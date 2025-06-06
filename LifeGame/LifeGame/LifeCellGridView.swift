import Foundation
import CellGridView

public final class LifeCellGridView: CellGridView
{
    public override func createCell<T: Cell>(x: Int, y: Int, foreground: CellColor) -> T? {
        return LifeCell(cellGridView: self, x: x, y: y, foreground: foreground) as? T
    }

    public override func automationStep() {
        self.nextGeneration()
        self.updateImage()
    }

    private func nextGeneration() {
        #if targetEnvironment(simulator)
            let debugStart = Date()
        #endif
        var states: [[Bool]] = Array(repeating: Array(repeating: false, count: self.gridColumns), count: self.gridRows)
        for row in 0..<self.gridRows {
            for column in 0..<self.gridColumns {
                if let cell: LifeCell = self.gridCell(column, row) {
                    let liveNeighbors: Int = self.activeNeighbors(cell)
                    if cell.active {
                        states[row][column] = ((liveNeighbors == 2) || (liveNeighbors == 3))
                    } else {
                        states[row][column] = (liveNeighbors == 3)
                    }
                }
            }
        }
        for row in 0..<self.gridRows {
            for column in 0..<self.gridColumns {
                if let cell: LifeCell = self.gridCell(column, row) {
                    if (states[row][column]) {
                        cell.activate()
                    }
                    else {
                        cell.deactivate()
                    }
                }
            }
        }
        #if targetEnvironment(simulator)
            self.printNextGenerationResult(debugStart)
        #endif
    }

    private func activeNeighbors(_ cell: LifeCell) -> Int {
        var count = 0
        for dy in -1...1 {
            for dx in -1...1 {
                if ((dx == 0) && (dy == 0)) {
                    continue
                }
                let nx = (cell.x + dx + self.gridColumns) % self.gridColumns
                let ny = (cell.y + dy + self.gridRows) % self.gridRows
                if let cell: LifeCell = self.gridCell(nx, ny) {
                    if (cell.active) {
                        count += 1
                    }
                }
            }
        }
        return count
    }

    public override func onLongTap(_ viewPoint: CGPoint) {
        if (self.gridCellLocation(viewPoint: viewPoint) != nil) {
            self.automationToggle()
        }
    }

    private func printNextGenerationResult(_ start: Date) {
        let time: TimeInterval = Date().timeIntervalSince(start)
        print("NEXTG> \(time)")
    }
}
