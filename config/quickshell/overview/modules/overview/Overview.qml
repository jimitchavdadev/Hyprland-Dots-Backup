import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../services"
import "."

Scope {
    id: overviewScope
    property real lastToggleTime: 0

    Variants {
        id: overviewVariants
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData
            visible: GlobalStates.overviewOpen
            property alias keyCapture: keyCapture

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: GlobalStates.overviewOpen
                                         ? WlrKeyboardFocus.Exclusive
                                         : WlrKeyboardFocus.None
            color: "transparent"

            anchors { top: true; bottom: true; left: true; right: true }

            onVisibleChanged: {
                console.log("QML LOG: PanelWindow visible changed to:", visible)
                if (visible) {
                    keyCapture.forceActiveFocus()
                }
            }

            // ── Dimmer / click-outside-to-dismiss ──────────────────────────
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.55)
                z: 0
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("QML LOG: Dimmer clicked! Closing overview.")
                        GlobalStates.overviewOpen = false
                    }
                }
            }

            // ── Keyboard capture ────────────────────────────────────────────
            Item {
                id: keyCapture
                anchors.fill: parent
                focus: GlobalStates.overviewOpen
                z: 1
                Keys.onPressed: (event) => {
                    console.log("QML LOG: Key pressed in capture:", event.key, "modifiers:", event.modifiers)
                    if (event.key === Qt.Key_Escape) {
                        console.log("QML LOG: Escape pressed. Closing overview.")
                        GlobalStates.overviewOpen = false
                        event.accepted = true
                    } else if ((event.key === Qt.Key_A || event.key === 65 || event.key === 97) && (event.modifiers & Qt.MetaModifier)) {
                        if (!event.isAutoRepeat) {
                            console.log("QML LOG: Super+A pressed in capture. Closing overview.")
                            GlobalStates.overviewOpen = false
                        }
                        event.accepted = true
                    }
                }
            }

            // ── Overview widget ─────────────────────────────────────────────
            Loader {
                id: widgetLoader
                active: GlobalStates.overviewOpen
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -50
                z: 2
                sourceComponent: OverviewWidget {
                    panelWindow: root
                }
            }
        }
    }

    // ── IPC handler ─────────────────────────────────────────────────────────
    IpcHandler {
        target: "overview"
        function toggle() {
            var now = Date.now()
            if (now - lastToggleTime < 300) {
                console.log("QML LOG: IPC toggle ignored (debounced). Time diff:", now - lastToggleTime)
                return
            }
            lastToggleTime = now
            console.log("QML LOG: IPC toggle() called. Current overviewOpen:", GlobalStates.overviewOpen)
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
        function close()  {
            console.log("QML LOG: IPC close() called.")
            GlobalStates.overviewOpen = false
        }
        function open()   {
            console.log("QML LOG: IPC open() called.")
            GlobalStates.overviewOpen = true
        }
    }

    Connections {
        target: GlobalStates
        function onOverviewOpenChanged() {
            console.log("QML LOG: GlobalStates.overviewOpen changed to:", GlobalStates.overviewOpen)
        }
    }

    Component.onCompleted: {
        console.log("QML LOG: Overview module loaded.")
    }
}
