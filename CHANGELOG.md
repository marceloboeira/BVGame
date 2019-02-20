# Changelog
> See what changed over time

## v0.2.0 - Timeout

The game now has a new design and a time constraint.

Features:
* Timeout after 30s
* Unlimited stations
* Minimalist design
* Footer with Github Logo
* Google Analytics

Bug fixes:
* Pipeline names with "Berlin," are better handled now

Technicall improvements:
* Lots of tests
* Experimenting with Subscriptions

## v0.1.0 - Welcome Data

The game is still raw, but it has some interesting features.

Features:
* A data pipeline downloads data from BVG/VBB for stations and lines
* Randomically select stations (makes the game less predictable and more interactive)
* Better handling of errors (the user now knows if something didn't work well with an Error page)

Bug fixes:
* CSS adjustments

Technicall improvements:
* Less usage of state for the game functionality
* Better management of memory, but keeping only relevant stations
* Better update-loop and rendering by storing the Step of the game
* State and View are now modules
* State has now a full suite of tests

## v0.0.1 - First "playbable"

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
