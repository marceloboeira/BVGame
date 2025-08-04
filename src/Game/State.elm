port module Game.State exposing (Action(..), State, Step(..), fetchLines, fetchStations, init, shuffle, update)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Game.Score as Score exposing (GameMode(..), ScoreMsg(..))
import Http
import List exposing (map, member, sortBy, take)
import Maybe exposing (map, withDefault)
import Process
import Random exposing (Generator)
import Random.List
import String
import Task
import Time



-- Sound effect ports


port playCorrectSoundPort : () -> Cmd msg


port playWrongSoundPort : () -> Cmd msg


port playWarningSoundPort : () -> Cmd msg


type Step
    = Loading
    | Error String
    | Home
    | ModeSelection
    | NotStarted
    | Countdown Int
    | Ask Station
    | Finished


type alias State =
    { lines : List Line
    , stations : List Station
    , step : Step
    , lastAnswer : Maybe Bool
    , score : Int
    , lastScore : Int
    , timeLeft : Int
    , scoreEffect : Bool
    , plusOneAnim : Bool
    , highScores : { classic : Int, survival : Int, timeAttack : Int }
    , gameMode : GameMode
    , roundTimer : Int
    , lastGuessTime : Time.Posix
    , currentTime : Time.Posix
    , canGuess : Bool
    }


type Action
    = HomeAction
    | Tick Time.Posix
    | GotLinesData (Result Http.Error (List Line))
    | GotStationsData (Result Http.Error (List Station))
    | GotShuffledStations (List Station)
    | SelectMode GameMode
    | Start
    | Verify Station Line
    | SkipStation
    | KeyPress String
    | ScoreEffect
    | PlusOneAnim
    | ClearPlusOne
    | ScoreMsg ScoreMsg
    | UpdateCurrentTime Time.Posix
    | LoadAllHighScores { classic : Int, survival : Int, timeAttack : Int }
    | EnableGuess
    | CountdownTick
    | PlayCorrectSound
    | PlayWrongSound
    | PlayWarningSound


roundTime : Int
roundTime =
    30


roundTimer : Int
roundTimer =
    5


cooldownMs : Int
cooldownMs =
    500


handleNumberKey : Int -> State -> ( State, Cmd Action )
handleNumberKey number state =
    case state.step of
        Ask station ->
            List.drop (number - 1) state.lines
                |> List.head
                |> Maybe.map (\line -> update (Verify station line) state)
                |> withDefault ( state, Cmd.none )

        _ ->
            ( state, Cmd.none )


fetchLines : Cmd Action
fetchLines =
    Line.fetch "./data/lines.json" GotLinesData


fetchStations : Cmd Action
fetchStations =
    Station.fetch "./data/stations.json" GotStationsData


shuffle : List Station -> Cmd Action
shuffle stations =
    Random.generate GotShuffledStations (Random.List.shuffle stations)


init : ( State, Cmd Action )
init =
    ( State [] [] Loading Nothing 0 0 roundTime False False { classic = 0, survival = 0, timeAttack = 0 } Classic 0 (Time.millisToPosix 0) (Time.millisToPosix 0) True, fetchLines )


getInitialTimer : GameMode -> Int
getInitialTimer mode =
    case mode of
        Classic ->
            roundTime

        Survival ->
            roundTimer

        TimeAttack ->
            roundTime


updateTimer : GameMode -> Int -> Int
updateTimer mode currentTime =
    let
        newTime =
            currentTime - 1
    in
    if newTime <= 0 then
        0

    else
        newTime


isGameOver : GameMode -> Int -> Bool
isGameOver mode time =
    time <= 0


canGuess : Time.Posix -> Time.Posix -> Bool
canGuess currentTime lastGuessTime =
    let
        timeDiff =
            Time.posixToMillis currentTime - Time.posixToMillis lastGuessTime
    in
    timeDiff >= cooldownMs


