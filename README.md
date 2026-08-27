<div align="center">

# Velora 🥀

**A polished Roblox piano player with a growing library of hand-prepared and MIDI-converted arrangements.**

![Lua](https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-D34C5A?style=flat-square)
![Status](https://img.shields.io/badge/Status-Active-D34C5A?style=flat-square)

</div>

---

## ✨ Features

- Clean dark ruby glass interface
- Searchable song library with categories
- Favorites and recent-song history
- Adjustable BPM and playback controls
- Loop support and progress seeking
- Live library updates from this repository
- High-resolution MIDI conversions with timing preserved where possible
- Automatic keyboard output when supported by the runtime environment

## 🚀 Run Velora

### GitHub launcher

```lua
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/MrRos3/Velora/main/loader.lua"
))()
```

### CDN fallback

If direct GitHub access is unavailable in your environment:

```lua
loadstring(game:HttpGet(
    "https://cdn.jsdelivr.net/gh/MrRos3/Velora@main/loader.lua"
))()
```

> **Tip:** Before pressing Play, click the in-game piano once so it owns keyboard focus.

## 🎹 Music Library

Velora contains a growing collection of piano arrangements, game themes, classical pieces, soundtrack music, and MIDI conversions.

Song metadata lives in [`Songs.lua`](./Songs.lua), while individual arrangements are stored in [`songs/`](./songs).

For converted material, source and licensing information is kept inside the corresponding song file whenever available. Third-party compositions, MIDI files, scores, names, and trademarks remain the property of their respective owners.

## 🧩 Project Structure

```text
Velora/
├── loader.lua       # Public entry point
├── runtime.lua      # Runtime bootstrap
├── visuals.lua      # Visual treatment
├── polish.lua       # Final UI polish
├── release.lua      # Core application
├── patches.lua      # Runtime patch layer
├── Songs.lua        # Song registry
└── songs/           # Individual arrangements
```

## ⚙️ Requirements

Velora requires an environment that provides `loadstring` and HTTP access through `game:HttpGet`.

Automatic piano playback also depends on keyboard-input support exposed by the runtime environment. If automatic input is unavailable, Velora can still load and display the interface and library.

## 📜 License

Velora's original source code is licensed under the **MIT License**.

Copyright © 2026 **MrRos3**.

See [`LICENSE`](./LICENSE) for the full license text.

> The MIT License applies to Velora's original source code. Third-party music, arrangements, scores, MIDI sources, trademarks, and other referenced works retain their respective rights and licenses.

---

<div align="center">

**Made by MrRos3 · Velora 🥀**

</div>
