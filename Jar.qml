import QtQuick 2.0
import QtGraphicalEffects 1.12

Column {
    id: root
    property bool enabled: true
    property int content: 0
    property int capacity: 10
    signal itemClicked()

    //Behavior on content { NumberAnimation {} }

    onContentChanged: mask.t = content / capacity

    Item {
        id: jarItem
        width: imageEmpty.implicitWidth
        height: imageEmpty.implicitHeight

        Image {
            id: imageEmpty
            source: "jar-empty.svg"
            smooth: true
            visible: true
        }

        Image {
            id: imageFull
            source: "jar-full.svg"
            smooth: true
            visible: false
            anchors.fill: parent
        }

        Canvas {
            id: mask
            property real t: 0
            Behavior on t { NumberAnimation {} }
            onTChanged: requestPaint()
            readonly property real kMin: 0.19423004191827958
            readonly property real kMax: 0.8024589260097033
            readonly property real k: kMin + t * (kMax - kMin)
            anchors.fill: parent
            onPaint: {
                var ctx = getContext('2d')
                ctx.reset()
                ctx.fillStyle = '#f0f'
                ctx.fillRect(0, (1 - k) * height, width, k * height)
            }
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: imageFull
            maskSource: mask
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
            opacity: root.enabled ? 0 : 0.5
        }

        MouseArea {
            anchors.fill: parent
            onClicked: if(root.enabled) root.itemClicked()
            cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.NoArrow
        }
    }

    Text {
        width: jarItem.width
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 40
        font.bold: true
        text: content + "/" + capacity
    }
}
