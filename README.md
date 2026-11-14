# Colorbxst

Ambxst has two colour sources: the **palette** (from matugen or a colour preset, not editable) and the **variants** you edit in Settings > Theme (Background, Popup, Internal BG, Primary...). Several parts of the shell and the terminal generators read the palette directly, so they ignore what you set in Settings and only change with dark/light mode. This mod points them at the variants instead.

## What it changes

| Area | Before | With the mod |
|---|---|---|
| Ghostty / Kitty background | palette `background` | Background variant (first gradient colour + opacity) |
| Terminal text / cursor | palette `overSurface` | Background variant item colour, or a mod setting |
| ANSI palette | fixed tokens, inverted in light mode | mod settings `ANSI 0-15`; defaults keep 0/8 dark and 7/15 light |
| Calendar days and headers | `overSurface`, `outline`, `surfaceBright` (fixed dark grey) | Internal BG item colour, dimmed for secondary days |
| Context menus, tray menus | `background`, `overBackground`, `overPrimary` | Popup variant; hover uses Primary variant |
| Tooltips, OSD | `overBackground` | Popup variant item colour |

With the default Ambxst theme, the shell looks the same as before; the difference shows as soon as you edit a variant.

## Terminal colours

Settings > Theme > **Terminal** (below Colors). Click a colour to pick a palette name or a hex value, right click to reset it, • marks a changed colour. Background and opacity follow the Background variant. They are saved in `~/.config/ambxst/config/colorbxst.json`, so presets can include them: tick **colorbxst** when you create or update a preset.

## Settings

- **Dimmed text opacity**: opacity of secondary text (default 0.45).

## Install

```sh
ambxst mods install https://github.com/Ecta250/ambxst-colorbxst.git
ambxst mods enable ecta250.colorbxst
```

Restart Ambxst to load the new generation. If anything goes wrong: `ambxst mods rollback`.

Ghostty must use `theme = ambxst` in its config.
