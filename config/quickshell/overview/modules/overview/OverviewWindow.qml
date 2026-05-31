import QtQuick.Effects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../common"
import "../../common/functions"
import "../../services"

Item { // Window
    id: root
    property var toplevel
    property var windowData
    property var monitorData
    property var scale
    property var availableWorkspaceWidth
    property var availableWorkspaceHeight
    property bool restrictToWorkspace: true
    property real initX: Math.max(((windowData?.at[0] ?? 0) - (monitorData?.x ?? 0) - (monitorData?.reserved?.[0] ?? 0)) * root.scale, 0) + xOffset
    property real initY: Math.max(((windowData?.at[1] ?? 0) - (monitorData?.y ?? 0) - (monitorData?.reserved?.[1] ?? 0)) * root.scale, 0) + yOffset
    property real xOffset: 0
    property real yOffset: 0
    property int widgetMonitorId: 0
    
    property var targetWindowWidth: (windowData?.size[0] ?? 100) * scale
    property var targetWindowHeight: (windowData?.size[1] ?? 100) * scale
    property bool hovered: false
    property bool pressed: false

    property var iconToWindowRatio: 0.25
    property var xwaylandIndicatorToIconRatio: 0.35
    property var iconToWindowRatioCompact: 0.45
    function iconExists(name) {
        if (!name) return false;
        var path = Quickshell.iconPath(name, true);
        return path && path.toString().length > 0;
    }

    function guessIcon(cls) {
        if (!cls) return "application-x-executable";
        
        // Try exact class name
        if (iconExists(cls)) return cls;
        
        // Try lowercased class name
        var lower = cls.toLowerCase();
        if (iconExists(lower)) return lower;
        
        // Try splitting by hyphen or underscore and take the first part
        var parts = cls.split(/[_-]/);
        if (parts.length > 1) {
            var p0 = parts[0];
            if (iconExists(p0)) return p0;
            var p0l = p0.toLowerCase();
            if (iconExists(p0l)) return p0l;
        }
        
        // Common substitutions
        var subs = {
            "Spotify": "spotify",
            "firefox-developer-edition": "firefox",
            "firefox-dev": "firefox",
            "ghostty": "terminal",
            "kitty": "terminal"
        };
        var subName = subs[cls] || subs[lower];
        if (subName && iconExists(subName)) return subName;
        
        return "application-x-executable";
    }

    property var iconPath: {
        var iconName = guessIcon(windowData?.class);
        if (iconExists(iconName)) {
            return Quickshell.iconPath(iconName, "");
        }
        if (iconExists("application-x-executable")) {
            return Quickshell.iconPath("application-x-executable", "");
        }
        if (iconExists("image-missing")) {
            return Quickshell.iconPath("image-missing", "");
        }
        return "";
    }
    property bool compactMode: Appearance.font.pixelSize.smaller * 4 > targetWindowHeight || Appearance.font.pixelSize.smaller * 4 > targetWindowWidth

    property bool indicateXWayland: windowData?.xwayland ?? false
    
    x: initX
    y: initY
    width: Math.min((windowData?.size[0] ?? 100) * root.scale, availableWorkspaceWidth)
    height: Math.min((windowData?.size[1] ?? 100) * root.scale, availableWorkspaceHeight)
    opacity: (windowData?.monitor ?? -1) == widgetMonitorId ? 1 : 0.4

    layer.enabled: true
    layer.smooth: true
    layer.mipmap: true

    Behavior on x {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on y {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on width {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on height {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    Rectangle {
        id: clipContainer
        anchors.fill: parent
        radius: Appearance.rounding.windowRounding * root.scale
        clip: true
        color: "transparent"

        ScreencopyView {
            id: windowPreview
            anchors.fill: parent
            captureSource: GlobalStates.overviewOpen ? root.toplevel : null
            live: true

            Rectangle {
                anchors.fill: parent
                radius: Appearance.rounding.windowRounding * root.scale
                color: pressed ? ColorUtils.transparentize(Appearance.colors.colLayer2Active, 0.5) : 
                    hovered ? ColorUtils.transparentize(Appearance.colors.colLayer2Hover, 0.7) : 
                    ColorUtils.transparentize(Appearance.colors.colLayer2)
                border.color : ColorUtils.transparentize(Appearance.m3colors.m3outline, 0.7)
                border.width : 1
            }

        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.font.pixelSize.smaller * 0.5

            Image {
                id: windowIcon
                property var iconSize: {
                    return Math.min(targetWindowWidth, targetWindowHeight) * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio) / (root.monitorData?.scale ?? 1);
                }
                Layout.alignment: Qt.AlignHCenter
                source: root.iconPath
                width: iconSize
                height: iconSize
                sourceSize: Qt.size(iconSize, iconSize)

                Behavior on width {
                    animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                }
                Behavior on height {
                    animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
                }
            }
        }
    }
    }
}
