import Foundation
import SwiftUI
import CellGridView
import Utils

public final class LifeCellGridView: CellGridView
{
    internal private(set) var activeColor: Colour
    internal private(set) var inactiveColor: Colour
    internal private(set) var inactiveColorRandom: Bool
    internal private(set) var inactiveColorRandomDynamic: Bool
    internal private(set) var inactiveColorRandomPalette: ColourMode
    internal private(set) var inactiveColorRandomFilter: ColourFilter?
    internal private(set) var dragThreshold: Int
    internal private(set) var swipeThreshold: Int
    internal private(set) var soundEnabled: Bool
    internal private(set) var hapticEnabled: Bool
    internal private(set) var generationNumber: Int = 0
    internal private(set) var inactiveColorRandomNumber: Int = 0
    internal private(set) var inactiveColorRandomDynamicNumber: Int = 0
    private               var liveCells: Set<CellLocation> = []

    public init(_ config: LifeCellGridView.Config? = nil) {
        let config: LifeCellGridView.Config = config ?? LifeCellGridView.Config()
        self.activeColor                = config.activeColor
        self.inactiveColor              = config.inactiveColor
        self.inactiveColorRandom        = config.inactiveColorRandom
        self.inactiveColorRandomDynamic = config.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = config.inactiveColorRandomPalette
        self.inactiveColorRandomFilter  = config.inactiveColorRandomFilter
        self.dragThreshold              = config.dragThreshold
        self.swipeThreshold             = config.swipeThreshold
        self.soundEnabled               = config.soundEnabled
        self.hapticEnabled              = config.hapticEnabled
        super.init(config)
    }

    internal func initialize(_ settings: Settings, screen: Screen,
                                                   viewWidth: Int,
                                                   viewHeight: Int,
                                                   onChangeImage: (() -> Void)? = nil,
                                                   preferredFit: CellGridView.PreferredFit = CellGridView.PreferredFit.none,
                                                   center: Bool = false)
    {
        super.initialize(settings.toConfig(self),
                         screen: screen,
                         viewWidth: viewWidth,
                         viewHeight: viewHeight,
                         onChangeImage: onChangeImage,
                         preferredFit: preferredFit,
                         center: center)
    }

    internal func configure(_ settings: Settings) {
        self.activeColor = settings.activeColor
        self.inactiveColor = settings.inactiveColor
        self.inactiveColorRandom = settings.inactiveColorRandom
        self.inactiveColorRandomDynamic = settings.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = settings.inactiveColorRandomPalette
        self.inactiveColorRandomFilter = settings.inactiveColorRandomFilter
        self.inactiveColorRandomNumber += 1 // todo/hack
        self.inactiveColorRandomDynamicNumber += 1 // todo/hack
        super.configure(settings.toConfig(self), viewWidth: self.viewWidth, viewHeight: self.viewHeight)
    }

    internal func configure(_ config: LifeCellGridView.Config) {
        super.configure(config, viewWidth: self.viewWidth, viewHeight: self.viewHeight)
    }

    /*
    public override func configure(_ config: CellGridView.Config, viewWidth: Int, viewHeight: Int)
    {
        if let config: LifeCellGridView.Config = config as? LifeCellGridView.Config {
            super.configure(config, viewWidth: viewWidth, viewHeight: viewHeight)
        }
    }
    */

    public override var config: LifeCellGridView.Config {
        LifeCellGridView.Config(self)
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

    internal var inactiveColorRandomColor: () -> Colour {
        //
        // This returns a function that returns a random (inactive) color based on the current
        // color mode (color, grayscale, monochrome), inactive color, and inactive color filter.
        //
        let inactiveColorRandomColorFunction: () -> Colour = {
            Colour.random(mode: self.inactiveColorRandomPalette,
                          tint: self.inactiveColor,
                          tintBy: nil,
                          filter: self.inactiveColorRandomFilter)
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
        self.inactiveColorRandomDynamicNumber += 1

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
