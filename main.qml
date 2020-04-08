import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.14

Window {
    id: mainWindow
    visible: true
    width: 910
    height: 400
    title: "Jars Puzzle"

    readonly property var levels: [
        [[5, 3], 4],
        [[3, 13, 7], 11],
        [[7, 23, 11], 13]
    ]
    property int level

    // Puzzle settings:
    property var jarCapacity
    property int goal
    readonly property int minCapacity: Math.min(...jarCapacity)
    readonly property int maxCapacity: Math.max(...jarCapacity)

    // State variables: (is defined with two steps)
    // Action:
    // - step 1: pick source
    // - step 2: pick target
    // Source is stored here: (-1 => step 1)
    property int source: -1
    // State of jars:
    property var jarState

    Column {
        Row {
            Faucet {
                enabled: canClick(-100)
                onItemClicked: mainWindow.itemClicked(-100)
            }
            Repeater {
                model: jarCapacity.length
                delegate: Jar {
                    content: jarState[index]
                    capacity: jarCapacity[index]
                    enabled: canClick(index)
                    scale: 0.66 + 0.34 * (capacity - minCapacity) / (maxCapacity - minCapacity)
                    onItemClicked: mainWindow.itemClicked(index)
                }
            }
            Sink {
                enabled: canClick(-200)
                onItemClicked: mainWindow.itemClicked(-200)
            }
        }
        Item {
            width: 5
            height: 10
        }
        Rectangle {
            color: "black"
            width: mainWindow.width
            height: 1
        }
        Item {
            width: 5
            height: 10
            visible: !checkWin()
            Text {
                anchors.top: parent.bottom
                width: mainWindow.width
                horizontalAlignment: Text.AlignHCenter
                text: "Goal: " + goal
                font.pixelSize: 35
            }
        }
        Rectangle {
            width: mainWindow.width
            height: 64
            visible: checkWin()
            color: "#eee"
            Text {
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "SUCCESS!"
                font.pixelSize: 40
                font.bold: true
            }
            Text {
                visible: (level + 1) < levels.length
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                text: "Next level"
                font.pixelSize: 30
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: setLevel(level + 1)
                }
            }
        }
    }

    function setLevel(i) {
        jarState = new Array(levels[i][0].length).fill(0)
        jarCapacity = levels[i][0]
        goal = levels[i][1]
        level = i
    }

    function itemClicked(i) {
        if(source === -1) {
            source = i
        }
        else {
            doAction(source, i)
            source = -1
        }
    }

    function isJar(i) {
        return i >= 0
    }

    function isFaucet(i) {
        return i === -100
    }

    function isSink(i) {
        return i === -200
    }

    function allFull() {
        for(var i in jarState)
            if(jarState[i] < jarCapacity[i])
                return false
        return true
    }

    function canClick(i) {
        if(source == -1)
            return (isFaucet(i) && !allFull()) || jarState[i] > 0
        else
            return (isSink(i) && !isFaucet(source)) || (jarState[i] < jarCapacity[i] && source !== i)
    }

    function doAction(source, target) {
        if(isFaucet(source) && isJar(target)) {
            jarState[target] = jarCapacity[target]
        }
        else if(isJar(source) && isSink(target)) {
            jarState[source] = 0
        }
        else if(isJar(source) && isJar(target)) {
            var moved = Math.min(jarState[source], jarCapacity[target] - jarState[target])
            jarState[source] -= moved
            jarState[target] += moved
        }
        else {
            console.log("invalid move:", source, target)
            return
        }
        jarState = jarState.slice()
    }

    function checkWin() {
        for(var s of jarState)
            if(s === goal)
                return true
        return false
    }

    Component.onCompleted: setLevel(0)
}
