const vbbStations = require("vbb-stations/full.json")
const vbbLinesAt = require("vbb-lines-at")
const fileSystem = require("fs")
const md5 = require("md5")

const hashToArray = (hash) => {
  return Object.keys(hash).reduce((result, id) => {
    return result.concat(hash[id])
  }, [])
}

const toJSON = (input) => JSON.stringify(input, null, 2)

const toFile = (name, content) => {
  return fileSystem.writeFile(name, content, (err) => {
    if (err) console.log(err)

    console.log(name, "generated!")
  })
}

/* Regexp to clean the names
 * From                            | To
 * S+U Neukölln (Berlin) [U7]      | Neukölln
 * U AlexanderPlatz (Berlin) [U8]  | Alexanderplatz
 * U Bullowstr. (Berlin) [U55]     | Bullowstr.
 * U Stadmitte U2                  | Stadmitte
 * S+U Rathaus Steglitz (Bhf) [U9] | Rathaus Steglitz
 */
const cleanStationName = (name) => name.replace(/((S\+U)|(U\s)|(\(.*?\))|(\[?U[0-9]*\]?))/g, "").trim()

const mergeStation = (stations, station, lines) => {
  const stationName = cleanStationName(station["name"])
  if (lines.length > 0) {
    if (stations[stationName] == null) {
      stations[stationName] = { "id": md5(stationName), "name": stationName, "lines": lines }
    } else {
      stations[stationName]["lines"] = lines.concat(stations[stationName]["lines"])
    }
  }
  return stations
}

const mergeLines = (lines, stationLines) => {
  return stationLines.reduce((lines, line) => {
    if (lines[line["id"]] == null) {
      lines[line["id"]] = line
    }

    return lines
  }, lines)
}

const subwayLinesFor = (station) => {
  return vbbLinesAt[station["id"]]
    .filter(line => line["product"] == "subway")
    .map(line => { return { "id": md5(line["id"]), "name": line["name"] } })
}

const state = hashToArray(vbbStations).reduce((state, station) => {
  var stations = state["stations"]
  var lines = state["lines"]
  const stationLines = subwayLinesFor(station)

  return {
    "stations": mergeStation(stations, station, stationLines),
    "lines": mergeLines(lines, stationLines)
  }
}, { "stations": {}, "lines": {} })

toFile("./output/stations.json", toJSON(hashToArray(state["stations"])))
toFile("./output/lines.json", toJSON(hashToArray(state["lines"])))
