import QtQuick 2.0

Image {
    id: root
    property bool enabled: true
    source: "faucet.svg"
    smooth: true
    opacity: enabled ? 1 : 0.5
    signal itemClicked()
    MouseArea {
        anchors.fill: parent
        onClicked: if(root.enabled) root.itemClicked()
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.NoArrow
    }
}