updateGameState : GameMode -> Bool -> State -> List Station -> ( State, Cmd Action )
updateGameState mode isCorrect state remainingStations =
    let
        newScore =
            state.score
                + (if isCorrect then
                    1

                   else
                    0
                  )

        scoreCmd =
            if isCorrect then
                Task.perform (\_ -> PlusOneAnim) (Task.succeed ())

            else
                Cmd.none

        soundCmd =
            if isCorrect then
                Task.perform (\_ -> PlayCorrectSound) (Task.succeed ())

            else
                Task.perform (\_ -> PlayWrongSound) (Task.succeed ())

        cooldownCmd =
            Task.perform (\_ -> EnableGuess) (Process.sleep 500)
    in
    case mode of
        Survival ->
            if isCorrect then
                ( { state
                    | score = newScore
                    , lastAnswer = Nothing -- Reset for next station
                    , step = Ask (withDefault (Station "" "" []) (List.head remainingStations))
                    , stations = withDefault [] (List.tail remainingStations)
                    , scoreEffect = True
                    , plusOneAnim = True
                    , roundTimer = roundTimer
                    , canGuess = False
                  }
                , Cmd.batch [ scoreCmd, cooldownCmd, soundCmd ]
                )

            else
                ( { state
                    | lastScore = newScore
                    , score = newScore
                    , lastAnswer = Just False
                    , step = Home
                    , scoreEffect = True
                    , plusOneAnim = False
                    , canGuess = False
                  }
                , Cmd.batch [ scoreCmd, Score.saveScorePort (Score.encodeScore mode newScore), cooldownCmd, soundCmd ]
                )

        _ ->
            ( { state
                | score = newScore
                , lastAnswer = Nothing -- Reset for next station
                , step = Ask (withDefault (Station "" "" []) (List.head remainingStations))
                , stations = withDefault [] (List.tail remainingStations)
                , scoreEffect = isCorrect
                , plusOneAnim = isCorrect
                , canGuess = False
              }
            , Cmd.batch [ scoreCmd, cooldownCmd, soundCmd ]
            )


updateHighScore : GameMode -> Int -> { classic : Int, survival : Int, timeAttack : Int } -> { classic : Int, survival : Int, timeAttack : Int }
updateHighScore mode score highScores =
    case mode of
        Classic ->
            { highScores | classic = score }

        Survival ->
            { highScores | survival = score }

        TimeAttack ->
            { highScores | timeAttack = score }


