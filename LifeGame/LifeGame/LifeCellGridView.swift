import Foundation
import SwiftUI
import CellGridView
import Utils

public final class LifeCellGridView: CellGridView
{
    private var _cellActiveColor: Colour = LifeGame.Defaults.activeColor
    private var _cellInactiveColor: Colour = LifeGame.Defaults.inactiveColor
    private var _liveCells: Set<CellLocation> = []
    private var _generationNumber: Int = 0
    private var _cellInactiveColorRandom: Bool = LifeGame.Defaults.inactiveColorRandom
    private var _cellInactiveColorRandomDynamic: Bool = LifeGame.Defaults.inactiveColorRandomDynamic
    private var _cellInactiveColorRandomColorMode: ColourMode? =  LifeGame.Defaults.inactiveColorRandomColorMode
    private var _cellInactiveColorRandomColorFilter: ColourFilter? = LifeGame.Defaults.inactiveColorRandomColorFilter
    private var _cellInactiveColorRandomNumber: Int = 0

    public override func createCell<T: Cell>(x: Int, y: Int, color: Colour) -> T? {
        return LifeCell(cellGridView: self, x: x, y: y) as? T
    }

    public override func automationStep() {
        self._generationNumber += 1
        self.nextGeneration()
        super.writeCells()
        self.onChangeImage()
    }

    internal var cellActiveColor: Colour {
        get { self._cellActiveColor }
        set {
            if (newValue != self._cellActiveColor) {
                self._cellActiveColor = newValue
                for cellLocation in self._liveCells {
                    if let cell: LifeCell = self.gridCell(cellLocation.x, cellLocation.y) {
                        cell.write()
                    }
                }
                super.writeCells()
            }
        }
    }

    internal var cellInactiveColor: Colour {
        get { self._cellInactiveColor }
        set { self._cellInactiveColor = newValue }
    }

    internal var cellInactiveColorRandom: Bool {
        self._cellInactiveColorRandom
    }

    internal var cellInactiveColorRandomColor: () -> Colour {
        let cellInactiveColorRandomColorFunction: () -> Colour = { Colour.random(filter: self._cellInactiveColorRandomColorFilter) }
        return cellInactiveColorRandomColorFunction
    }

    internal var cellInactiveColorRandomNumber: Int {
        self._cellInactiveColorRandomNumber
    }

    internal var cellInactiveColorRandomDynamic: Bool {
        self._cellInactiveColorRandomDynamic
    }

    internal func noteCellActivated(_ cell: LifeCell) {
        self._liveCells.insert(cell.location)
    }

    internal func noteCellDeactivated(_ cell: LifeCell) {
        self._liveCells.remove(cell.location)
    }

    internal var generationNumber: Int {
        self._generationNumber
    }

    private func nextGeneration()
    {
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
                if ((count == 2) || (count == 3)) {
                    newLiveCells.insert(cellLocation)
                }
            } else {
                //
                // Birth rule.
                //
                if (count == 3) {
                    newLiveCells.insert(cellLocation)
                }
            }
        }

        // Update the underlying grid and cell colors;
        // deactivate cells that die; activate new live cells.

        for oldLocation in self._liveCells.subtracting(newLiveCells) {
            if let cell: LifeCell = self.gridCell(oldLocation.x, oldLocation.y) {
                cell.deactivate(nonotify: true)
            }
        }

        for newLocation in newLiveCells.subtracting(self._liveCells) {
            if let cell: LifeCell = self.gridCell(newLocation.x, newLocation.y) {
                cell.activate(nonotify: true)
            }
        }

        self._liveCells = newLiveCells
    }
}
