import QtQuick

import "../styles"

Rectangle {
    id: root

    default property alias content: container.data

    implicitHeight: 32
    radius: 999

    color: Theme.background

    border.color: Qt.rgba(
        1, 1, 1, 0.06
    )

    border.width: 1

    layer.enabled: true
    layer.smooth: true

    Item {
        id: container

        anchors.fill: parent
        anchors.margins: 8
    }
}