update : Action -> State -> ( State, Cmd Action )
update action state =
    case action of
        HomeAction ->
            ( { state | step = Home }, Cmd.none )

        GotLinesData result ->
            result
                |> Result.map (\lines -> ( { state | lines = sortBy .name lines }, fetchStations ))
                |> Result.withDefault ( { state | step = Error "Couldn't load lines" }, Cmd.none )

        GotStationsData result ->
            result
                |> Result.map (\stations -> ( state, shuffle stations ))
                |> Result.withDefault ( { state | step = Error "Couldn't load stations" }, Cmd.none )

        GotShuffledStations stations ->
            ( { state | step = ModeSelection, stations = stations }, Cmd.none )

        SelectMode mode ->
            ( { state
                | gameMode = mode
                , step = Countdown 3
                , score = 0 -- Reset score for new game
                , lastAnswer = Nothing -- Reset answer state
                , plusOneAnim = False -- Reset animation state
                , scoreEffect = False -- Reset score effect
              }
            , Task.perform (\_ -> CountdownTick) (Process.sleep 1000)
            )

        Tick currentTime ->
            case state.step of
                Ask _ ->
                    let
                        newTime =
                            updateTimer state.gameMode state.timeLeft

                        newRoundTime =
                            updateTimer state.gameMode state.roundTimer

                        isUrgent =
                            (if state.gameMode == Survival then
                                newRoundTime

                             else
                                newTime
                            )
                                <= 10

                        wasNotUrgent =
                            (if state.gameMode == Survival then
                                state.roundTimer

                             else
                                state.timeLeft
                            )
                                > 10

                        warningCmd =
                            if isUrgent && wasNotUrgent then
                                Task.perform (\_ -> PlayWarningSound) (Task.succeed ())

                            else
                                Cmd.none
                    in
                    if
                        isGameOver state.gameMode
                            (if state.gameMode == Survival then
                                newRoundTime

                             else
                                newTime
                            )
                    then
                        ( { state | step = Finished }, Cmd.none )

                    else
                        ( { state
                            | timeLeft =
                                if state.gameMode == Survival then
                                    state.timeLeft

                                else
                                    newTime
                            , roundTimer =
                                if state.gameMode == Survival then
                                    newRoundTime

                                else
                                    state.roundTimer
                            , currentTime = currentTime
                          }
                        , warningCmd
                        )

                _ ->
                    ( { state | currentTime = currentTime }, Cmd.none )

        Start ->
            List.head state.stations
                |> Maybe.map
                    (\station ->
                        ( { state
                            | step = Countdown 3
                            , stations = withDefault [] (List.tail state.stations)
                            , score = 0
                            , lastAnswer = Nothing
                            , timeLeft = getInitialTimer state.gameMode -- Set initial timer
                            , roundTimer = roundTimer -- Set initial round timer
                            , plusOneAnim = False
                            , lastGuessTime = Time.millisToPosix 0
                            , currentTime = state.currentTime
                            , canGuess = True
                          }
                        , Task.perform (\_ -> CountdownTick) (Process.sleep 1000)
                        )
                    )
                |> withDefault ( { state | step = Error "Couldn't start the game" }, Cmd.none )

        Verify lastStation line ->
            if not state.canGuess then
                ( state, Cmd.none )

            else
                let
                    isCorrect =
                        member line lastStation.lines

                    remainingStations =
                        withDefault [] (List.tail state.stations)
                in
                if List.isEmpty remainingStations then
                    let
                        newScore =
                            state.score
                                + (if isCorrect then
                                    1

                                   else
                                    0
                                  )
                    in
                    ( { state
                        | lastScore = newScore
                        , score = newScore
                        , lastAnswer = Just isCorrect
                        , step = Home
                        , scoreEffect = isCorrect
                        , plusOneAnim = False
                        , lastGuessTime = state.currentTime
                        , canGuess = False
                      }
                    , Cmd.batch
                        [ if isCorrect then
                            Task.perform (\_ -> PlusOneAnim) (Task.succeed ())

                          else
                            Cmd.none
                        , Score.saveScorePort (Score.encodeScore state.gameMode newScore)
                        , Task.perform (\_ -> EnableGuess) (Process.sleep 500)
                        , if isCorrect then
                            Task.perform (\_ -> PlayCorrectSound) (Task.succeed ())

                          else
                            Task.perform (\_ -> PlayWrongSound) (Task.succeed ())
                        ]
                    )

                else
                    let
                        updatedState =
                            { state | lastGuessTime = state.currentTime, canGuess = False }
                    in
                    updateGameState state.gameMode isCorrect updatedState remainingStations

        SkipStation ->
            case state.step of
                Ask _ ->
                    List.head state.stations
                        |> Maybe.map
                            (\station ->
                                ( { state
                                    | step = Ask station
                                    , stations = withDefault [] (List.tail state.stations)
                                    , lastAnswer = Nothing -- Reset for next station
                                  }
                                , Cmd.none
                                )
                            )
                        |> withDefault ( { state | step = Home, lastScore = state.score }, Cmd.none )

                _ ->
                    ( state, Cmd.none )

        ScoreEffect ->
            ( { state | scoreEffect = False }, Cmd.none )

        PlusOneAnim ->
            ( { state | plusOneAnim = True }, Task.perform (\_ -> ClearPlusOne) (Task.succeed ()) )

        ClearPlusOne ->
            ( { state | plusOneAnim = False }, Cmd.none )

        ScoreMsg msg ->
            case msg of
                SaveScore mode score ->
                    ( state, Score.saveScorePort (Score.encodeScore mode score) )

                GetHighScore mode ->
                    ( state, Cmd.none )

                HighScoreReceived mode score ->
                    let
                        newHighScores =
                            updateHighScore mode score state.highScores
                    in
                    ( { state | highScores = newHighScores }, Cmd.none )

        UpdateCurrentTime time ->
            ( { state | currentTime = time }, Cmd.none )

        LoadAllHighScores highScores ->
            ( { state | highScores = highScores }, Cmd.none )

        EnableGuess ->
            ( { state | canGuess = True }, Cmd.none )

        PlayCorrectSound ->
            ( state, playCorrectSoundPort () )

        PlayWrongSound ->
            ( state, playWrongSoundPort () )

        PlayWarningSound ->
            ( state, playWarningSoundPort () )

        CountdownTick ->
            case state.step of
                Countdown count ->
                    if count > 1 then
                        ( { state | step = Countdown (count - 1) }
                        , Task.perform (\_ -> CountdownTick) (Process.sleep 1000)
                        )

                    else
                        -- Countdown finished, start the game
                        List.head state.stations
                            |> Maybe.map
                                (\station ->
                                    ( { state
                                        | step = Ask station
                                        , timeLeft = getInitialTimer state.gameMode -- Reset timer
                                        , roundTimer = roundTimer -- Reset round timer
                                        , lastAnswer = Nothing -- Reset answer state
                                        , score = 0 -- Ensure score is reset
                                        , plusOneAnim = False -- Reset animation
                                        , scoreEffect = False -- Reset score effect
                                      }
                                    , Cmd.none
                                    )
                                )
                            |> withDefault ( { state | step = Error "Couldn't start the game" }, Cmd.none )

                _ ->
                    ( state, Cmd.none )

        KeyPress key ->
            case key of
                " " ->
                    case state.step of
                        Home ->
                            update (SelectMode state.gameMode) state

                        NotStarted ->
                            update Start state

                        _ ->
                            ( state, Cmd.none )

                "Escape" ->
                    update SkipStation state

                _ ->
                    String.toInt key
                        |> Maybe.map (\num -> handleNumberKey num state)
                        |> withDefault ( state, Cmd.none )
