import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation

    // Игровые переменные
    property var symbols: ["🍒", "🍋", "🔔", "⭐", "7️⃣", "💎"]
    property var reels: ["🍒", "🍋", "🔔"]
    property int credits: 200
    property int bet: 10
    property bool spinning: false
    property string result: ""
    property bool gameOver: false

    // Размерные единицы, основанные на минимальном размере
    property real unit: Math.min(Plasmoid.width, Plasmoid.height) / 30
    property real padding: unit * 1.5
    property real spacing: unit

    // Таймеры
    Timer {
        id: spinTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: {
            reels = [
                symbols[Math.floor(Math.random() * symbols.length)],
                symbols[Math.floor(Math.random() * symbols.length)],
                symbols[Math.floor(Math.random() * symbols.length)]
            ]
        }
    }

    Timer {
        id: stopTimer
        interval: 1500
        running: false
        onTriggered: {
            spinTimer.stop()
            spinning = false
            checkWin()
            if (credits <= 0) gameOver = true
        }
    }

    fullRepresentation: Item {
        id: container

        // Основной фон
        Rectangle {
            anchors.fill: parent
            color: "#0f172a"
            radius: unit

            // Акцентная полоска сверху
            Rectangle {
                width: parent.width
                height: Math.max(2, unit * 0.25)
                color: "#fbbf24"
                anchors.top: parent.top
                anchors.topMargin: unit
            }
        }

        // Основной контент с адаптивными отступами
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: padding
            spacing: spacing

            // Заголовок
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🎰 CASINO SLOTS 🎰"
                color: "#fbbf24"
                font.pixelSize: Math.max(12, unit * 1.2)
                font.bold: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                Layout.maximumWidth: parent.width - padding * 2
            }

            // Барабаны с адаптивным размером
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: unit * 8

                Rectangle {
                    anchors.fill: parent
                    color: "#1e293b"
                    radius: unit * 0.75
                    border.width: Math.max(1, unit * 0.15)
                    border.color: spinning ? "#fbbf24" : "#334155"

                    Row {
                        anchors.centerIn: parent
                        spacing: spacing

                        Repeater {
                            model: 3

                            Rectangle {
                                width: Math.min(parent.parent.width / 3.5, unit * 5)
                                height: width
                                radius: unit * 0.6
                                color: "#0f172a"
                                border.width: Math.max(2, unit * 0.25)
                                border.color: spinning ? "#fbbf24" : "#475569"

                                Text {
                                    anchors.centerIn: parent
                                    text: reels[index]
                                    font.pixelSize: parent.width * 0.45
                                    color: "white"
                                }
                            }
                        }
                    }
                }
            }

            // Информация о игре - адаптивная сетка
            GridLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: unit * 6
                columns: width > unit * 20 ? 2 : 1
                columnSpacing: spacing
                rowSpacing: spacing * 0.5

                // Кредиты
                Column {
                    spacing: unit * 0.25
                    Layout.fillWidth: true

                    Text {
                        text: "BALANCE"
                        color: "#94a3b8"
                        font.pixelSize: Math.max(9, unit * 0.7)
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "$" + credits
                        color: credits > 100 ? "#10b981" : credits > 50 ? "#fbbf24" : "#ef4444"
                        font.pixelSize: Math.max(14, unit * 1.3)
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }

                // Ставка
                Column {
                    spacing: unit * 0.25
                    Layout.fillWidth: true

                    Text {
                        text: "CURRENT BET"
                        color: "#94a3b8"
                        font.pixelSize: Math.max(9, unit * 0.7)
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "$" + bet
                        color: "#fbbf24"
                        font.pixelSize: Math.max(14, unit * 1.3)
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }

                // Статус - растягиваем на 2 колонки если мало места
                Column {
                    spacing: unit * 0.25
                    Layout.fillWidth: true
                    Layout.columnSpan: parent.columns

                    Text {
                        text: "STATUS"
                        color: "#94a3b8"
                        font.pixelSize: Math.max(9, unit * 0.7)
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: spinning ? "SPINNING..." :
                        gameOver ? "GAME OVER" : "READY"
                        color: spinning ? "#8b5cf6" :
                        gameOver ? "#ef4444" : "#10b981"
                        font.pixelSize: Math.max(11, unit * 1)
                        font.bold: true
                        width: parent.width
                        elide: Text.ElideRight
                    }
                }
            }

            // Управление ставкой - адаптивное
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: unit * 3.5

                RowLayout {
                    anchors.fill: parent
                    spacing: spacing * 0.5

                    // Уменьшить
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: unit * 0.4
                        color: bet > 1 && !spinning && !gameOver ? "#ef4444" : "#475569"

                        Text {
                            anchors.centerIn: parent
                            text: "−5"
                            color: "white"
                            font.pixelSize: Math.max(11, parent.height * 0.4)
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: bet > 1 && !spinning && !gameOver
                            onClicked: {
                                if (bet > 5) {
                                    bet -= 5;
                                } else if (bet > 1) {
                                    bet = 1;
                                }
                            }
                        }
                    }

                    // Отображение ставки
                    Text {
                        text: "BET: $" + bet
                        color: "#fbbf24"
                        font.pixelSize: Math.max(12, unit * 1)
                        font.bold: true
                        Layout.alignment: Qt.AlignVCenter
                        Layout.minimumWidth: unit * 5
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Увеличить
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: unit * 0.4
                        color: bet < Math.min(credits, 100) && !spinning && !gameOver ? "#10b981" : "#475569"

                        Text {
                            anchors.centerIn: parent
                            text: "+5"
                            color: "white"
                            font.pixelSize: Math.max(11, parent.height * 0.4)
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: bet < Math.min(credits, 100) && !spinning && !gameOver
                            onClicked: {
                                var maxBet = Math.min(credits, 100);
                                if (bet < maxBet) {
                                    bet = Math.min(maxBet, bet + 5);
                                }
                            }
                        }
                    }

                    // MAX
                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: unit * 4
                        radius: unit * 0.4
                        color: credits > 0 && !spinning && !gameOver ? "#8b5cf6" : "#475569"

                        Text {
                            anchors.centerIn: parent
                            text: "MAX"
                            color: "white"
                            font.pixelSize: Math.max(10, parent.height * 0.35)
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: credits > 0 && !spinning && !gameOver
                            onClicked: bet = Math.min(credits, 1000)
                        }
                    }
                }
            }

            // Кнопка SPIN/RESTART - адаптивная
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: unit * 3
                radius: unit * 0.6
                color: {
                    if (spinning) return "#8b5cf6";
                    if (gameOver) return "#3b82f6";
                    if (credits >= bet) return "#dc2626";
                    return "#475569";
                }

                Text {
                    anchors.centerIn: parent
                    text: spinning ? "🌀 SPINNING..." :
                    gameOver ? "🔄 RESTART GAME" :
                    "🎰 SPIN ($" + bet + ")"
                    color: "white"
                    font.pixelSize: Math.max(12, parent.height * 0.35)
                    font.bold: true
                    width: parent.width * 0.9
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: (gameOver) || (!spinning && credits >= bet)
                    onClicked: {
                        if (gameOver) {
                            credits = 200
                            bet = 10
                            gameOver = false
                            result = ""
                            reels = ["🍒", "🍋", "🔔"]
                        } else {
                            startSpin()
                        }
                    }
                }
            }

            // Результат - адаптивный
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: unit * 2.5
                color: "#1e293b"
                radius: unit * 0.5
                border.width: Math.max(1, unit * 0.1)
                border.color: result.includes("JACKPOT") ? "#fbbf24" :
                result.includes("WIN") ? "#10b981" :
                result.includes("MATCH") ? "#3b82f6" :
                gameOver ? "#ef4444" : "#334155"

                Text {
                    anchors.centerIn: parent
                    text: result || (gameOver ? "💀 GAME OVER" : "")
                    color: {
                        if (gameOver) return "#ef4444";
                        if (result.includes("JACKPOT")) return "#fbbf24";
                        if (result.includes("WIN")) return "#10b981";
                        if (result.includes("MATCH")) return "#3b82f6";
                        return "#94a3b8";
                    }
                    font.pixelSize: Math.max(10, parent.height * 0.3)
                    font.bold: true
                    width: parent.width * 0.9
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Сообщение о GAME OVER - адаптивное
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: unit * 2
                color: "#ef444420"
                radius: unit * 0.4
                border.width: Math.max(1, unit * 0.05)
                border.color: "#ef444460"
                visible: gameOver && credits <= 0

                Text {
                    anchors.centerIn: parent
                    text: "💸 Out of credits! Click RESTART above"
                    color: "#fca5a5"
                    font.pixelSize: Math.max(9, parent.height * 0.25)
                    font.bold: true
                    width: parent.width * 0.9
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    // Функция старта вращения
    function startSpin() {
        if (spinning || credits < bet) return

            credits -= bet
            spinning = true
            result = ""

            spinTimer.start()
            stopTimer.start()
    }

    // Проверка выигрыша
    function checkWin() {
        // Джекпот
        if (reels[0] === "7️⃣" && reels[1] === "7️⃣" && reels[2] === "7️⃣") {
            var jackpot = bet * 50
            credits += jackpot
            result = "🎉 JACKPOT! +$" + jackpot
        }
        // Три одинаковых
        else if (reels[0] === reels[1] && reels[1] === reels[2]) {
            var win = bet * 10
            credits += win
            result = "💰 BIG WIN! +$" + win
        }
        // Два одинаковых
        else if (reels[0] === reels[1] || reels[1] === reels[2] || reels[0] === reels[2]) {
            var smallWin = bet * 3
            credits += smallWin
            result = "⭐ MATCH! +$" + smallWin
        }
        // Проигрыш
        else {
            result = "😢 Try again!"
        }
    }
}
