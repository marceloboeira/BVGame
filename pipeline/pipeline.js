//TODO
// Feature:
// Gather photos
// Generate a MD5 of the name for the IDs (since they are in theory unique)
// Gather colors?
//
// Refactor
// Receive options as parameters (output path)
// Make the pipeline more functional
const vbbStationPhotos = require("vbb-station-photos");
const vbbLinesAt = require("vbb-lines-at");
const vbbStations = require("vbb-stations/full.json");
const fileSystem = require("fs");

// Globals
var finalStations = {}
var finalLines = {}

const hashToArray = (hash) => {
  return Object.keys(hash).reduce((result, id) => {
    return result.concat(hash[id])
  }, []);
}

const toJSON = (input) => JSON.stringify(input, null, 2)

const toFile = (name, content) => {
  return fileSystem.writeFile(name, content, (err) => {
    if (err) console.log(err);

    console.log(name, "generated!");
  });
}

for (var vbbStationId in vbbStations) {
  var vbbStation = vbbStations[vbbStationId]
  var vbbStationLines = vbbLinesAt[vbbStationId]
  var hasSubwayLine = false

  var stationLines = []
  for (var id in vbbStationLines) {
    var vbbLine = vbbStationLines[id]
    if (vbbLine["mode"] == "train" && vbbLine["product"] == "subway") {
      hasSubwayLine = true

      // Add to the unique list of Lines
      finalLines[vbbLine["id"]] = { "id": vbbLine["id"], "name": vbbLine["name"] }

      stationLines.push(vbbLine["id"])
    }
  }

  if (hasSubwayLine) {
    // Regexp to clean the names
    // From                            | To
    // S+U Neukölln (Berlin) [U7]      | Neukölln
    // U AlexanderPlatz (Berlin) [U8]  | Alexanderplatz
    // U Bullowstr. (Berlin) [U55]     | Bullowstr.
    // U Stadmitte U2                  | Stadmitte
    // S+U Rathaus Steglitz (Bhf) [U9] | Rathaus Steglitz

    cleanStationName = vbbStation["name"].replace(/((S\+U)|(U\s)|(\(.*?\))|(\[?U[0-9]*\]?))/g, "").trim()

    if (finalStations[cleanStationName] == null) {
      finalStations[cleanStationName] = { "name": cleanStationName, "lines": stationLines}
    } else {
      finalStations[cleanStationName]["lines"] = stationLines.concat(finalStations[cleanStationName]["lines"])
    }
  }
}

toFile("./output/stations.json", toJSON(hashToArray(finalStations)))
toFile("./output/lines.json", toJSON(hashToArray(finalLines)))
