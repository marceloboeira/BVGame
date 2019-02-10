<p align="center">
  <img src="https://github.com/marceloboeira/BVGame/blob/master/docs/bvg-logo.gif?raw=true" width="200">
  <h3 align="center">BVGame</h3>
  <p align="center">💛 An unofficial BVG Stations Game<p>
  <p align="center">
    <a href="https://travis-ci.org/marceloboeira/BVGame"><img src="https://img.shields.io/travis/marceloboeira/BVGame.svg?maxAge=360"></a>
    <a href="http://github.com/marceloboeira/BVGame/releases"><img src="https://img.shields.io/github/release/marceloboeira/BVGame.svg?maxAge=360"></a>
    <a href="https://marceloboeira.com/BVGame"><img src="https://img.shields.io/badge/access-BVGame-f0d722.svg?maxAge=360"></a>
  </p>
</p>

## Motivation

The ideia is to learn more about functional programming & front-end applications with Elm.

### The Game

The game is about Subway Stations and Lines from the Berliner Verkehrsbetriebe [BVG](https://www.bvg.de/en). The players must guess at least one train Line that cross a given station.

## Changelog
> See what changed over time

### v0.0.1 - First "playbable"

Up to this point the game is quite raw:

1. You load the page
2. Click start
3. See the Statation
4. Select one of the 9 possible U-Bahn lines
5. Repeat steps 3 and 4 for 5 rounds
6. See a "end-game" screen with your score

Limitations:

* Only 6 stations are available
* The stations always appear in the same order
* No support for mobile devices / screen sizes

Technically:

* No significant abstractions, mainly adding everyting to "Application.elm"
* No significant testing, only some samples to learn about `elm-explorations/test`.
* No CSS/JS pipeline (uglify/minimize)
* No HTML/CSS optmizations

## Contributing
> Help us to improve the codebase

### Development
> Available commands

* `make run` - Run the webserver at `http://localhost:1928`.
* `make build` - Build the `application.js` file to the `dist/` folder.
* `make setup` - One time setup of dependencies.
* `make test` - Run the tests.
* `make test_watch` - Run the tests watching for changes.
* `make check_format` - Check if the code is formated
* `make format` - Format the code following elm standards.
