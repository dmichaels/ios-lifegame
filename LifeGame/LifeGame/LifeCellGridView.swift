import Foundation
import SwiftUI
import CellGridView
import Utils

public final class LifeCellGridView: CellGridView
{
    /*
    private var _activeColor: Colour = Colour.black
    private var _inactiveColor: Colour = Colour.white
    private var _inactiveColorRandom: Bool = false
    private var _inactiveColorRandomDynamic: Bool = false
    private var _inactiveColorRandomColorMode: ColourMode = ColourMode.color
    */

    public   internal(set) var activeColor: Colour
    public   internal(set) var inactiveColor: Colour
    public   private(set)  var inactiveColorRandom: Bool
    public   private(set)  var inactiveColorRandomDynamic: Bool
    public   private(set)  var inactiveColorRandomColorMode: ColourMode
    public   private(set)  var inactiveColorRandomColorFilter: ColourFilter?
    public   private(set)  var dragThreshold: Int
    public   private(set)  var swipeThreshold: Int
    public   private(set)  var soundEnabled: Bool
    public   private(set)  var hapticEnabled: Bool
    internal private(set)  var generationNumber: Int = 0
    internal private(set)  var inactiveColorRandomNumber: Int = 0
    private                var liveCells: Set<CellLocation> = []

    public override init(_ config: CellGridView.Config? = nil) {
        let config: LifeCellGridView.Config? = config as? LifeCellGridView.Config
        self.activeColor                    = config?.activeColor                    ?? Settings.Defaults.activeColor
        self.inactiveColor                  = config?.inactiveColor                  ?? Settings.Defaults.inactiveColor
        self.inactiveColorRandom            = config?.inactiveColorRandom            ?? Settings.Defaults.inactiveColorRandom
        self.inactiveColorRandomDynamic     = config?.inactiveColorRandomDynamic     ?? Settings.Defaults.inactiveColorRandomDynamic
        self.inactiveColorRandomColorMode   = config?.inactiveColorRandomColorMode   ?? Settings.Defaults.inactiveColorRandomColorMode
        self.inactiveColorRandomColorFilter = config?.inactiveColorRandomColorFilter ?? Settings.Defaults.inactiveColorRandomColorFilter
        self.dragThreshold                  = config?.dragThreshold                  ?? Settings.Defaults.dragThreshold
        self.swipeThreshold                 = config?.swipeThreshold                 ?? Settings.Defaults.swipeThreshold
        self.soundEnabled                   = config?.soundEnabled                   ?? Settings.Defaults.soundEnabled
        self.hapticEnabled                  = config?.hapticEnabled                  ?? Settings.Defaults.hapticEnabled
        super.init(config)
    }

    public override var config: LifeCellGridView.Config {
        LifeCellGridView.Config(self)
    }

    public override func initialize(_ config: CellGridView.Config)
    {
        self.configure(config)
    }

    public override func configure(_ config: CellGridView.Config)
    {
        if let config: LifeCellGridView.Config = config as? LifeCellGridView.Config {
            super.configure(config)
        }
    }

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

    internal func noteCellActiveColorChanged() {
        for cellLocation in self.liveCells {
            if let cell: LifeCell = self.gridCell(cellLocation.x, cellLocation.y) {
                cell.write()
            }
        }
    }

    internal func noteCellInactiveColorChanged() {
        self.inactiveColorRandomNumber += 2 // todo/hack
        self.generationNumber += 2 // todo/hack
        super.writeCells()
    }
/*
    internal var activeColor: Colour {
        get { self._activeColor }
        set {
            if (newValue != self._activeColor) {
                self._activeColor = newValue
                for cellLocation in self.liveCells {
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
                self.inactiveColorRandomNumber += 2
                self.generationNumber += 2
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

    internal var inactiveColorRandomColorMode: ColourMode {
        get { self._inactiveColorRandomColorMode }
        set {
            if (newValue != self._inactiveColorRandomColorMode) {
                self._inactiveColorRandomColorMode = newValue
                self.inactiveColorRandomNumber += 2
                self.generationNumber += 2
                super.writeCells()
            }
        }
    }
    */

    internal var inactiveColorRandomColor: () -> Colour {
        //
        // This returns a function that returns a random (inactive) color based on the current
        // color mode (color, grayscale, monochrome), inactive color, and inactive color filter.
        //
        let inactiveColorRandomColorFunction: () -> Colour = {
            Colour.random(mode: self.inactiveColorRandomColorMode,
                          tint: self.inactiveColor,
                          tintBy: nil,
                          filter: self.inactiveColorRandomColorFilter)
        }
        return inactiveColorRandomColorFunction
    }

    internal func noteCellActivated(_ cell: LifeCell) {
        self.liveCells.insert(cell.location)
    }

    internal func noteCellDeactivated(_ cell: LifeCell) {
        self.liveCells.remove(cell.location)
    }

    internal func erase() {
        for cellLocation in self.liveCells {
            if let cell: LifeCell = super.gridCell(cellLocation) {
                cell.deactivate()
            }
        }
        self.onChangeImage()
    }

    private func nextGeneration()
    {
        self.generationNumber += 1
        print("GN: \(self.generationNumber)")

        var neighborCount: [CellLocation: Int] = [:]

        // Count neighbors for all live cells and their neighbors.

        for cellLocation in self.liveCells {
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
            let isAlive = self.liveCells.contains(cellLocation)
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

        for oldLocation in self.liveCells.subtracting(newLiveCells) {
            if let cell: LifeCell = self.gridCell(oldLocation.x, oldLocation.y) {
                cell.deactivate(nonotify: true)
            }
        }

        for newLocation in newLiveCells.subtracting(self.liveCells) {
            if let cell: LifeCell = self.gridCell(newLocation.x, newLocation.y) {
                cell.activate(nonotify: true)
            }
        }

        self.liveCells = newLiveCells
    }
}
