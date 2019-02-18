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

# Motivation

The ideia is to learn more about functional programming & front-end applications with Elm.

**Disclaimer** don't take the code here too seriously, it's probably crappy since it's my first attempt to build an SPA and also my first app with Elm. 😉

## The Game

The game is about Subway Stations and Lines from the Berliner Verkehrsbetriebe [BVG](https://www.bvg.de/en). The players must guess at least one train Line that cross a given station.

# Architecture
> How does it work?

<a href="https://marceloboeira.com/BVGame">
  <img src="https://github.com/marceloboeira/BVGame/blob/master/docs/diagram.png?raw=true">
</a>

## Web
> Static SPA served with GitHub Pages

The code of the application is written in Elm. During build, the Elm files are compiled to a single Javascript, `application.js` that is served statically, together with raw CSS and HTML files. Everything under `dist/` is served with Github Pages, built from the `master` branch of this repo to the `gh-pages` branch by Travis-CI.

The application also requires data coming from the `dist/data` folder, which is generated from the pipeline.

## Data Pipeline
> Gathering data for the game

In order to gather information about the stations, a small pipeline was created, heavily inspired by [derhuerst](https://github.com/derhuerst) work on the [VBB libraries](https://github.com/derhuerst/vbb-modules).

The output of the pipeline is copied to `dist/data/` as JSON files, consumed by the web-application as data source.

# Contributing
> Help us to improve the codebase

## Development
> Available commands

* `make run` - Run the webserver at `http://localhost:1928`.
* `make build` - Build the `application.js` file to the `dist/` folder.
* `make setup` - One time setup of dependencies.
* `make setup_pipeline` - Install dependencies for the pipeline. (It's triggered by the setup)
* `make build_pipeline` - Run the pipeline and copy the files to the `dist/` folder.  (It's triggered by the setup)
* `make test` - Run the tests.
* `make test_watch` - Run the tests watching for changes.
* `make check_format` - Check if the code is formated
* `make format` - Format the code following elm standards.

## Credits

* Data Sources
  * [derhuerst/vbb-stations](https://github.com/derhuerst/vbb-stations) - List of Stations
  * [derhuerst/vbb-lines](https://github.com/derhuerst/vbb-lines) - List of Lines
  * [Wikipedia](https://de.wikipedia.org/wiki/Liste_der_Berliner_U-Bahnhöfe)
