import Foundation
import CellGridView

public final class LifeCellGridView: CellGridView
{
    private var _liveCells: Set<CellLocation> = []

    public override func createCell<T: Cell>(x: Int, y: Int, foreground: CellColor) -> T? {
        return LifeCell(cellGridView: self, x: x, y: y, foreground: foreground) as? T
    }

    public override func onLongTap(_ viewPoint: CGPoint) {
        if (self.gridCellLocation(viewPoint: viewPoint) != nil) {
            self.automationToggle()
        }
    }

    public override func automationStep() {
        self.nextGeneration()
        self.updateImage()
    }

    internal func noteCellActivated(_ cell: LifeCell) {
        self._liveCells.insert(cell.location)
    }

    internal func noteCellDeactivated(_ cell: LifeCell) {
        self._liveCells.remove(cell.location)
    }

    private func nextGeneration()
    {
        #if targetEnvironment(simulator)
            let debugStart = Date()
        #endif

        var neighborCount: [CellLocation: Int] = [:]

        // Count neighbors for all live cells and their neighbors.

        for cellLocation in self._liveCells {
            for dy in -1...1 {
                for dx in -1...1 {
                    if dx == 0 && dy == 0 { continue }
                    let neighborX = (cellLocation.x + dx + self.gridColumns) % self.gridColumns
                    let neighborY = (cellLocation.y + dy + self.gridRows) % self.gridRows
                    let neighborLocation = CellLocation(neighborX, neighborY)
                    neighborCount[neighborLocation, default: 0] += 1
                }
            }
        }

        var newLiveCells: Set<CellLocation> = []

        // Determine which cells live in the next generation.

        for (cellLocation, count) in neighborCount {
            let isAlive = self._liveCells.contains(cellLocation)
            if (isAlive) {
                //
                // Survival rules.
                //
                if count == 2 || count == 3 {
                    newLiveCells.insert(cellLocation)
                }
            } else {
                //
                // Birth rule.
                //
                if count == 3 {
                    newLiveCells.insert(cellLocation)
                }
            }
        }

        // Update the underlying grid and cell colors;
        // deactivate cells that die; activate new live cells.

        for oldLocation in self._liveCells.subtracting(newLiveCells) {
            if let cell: LifeCell = self.gridCell(oldLocation.x, oldLocation.y) {
                cell.deactivate()
            }
        }

        for newLocation in newLiveCells.subtracting(self._liveCells) {
            if let cell: LifeCell = self.gridCell(newLocation.x, newLocation.y) {
                cell.activate()
            }
        }

        self._liveCells = newLiveCells

        #if targetEnvironment(simulator)
            self.printNextGenerationResult(debugStart)
        #endif
    }

    private func printNextGenerationResult(_ start: Date) {
        let interval: TimeInterval = Date().timeIntervalSince(start)
        let ms = interval * 1000
        print(String(format: "NEXTG> %.4f ms", ms))
    }
}
