# Changelog

## 0.7.0

- Presets: terminal colours moved to `~/.config/ambxst/config/colorbxst.json` (moved automatically from the 0.5.0 location) and **colorbxst** is listed with the other files when you create or update a preset. Loading a preset that contains it restores your terminal colours.
- `surface` and `surfaceBright` use the palette's own tones instead of 10 % / 20 % tints of the background (the tints remain in OLED mode).

## 0.6.0

- Power menu, tools menu and screenshot/record mode icons follow the Background variant when not selected.
- Settings switches: the track follows the Primary variant when on and the Pane text colour (faint) when off; the knob follows the Primary or Pane text colour.

## 0.5.0

- Terminal colours are saved in `~/.config/ambxst/colorbxst.json` and only edited in Settings > Theme > Terminal; they no longer appear in Settings > Mods > Colorbxst, which keeps only Dimmed text opacity.
- Bar clock, clock icon and weather text follow the Background variant; empty workspaces use the same colour, dimmed.
- Lock screen clock follows the Primary variant (was the fixed primaryFixed tones).

## 0.4.0

- GTK, Qt (qt5ct/qt6ct), Discord and NvChad take their background and base text from the Background variant.
- Pywal (`~/.cache/wal/colors`, `colors.json`) uses the Terminal palette, background, text and cursor.
- Critical notifications use the Error variant instead of the fixed #FF6B08 / #FF0028.
- Fixed `Colors.foreground` (does not exist) in the bar pin buttons and ToggleButton.
- Right-click option lists (launcher, clipboard, tmux, notes, presets) follow the Popup variant; selected text follows its highlight variant.
- Power profile and layout selectors follow the Background variant; AI model selector follows Popup.

## 0.3.1

- Bigger colour buttons in the Terminal section; the ANSI palette shows each colour next to its bright variant.

## 0.3.0

- Terminal colours moved to their own **Terminal** section in Settings > Theme, below Colors, instead of an entry in the variant list.

## 0.2.0

- Renamed from Theme Coherence to Colorbxst (id `ecta250.colorbxst`).
- New **Terminal** entry in Settings > Theme > Colors: edit terminal text, cursor, selection, links and ANSI 0-15 with the native colour picker (palette name or hex). Right click resets a colour; "Reset terminal colours" resets them all.

## 0.1.0

- Ghostty and Kitty take their background and opacity from the Background variant in Settings > Theme, and their text and cursor from its item colour.
- Editable ANSI palette (ANSI 0-15) in the mod settings. Defaults keep black dark and white light in light mode instead of inverting them.
- Terminal themes regenerate when the Background variant or a mod setting changes.
- Calendar: day numbers, weekday headers and the separator follow the Internal BG variant. Days outside the month and other weekdays use the same colour, dimmed (Dimmed text opacity).
- Context menus (desktop, player) and tray menus follow the Popup variant for background, border and text, and the Primary variant for the hovered item.
- Tooltips and the volume/brightness OSD follow the Popup variant's item colour.
