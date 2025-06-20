import Foundation
import SwiftUI
import CellGridView
import Utils

public final class LifeCellGridView: CellGridView
{
    private var _activeColor: Colour = LifeGame.Defaults.activeColor
    private var _inactiveColor: Colour = LifeGame.Defaults.inactiveColor
    private var _inactiveColorRandom: Bool = LifeGame.Defaults.inactiveColorRandom
    private var _inactiveColorRandomDynamic: Bool = LifeGame.Defaults.inactiveColorRandomDynamic
    private var _inactiveColorRandomColorMode: ColourMode =  LifeGame.Defaults.inactiveColorRandomColorMode
    private var _inactiveColorRandomColorFilter: ColourFilter? = LifeGame.Defaults.inactiveColorRandomColorFilter
    private var _inactiveColorRandomNumber: Int = 0
    private var _generationNumber: Int = 0
    private var _liveCells: Set<CellLocation> = []

    public override func createCell<T: Cell>(x: Int, y: Int, color: Colour) -> T? {
        return LifeCell(cellGridView: self, x: x, y: y) as? T
    }

    public override func automationStep() {
        self.nextGeneration()
        if (self.inactiveColorRandomDynamic) {
            self.writeCells()
        }
        self.onChangeImage()
    }

    internal var activeColor: Colour {
        get { self._activeColor }
        set {
            if (newValue != self._activeColor) {
                self._activeColor = newValue
                for cellLocation in self._liveCells {
                    if let cell: LifeCell = self.gridCell(cellLocation.x, cellLocation.y) {
                        cell.write()
                    }
                }
            }
        }
    }

    internal var inactiveColor: Colour {
        get { self._inactiveColor }
        set {
            if (newValue != self._inactiveColor) {
                self._inactiveColor = newValue
                self._inactiveColorRandomNumber += 2
                self._generationNumber += 2
                super.writeCells()
            }
        }
    }

    internal var inactiveColorRandomColorMode: ColourMode {
        get { self._inactiveColorRandomColorMode }
        set {
            if (newValue != self._inactiveColorRandomColorMode) {
                self._inactiveColorRandomColorMode = newValue
                self._inactiveColorRandomNumber += 2
                self._generationNumber += 2
                super.writeCells()
            }
        }
    }

    internal var inactiveColorRandom: Bool {
        get { self._inactiveColorRandom }
        set {
            if (newValue != self._inactiveColorRandom) {
                self._inactiveColorRandom = newValue
                super.writeCells()
            }
        }
    }

    internal var inactiveColorRandomDynamic: Bool {
        get { self._inactiveColorRandomDynamic }
        set {
            if (newValue != self._inactiveColorRandomDynamic) {
                self._inactiveColorRandomDynamic = newValue
                super.writeCells()
            }
        }
    }

    internal var inactiveColorRandomColor: () -> Colour {
        let inactiveColorRandomColorFunction: () -> Colour = {
            var color: Colour = Colour.random(mode: self._inactiveColorRandomColorMode,
                                              tint: self._inactiveColor,
                                              tintBy: nil,
                                              filter: self._inactiveColorRandomColorFilter)
            return color
        }
        return inactiveColorRandomColorFunction
    }

    internal var inactiveColorRandomNumber: Int {
        self._inactiveColorRandomNumber
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

    internal func erase() {
        for cellLocation in self._liveCells {
            if let cell: LifeCell = super.gridCell(cellLocation) {
                cell.deactivate()
            }
        }
        self.onChangeImage()
    }

    private func nextGeneration()
    {
        self._generationNumber += 1
        print("GN: \(self._generationNumber)")

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
