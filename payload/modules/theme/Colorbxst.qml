pragma Singleton
import QtQuick
import Quickshell
import qs.config
import qs.modules.theme
import Quickshell.Io
import qs.modules.services

// Colorbxst: one place that turns the user's editable theme
// (the StyledRect variants in Settings > Theme, the Terminal section and
// this mod's settings) into the colours app generators and widgets use.
Singleton {
    id: root

    readonly property string modId: "ecta250.colorbxst"

    // Mod settings, merged over these defaults once the backend answers.
    property var values: ({})
    property bool settingsLoaded: false

    // Fired when anything a generator reads has changed.
    signal changed

    // ---- Shell widgets -------------------------------------------------

    // Opacity for secondary text (other-month days, inactive weekdays...).
    readonly property real dimOpacity: {
        const v = Number(values.dimOpacity);
        return isFinite(v) && v > 0 ? Math.min(v, 1) : 0.45;
    }

    // Background of the "Popup" variant (first gradient colour), for menus
    // that clip their content and so cannot be a StyledRect.
    readonly property color popupBackground: {
        const g = Config.theme.srPopup.gradient;
        return (g && g.length > 0 && g[0].length > 0) ? Config.resolveColor(g[0][0]) : Colors.background;
    }

    // Background of the "Primary" variant (first gradient colour).
    readonly property color primaryColor: {
        const g = Config.theme.srPrimary.gradient;
        return (g && g.length > 0 && g[0].length > 0) ? Config.resolveColor(g[0][0]) : Colors.primary;
    }

    // Same colour at the dimmed-text opacity.
    function dim(c) {
        return Qt.rgba(c.r, c.g, c.b, dimOpacity);
    }

    // Same colour, faint (switch tracks, separators).
    function faint(c) {
        return Qt.rgba(c.r, c.g, c.b, 0.2);
    }

    // Text of a selected option: item colour of the variant its highlight uses.
    function optionText(highlightColor) {
        if (highlightColor !== undefined && highlightColor === Colors.error)
            return Styling.srItem("error");
        if (highlightColor !== undefined && highlightColor === Colors.secondary)
            return Styling.srItem("secondary");
        return Styling.srItem("primary");
    }

    // ---- Terminals -----------------------------------------------------

    // "Background" variant: first gradient stop, its opacity, its item colour.
    readonly property color appBackground: {
        const g = Config.theme.srBg.gradient;
        const name = (g && g.length > 0 && g[0].length > 0) ? g[0][0] : "background";
        return Config.oledMode ? "#000000" : Config.resolveColor(name);
    }
    readonly property real appOpacity: Config.theme.srBg.opacity
    readonly property color appForeground: Styling.srItem("bg")

    readonly property bool lightMode: Config.theme.lightMode

    // Defaults per ANSI slot. 0/8 stay dark and 7/15 stay light in both modes,
    // so programs that assume a dark "black" and a light "white" keep working.
    readonly property var darkAnsi: ["surfaceContainerLow", "red", "green", "yellow", "primary", "magenta", "cyan", "outline", "surfaceBright", "lightRed", "lightGreen", "lightYellow", "lightBlue", "lightMagenta", "lightCyan", "overSurface"]
    readonly property var lightAnsi: ["inverseSurface", "red", "green", "yellow", "primary", "magenta", "cyan", "surfaceContainerHighest", "outline", "lightRed", "lightGreen", "lightYellow", "lightBlue", "lightMagenta", "lightCyan", "surfaceContainerLowest"]

    // Terminal colours live in ~/.config/ambxst/config/colorbxst.json (edited in
    // Settings > Theme > Terminal); other options come from the mod settings.
    function setting(key) {
        const v = terminalKeys.includes(key) ? store.adapter[key] : values[key];
        return (v === undefined || v === null) ? "" : String(v).trim();
    }

    // A setting that holds a palette name or a hex value, or the fallback.
    function colorSetting(key, fallback) {
        const v = setting(key);
        if (!v)
            return fallback;
        const c = Config.resolveColor(v);
        return (String(c) === "transparent") ? fallback : c;
    }

    function ansi(i) {
        const name = (lightMode ? lightAnsi : darkAnsi)[i];
        return colorSetting("ansi" + i, Config.resolveColor(name));
    }

    // ---- App generators (GTK, Qt, Discord, NvChad, Pywal) ---------------

    // A copy of the palette where the base background and text follow the
    // "Background" variant. Generators call `Colors = Colorbxst.appColors(Colors)`
    // and keep reading Colors.* as before.
    function appColors(palette) {
        const out = {};
        const source = palette.adapter || palette;
        for (const key in source) {
            const v = palette[key] !== undefined ? palette[key] : source[key];
            if (v !== null && typeof v === "object" && v.r !== undefined && v.a !== undefined)
                out[key] = v;
        }
        for (const key of ["criticalText", "criticalRed", "warning", "success"]) {
            if (palette[key] !== undefined)
                out[key] = palette[key];
        }
        out.background = appBackground;
        out.overBackground = appForeground;
        return out;
    }

    // ---- Terminal editor (Settings > Theme > Terminal) -------------------

    readonly property var terminalKeys: ["foreground", "cursor", "cursorText", "selectionBg", "selectionFg", "url"].concat(Array.from({ length: 16 }, (_, i) => "ansi" + i))

    // Palette name used when a terminal setting is empty.
    function defaultName(key) {
        if (key.startsWith("ansi"))
            return (lightMode ? lightAnsi : darkAnsi)[parseInt(key.substring(4))];
        switch (key) {
        case "foreground":
        case "cursor":
            return Config.theme.srBg.itemColor || "overBackground";
        case "cursorText":
            return "overSurfaceVariant";
        case "selectionBg":
            return "secondaryFixedDim";
        case "selectionFg":
            return "overSecondary";
        case "url":
            return "primary";
        }
        return "";
    }

    // What the editor shows: the override if set, else the default name.
    function displayValue(key) {
        return setting(key) || defaultName(key);
    }

    function isOverridden(key) {
        return setting(key) !== "";
    }

    function setColor(key, value) {
        if (!terminalKeys.includes(key))
            return;
        store.adapter[key] = (value === undefined || value === null) ? "" : String(value);
    }

    function resetAll() {
        for (const key of terminalKeys) {
            if (isOverridden(key))
                store.adapter[key] = "";
        }
    }

    property bool pauseSave: false

    // 0.5.0 kept the file in ~/.config/ambxst; move it next to the other configs.
    property Process migrate: Process {
        running: true
        command: ["sh", "-c", "d=\"$HOME/.config/ambxst\"; [ -f \"$d/colorbxst.json\" ] && [ ! -f \"$d/config/colorbxst.json\" ] && mv \"$d/colorbxst.json\" \"$d/config/colorbxst.json\"; true"]
    }

    property FileView store: FileView {
        // Lives next to theme.json so Ambxst presets can save and load it.
        path: Quickshell.env("HOME") + "/.config/ambxst/config/colorbxst.json"
        atomicWrites: true
        watchChanges: true
        printErrors: false
        blockLoading: true
        onFileChanged: {
            root.pauseSave = true;
            reload();
            root.pauseSave = false;
            root.requestRegeneration();
        }
        onAdapterUpdated: {
            if (!root.pauseSave)
                writeAdapter();
            root.requestRegeneration();
        }

        adapter: JsonAdapter {
            property string foreground: ""
            property string cursor: ""
            property string cursorText: ""
            property string selectionBg: ""
            property string selectionFg: ""
            property string url: ""
            property string ansi0: ""
            property string ansi1: ""
            property string ansi2: ""
            property string ansi3: ""
            property string ansi4: ""
            property string ansi5: ""
            property string ansi6: ""
            property string ansi7: ""
            property string ansi8: ""
            property string ansi9: ""
            property string ansi10: ""
            property string ansi11: ""
            property string ansi12: ""
            property string ansi13: ""
            property string ansi14: ""
            property string ansi15: ""
        }
    }

    // Opaque "#rrggbb" for any colour value (name already resolved, hex, color).
    function hex(c) {
        const q = Qt.tint(c, "transparent");
        return Qt.rgba(q.r, q.g, q.b, 1).toString();
    }

    // Everything a terminal generator needs, as "#rrggbb" strings.
    function terminal() {
        const palette = [];
        for (let i = 0; i < 16; i++)
            palette.push(hex(ansi(i)));
        return {
            background: hex(appBackground),
            backgroundOpacity: appOpacity,
            foreground: hex(colorSetting("foreground", appForeground)),
            cursor: hex(colorSetting("cursor", appForeground)),
            cursorText: hex(colorSetting("cursorText", Colors.overSurfaceVariant)),
            selectionForeground: hex(colorSetting("selectionFg", Colors.overSecondary)),
            selectionBackground: hex(colorSetting("selectionBg", Colors.secondaryFixedDim)),
            url: hex(colorSetting("url", Colors.primary)),
            palette: palette
        };
    }

    // ---- Wiring --------------------------------------------------------

    function loadSettings() {
        ModsService.getSettings(root.modId, (settings, error) => {
            root.values = error ? {} : (settings?.values ?? {});
            root.settingsLoaded = true;
            root.requestRegeneration();
        });
    }

    function requestRegeneration() {
        root.changed();
        if (Colors.generationTimer)
            Colors.generationTimer.restart();
    }

    onAppBackgroundChanged: requestRegeneration()
    onAppOpacityChanged: requestRegeneration()
    onAppForegroundChanged: requestRegeneration()

    property Connections settingsWatcher: Connections {
        target: ModsService
        function onSettingChanged(modId, key, value) {
            if (modId !== root.modId)
                return;
            const next = Object.assign({}, root.values);
            next[key] = value;
            root.values = next;
            root.requestRegeneration();
        }
    }

    Component.onCompleted: loadSettings()
}
