/*
 * Pipeline
 * ================
 *
 * The pipeline uses libraries to gather information about BVG lines and stations
 * to cross-reference, clean, and format them. They serve as the source for the game.
 *
 * At this point, only U-Bahn (subway) lines are supported, since the game is for BVG
 * and both Tram/Bus lines are not so consistent with station names.
 *
 */
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

// Represents only UBahn stations so far
const colorFor = (line) => {
  return {
    "U1": { "background": "#59ff00", "font": "#fff"  },
    "U2": { "background": "#ff3300", "font": "#fff"  },
    "U3": { "background": "#00ff66", "font": "#fff"  },
    "U4": { "background": "#ffe600", "font": "#000"  },
    "U5": { "background": "#664019", "font": "#fff"  },
    "U55": { "background": "#664019", "font": "#fff"  },
    "U6": { "background": "#4d66ff", "font": "#fff"  },
    "U7": { "background": "#33ccff", "font": "#fff"  },
    "U8": { "background": "#0061da", "font": "#fff"  },
    "U9": { "background": "#ff7300", "font": "#fff"  }
  }[line]
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
    .map(line => {
      return {
        "id": md5(line["id"]),
        "name": line["name"],
        "color": colorFor(line["name"]),
      }
    })
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
