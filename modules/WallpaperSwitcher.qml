import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../styles"
import "../state"

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: GlobalState.showWallpaperSwitcher ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: GlobalState.showWallpaperSwitcher

    readonly property string wallDir: "/home/vamsi/Pictures/Wallpapers/walls"
    property string selectedCategory: ""
    property string selectedTransition: "random"
    property string currentWallpaper: "" 
    property string activePreviewName: "" 

    property var transitions: ["grow", "wipe", "wave", "outer", "center", "random"]

    ListModel { id: categoryModel }
    ListModel { id: imageModel }

    Shortcut {
        sequence: "Escape"
        onActivated: GlobalState.showWallpaperSwitcher = false
        enabled: GlobalState.showWallpaperSwitcher
    }

    MouseArea {
        anchors.fill: parent
        onClicked: GlobalState.showWallpaperSwitcher = false
    }

    Process {
        id: loadCategoriesProcess
        command: ["sh", "-c", "find " + root.wallDir + " -mindepth 1 -maxdepth 1 -type d -exec basename {} \\; | sort"]
        stdout: SplitParser {
            onRead: data => {
                const cat = data.trim()
                if (cat !== "") {
                    categoryModel.append({ name: cat })
                    if (root.selectedCategory === "") root.selectedCategory = cat
                }
            }
        }
    }

    Process {
        id: loadImagesProcess
        stdout: SplitParser {
            onRead: data => {
                const img = data.trim()
                if (img !== "") {
                    const fullPath = "file://" + root.wallDir + "/" + root.selectedCategory + "/" + img
                    imageModel.append({ fileName: img, filePath: fullPath })
                }
            }
        }
    }

    Process { id: swwwProcess }

    Process {
        id: matugenProcess
        property string jsonBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                matugenProcess.jsonBuffer += data
            }
        }
        
        onExited: {
            try {
                const parsed = JSON.parse(matugenProcess.jsonBuffer)
                // NEW: Just hand the entire color object to the Theme! 
                // The declarative bindings in Theme.qml will do the rest instantly.
                Theme.palette = parsed.colors 
            } catch (e) {
                console.log("Matugen JSON Parse Error: " + e)
            }
            matugenProcess.jsonBuffer = "" 
        }
    }

    function setWallpaper(imageName) {
        if (!imageName || swwwProcess.running) return;

        root.currentWallpaper = imageName;
        const fullPath = root.wallDir + "/" + root.selectedCategory + "/" + imageName
        let activeTransition = root.selectedTransition;

        if (activeTransition === "random") {
            const validTransitions = ["grow", "wipe", "wave", "outer", "center"];
            activeTransition = validTransitions[Math.floor(Math.random() * validTransitions.length)];
        }
        
        swwwProcess.command = [
            "sh", "-c", 
            "awww img '" + fullPath + "' --transition-type " + activeTransition + " --transition-pos 0.5,0.5 --transition-fps 144 --transition-step 30"
        ]
        swwwProcess.running = true
        
        matugenProcess.command = [
            "sh", "-c", 
            "matugen image '" + fullPath + "' --dry-run -j hex --prefer saturation 2>&1"
        ]
        matugenProcess.running = true

        GlobalState.showWallpaperSwitcher = false
    }

    Connections {
        target: GlobalState
        function onShowWallpaperSwitcherChanged() {
            if (GlobalState.showWallpaperSwitcher) {
                if (categoryModel.count === 0) loadCategoriesProcess.running = true;
                Qt.callLater(function() { categoryList.forceActiveFocus(); });
            }
        }
    }

    onSelectedCategoryChanged: {
        imageModel.clear()
        if (selectedCategory !== "") {
            loadImagesProcess.command = [
                "sh", "-c", 
                "ls -1 '" + root.wallDir + "/" + root.selectedCategory + "' | grep -iE '\\.(png|jpe?g|gif|webp|bmp)$' | sort"
            ]
            loadImagesProcess.running = true
            imageGrid.currentIndex = 0
            root.activePreviewName = ""
        }
    }

    Rectangle {
        width: 1180
        height: 750
        anchors.centerIn: parent
        radius: Theme.radius
        color: Theme.background
        border.color: Theme.border
        border.width: 1

        MouseArea { anchors.fill: parent }

        Row {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Rectangle {
                width: 220
                height: parent.height
                color: Theme.surface
                radius: Theme.radius
                border.color: Theme.border
                border.width: 1
                clip: true

                ListView {
                    id: categoryList
                    anchors.fill: parent
                    anchors.margins: 10
                    model: categoryModel
                    spacing: 6
                    focus: true 

                    KeyNavigation.right: imageGrid
                    Keys.onTabPressed: imageGrid.forceActiveFocus()
                    Keys.onReturnPressed: imageGrid.forceActiveFocus()
                    Keys.onEnterPressed: imageGrid.forceActiveFocus()

                    onCurrentIndexChanged: {
                        if (activeFocus && count > 0) root.selectedCategory = model.get(currentIndex).name
                    }

                    delegate: Rectangle {
                        width: parent.width
                        height: 42
                        radius: 10
                        color: (root.selectedCategory === model.name || (categoryList.activeFocus && categoryList.currentIndex === index))
                               ? Theme.primary : (catHover.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent")

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            text: model.name
                            // Changed #111111 to Theme.background so it inverts cleanly
                            color: (root.selectedCategory === model.name || (categoryList.activeFocus && categoryList.currentIndex === index)) ? Theme.background : Theme.text
                            font.pixelSize: 14
                            font.bold: root.selectedCategory === model.name
                        }

                        MouseArea {
                            id: catHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedCategory = model.name
                                categoryList.currentIndex = index
                                imageGrid.forceActiveFocus() 
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width - 240
                height: parent.height

                Row {
                    id: headerRow
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40
                    spacing: 20

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.selectedCategory.charAt(0).toUpperCase() + root.selectedCategory.slice(1)
                        color: Theme.text
                        font.pixelSize: 28
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.activePreviewName !== "" ? "—  " + root.activePreviewName : ""
                        color: Theme.textDim
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        width: 250 
                    }

                    Item { width: headerRow.width - parent.children[0].width - parent.children[1].width - transitionButtons.width - 40; height: 1 }

                    Row {
                        id: transitionButtons
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Repeater {
                            model: root.transitions
                            delegate: Rectangle {
                                width: transText.implicitWidth + 24
                                height: 32
                                radius: 16
                                color: root.selectedTransition === modelData ? Theme.primary : Theme.surface
                                border.color: Theme.border
                                border.width: 1

                                Text {
                                    id: transText
                                    anchors.centerIn: parent
                                    text: modelData
                                    // Changed #111111 to Theme.background
                                    color: root.selectedTransition === modelData ? Theme.background : Theme.textDim
                                    font.pixelSize: 12
                                    font.bold: root.selectedTransition === modelData
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectedTransition = modelData
                                }
                            }
                        }
                    }
                }

                GridView {
                    id: imageGrid
                    anchors.top: headerRow.bottom
                    anchors.topMargin: 20
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    model: imageModel
                    cellWidth: 260
                    cellHeight: 180
                    clip: true
                    
                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < imageModel.count) {
                            root.activePreviewName = imageModel.get(currentIndex).fileName
                        }
                    }

                    Keys.onTabPressed: categoryList.forceActiveFocus()
                    Keys.onLeftPressed: (event) => {
                        let cols = Math.floor(width / cellWidth);
                        if (currentIndex % cols === 0) {
                            categoryList.forceActiveFocus();
                            event.accepted = true;
                        } else {
                            event.accepted = false; 
                        }
                    }
                    Keys.onReturnPressed: applyCurrent()
                    Keys.onEnterPressed: applyCurrent()
                    Keys.onSpacePressed: applyCurrent()

                    function applyCurrent() {
                        if (currentIndex >= 0 && currentIndex < imageModel.count) {
                            root.setWallpaper(imageModel.get(currentIndex).fileName)
                        }
                    }

                    delegate: Item {
                        width: 240
                        height: 160
                        property bool isHighlighted: imgHover.containsMouse || (imageGrid.activeFocus && GridView.isCurrentItem)
                        z: isHighlighted ? 10 : 1

                        Rectangle {
                            anchors.fill: parent
                            radius: 14
                            color: Theme.surface
                            scale: parent.isHighlighted ? 1.05 : 1.0
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                            
                            border.color: (root.currentWallpaper === model.fileName) 
                                          ? Theme.secondary : (parent.isHighlighted ? Theme.primary : Theme.border)
                            border.width: (root.currentWallpaper === model.fileName || parent.isHighlighted) ? 3 : 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            Image {
                                anchors.fill: parent
                                source: model.filePath
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true 
                                cache: true
                            }

                            MouseArea {
                                id: imgHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    imageGrid.currentIndex = index
                                    imageGrid.forceActiveFocus()
                                    root.setWallpaper(model.fileName)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}