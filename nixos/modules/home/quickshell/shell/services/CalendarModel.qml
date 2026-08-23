import Quickshell
import QtQuick

// Calendar data is derived from Quickshell's minute-resolution system clock;
// there is no shell-owned polling timer.
Item {
  id: root

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  readonly property date now: clock.date
  property int displayedYear: clock.date.getFullYear()
  property int displayedMonth: clock.date.getMonth()

  readonly property string monthTitle: {
    const date = new Date(root.displayedYear, root.displayedMonth, 1)
    return Qt.formatDateTime(date, "MMMM yyyy")
  }

  readonly property var days: {
    const first = new Date(root.displayedYear, root.displayedMonth, 1)
    const start = first.getDay()
    const count = new Date(root.displayedYear, root.displayedMonth + 1, 0).getDate()
    const today = root.now
    const todayKey = today.getFullYear() + "-" + today.getMonth() + "-" + today.getDate()
    const result = []

    for (let index = 0; index < 42; index++) {
      const day = index - start + 1
      const inMonth = day > 0 && day <= count
      const date = new Date(root.displayedYear, root.displayedMonth, day)
      const key = date.getFullYear() + "-" + date.getMonth() + "-" + date.getDate()
      result.push({
        number: inMonth ? day : "",
        inMonth: inMonth,
        today: inMonth && key === todayKey,
      })
    }
    return result
  }

  function showPreviousMonth() {
    if (root.displayedMonth === 0) {
      root.displayedMonth = 11
      root.displayedYear--
    } else {
      root.displayedMonth--
    }
  }

  function showNextMonth() {
    if (root.displayedMonth === 11) {
      root.displayedMonth = 0
      root.displayedYear++
    } else {
      root.displayedMonth++
    }
  }

  function showCurrentMonth() {
    root.displayedYear = root.now.getFullYear()
    root.displayedMonth = root.now.getMonth()
  }
}
