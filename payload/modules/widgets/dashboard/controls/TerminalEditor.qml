pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.theme
import qs.modules.components
import qs.config

// Colorbxst: "Terminal" section of Settings > Theme.
// Edits the terminal colours stored in the Colorbxst mod settings.
// Left click: pick a palette colour or hex. Right click: back to default.
Item {
    id: root

    signal openColorPickerRequested(var colorNames, string currentColor, string dialogTitle, var callback)

    implicitHeight: mainColumn.implicitHeight

    readonly property var colorNames: Colors.availableColorNames

    readonly property var mainFields: [
        { key: "foreground", label: "Text" },
        { key: "cursor", label: "Cursor" },
        { key: "cursorText", label: "Text under cursor" },
        { key: "url", label: "Links (Kitty)" },
        { key: "selectionBg", label: "Selection" },
        { key: "selectionFg", label: "Selected text" }
    ]

    readonly property var ansiNames: ["Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White"]

    readonly property var ansiFields: {
        const out = [];
        // Each normal colour next to its bright variant: 0 | 8, 1 | 9, ...
        for (let i = 0; i < 8; i++) {
            out.push({ key: "ansi" + i, label: i + " " + ansiNames[i] });
            out.push({ key: "ansi" + (i + 8), label: (i + 8) + " Bright " + ansiNames[i] });
        }
        return out;
    }

    component SectionLabel: Text {
        font.family: Config.theme.font
        font.pixelSize: Styling.fontSize(-1)
        font.weight: Font.Medium
        color: Colors.overSurfaceVariant
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
    }

    component TerminalColorButton: ColorButton {
        id: btn
        required property var modelData
        readonly property string key: modelData.key
        readonly property bool overridden: Colorbxst.isOverridden(key)

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        colorNames: root.colorNames
        currentColor: Colorbxst.displayValue(key)
        label: modelData.label + (overridden ? "  •" : "")
        dialogTitle: "Terminal: " + modelData.label
        onOpenColorPicker: (names, current, title) => {
            root.openColorPickerRequested(names, current, title, function (color) {
                Colorbxst.setColor(btn.key, color);
            });
        }

        // Right click resets this colour to its default.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: Colorbxst.setColor(btn.key, "")
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        SectionLabel {
            text: "Background and opacity follow the Background variant. Click a colour to change it, right click to reset it. • marks a changed colour."
            opacity: 0.8
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: root.mainFields
                delegate: TerminalColorButton {}
            }
        }

        SectionLabel {
            text: "ANSI palette"
            Layout.topMargin: 4
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 8
            rowSpacing: 8

            Repeater {
                model: root.ansiFields
                delegate: TerminalColorButton {}
            }
        }

        StyledRect {
            id: resetButton
            variant: resetHover.containsMouse ? "focus" : "common"
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 32
            Layout.preferredWidth: resetLabel.implicitWidth + 24
            radius: Styling.radius(-2)

            Text {
                id: resetLabel
                anchors.centerIn: parent
                text: "Reset terminal colours"
                font.family: Config.theme.font
                font.pixelSize: Styling.fontSize(-1)
                font.bold: true
                color: resetButton.item
            }

            MouseArea {
                id: resetHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Colorbxst.resetAll()
            }
        }
    }
}
