import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const read = (file) => fs.readFileSync(path.join(root, file), "utf8").replace(/^\uFEFF/, "");
const wrap = (name, source) => `local ${name} = (function()\n${source.trim()}\nend)()\n`;

let main = read("Main.lua");
main = main.replace(
    /local root = script\.Parent[\s\S]*?local SongRegistry = require\(root:WaitForChild\("Songs"\)\)\n/,
    ""
);
main = main.replace(
    /    local moduleName = entry\.File[\s\S]*?    end\n\n    local bpm =/,
    `    local moduleName = entry.File and entry.File:match("([^/]+)%.lua$")
    local song = moduleName and BuiltinSongs[moduleName]
    if not song then
        warn(("Velora: bundled song missing for %s (%s)"):format(entry.Name, tostring(entry.File)))
        return false
    end

    local bpm =`
);

const songFiles = fs.readdirSync(path.join(root, "songs"))
    .filter((file) => file.endsWith(".lua"))
    .sort();

const bundledSongs = songFiles.map((file) => {
    const name = path.basename(file, ".lua");
    return `    [${JSON.stringify(name)}] = (function()\n${read(path.join("songs", file)).trim()}\n    end)(),`;
}).join("\n");

const output = [
    "-- Velora v0.2 standalone Studio build 🥀🎹",
    "-- Copy this entire file into a LocalScript in StarterPlayerScripts, then press Play.",
    "-- Generated from the modular source by build-standalone.mjs.",
    "",
    wrap("Parser", read("src/Parser.lua")),
    wrap("Player", read("src/Player.lua")),
    wrap("PianoAdapter", read("src/PianoAdapter.lua")),
    wrap("UI", read("src/UI.lua")),
    wrap("SongRegistry", read("Songs.lua")),
    "local BuiltinSongs = {",
    bundledSongs,
    "}",
    "",
    main.trim(),
    "",
].join("\n");

if (/script\.Parent|WaitForChild\("src"\)|require\(/.test(output)) {
    throw new Error("Standalone build still contains a module dependency");
}

fs.writeFileSync(path.join(root, "Standalone.client.lua"), output);
console.log(`Built Standalone.client.lua (${output.split("\n").length} lines)`);
