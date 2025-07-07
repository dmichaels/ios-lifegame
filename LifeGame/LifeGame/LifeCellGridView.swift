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
    internal private(set) var inactiveColorRandomPalette: ColourPalette
    internal private(set) var inactiveColorRandomFilter: ColourFilter?
    internal private(set) var dragThreshold: Int
    internal private(set) var swipeThreshold: Int
    internal private(set) var soundEnabled: Bool
    internal private(set) var hapticEnabled: Bool
    internal private(set) var generationNumber: Int = 0
    internal private(set) var inactiveColorRandomNumber: Int = 0
    internal private(set) var inactiveColorRandomDynamicNumber: Int = 0
    //
    // In the HighLife variant of Conway's Life, an inactive cell also becomes
    // active if it has exactly six active neighbors, in addition to the normal
    // rule of being actived if it has exactly three active neighbors.
    //
    internal private(set) var variantHighLife: Bool
    //
    // In the Overpoplate variant of Conway's Life, an active cell which would
    // otherwise be deactivated due to overpopulation, i.e. because it had more
    // than three active neighbors, is allowed to survive (i.e. remains active).
    //
    internal private(set) var variantOverpopulate: Bool
    internal private(set) var variantInactiveFade: Bool
    private               var activeCells: Set<CellLocation> = []
    private               var recentInactiveCells: Set<CellLocation> = []
    internal private(set) var recentInactiveCellsMax: Int = 4

    public init(_ config: LifeCellGridView.Config? = nil) {
        let config: LifeCellGridView.Config = config ?? LifeCellGridView.Config()
        self.activeColor                = config.activeColor
        self.inactiveColor              = config.inactiveColor
        self.inactiveColorRandom        = config.inactiveColorRandom
        self.inactiveColorRandomDynamic = config.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = config.inactiveColorRandomPalette
        self.inactiveColorRandomFilter  = config.inactiveColorRandomFilter
        self.variantHighLife            = config.variantHighLife
        self.variantOverpopulate        = config.variantOverpopulate
        self.variantInactiveFade        = config.variantInactiveFade
        self.dragThreshold              = config.dragThreshold
        self.swipeThreshold             = config.swipeThreshold
        self.soundEnabled               = config.soundEnabled
        self.hapticEnabled              = config.hapticEnabled
        super.init(config)
    }

    internal func initialize(_ settings: Settings,
                               screen: Screen,
                               viewWidth: Int,
                               viewHeight: Int,
                               onChangeImage: (() -> Void)? = nil)
    {
        super.initialize(settings.toConfig(self),
                         screen: screen,
                         viewWidth: viewWidth,
                         viewHeight: viewHeight,
                         onChangeImage: onChangeImage)
    }

    internal func configure(_ settings: Settings) {
        self.activeColor = settings.activeColor
        self.inactiveColor = settings.inactiveColor
        self.inactiveColorRandom = settings.inactiveColorRandom
        self.inactiveColorRandomDynamic = settings.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = settings.inactiveColorRandomPalette
        self.inactiveColorRandomFilter = settings.inactiveColorRandomFilter
        self.variantHighLife = settings.variantHighLife
        self.variantOverpopulate = settings.variantOverpopulate
        self.variantInactiveFade = settings.variantInactiveFade
        self.inactiveColorRandomNumber += 2
        self.inactiveColorRandomDynamicNumber += 2
        super.configure(settings.toConfig(self), viewWidth: self.viewWidth, viewHeight: self.viewHeight)
    }

    internal func configure(_ config: LifeCellGridView.Config) {
        super.configure(config, viewWidth: self.viewWidth, viewHeight: self.viewHeight)
    }

    public override var config: LifeCellGridView.Config {
        LifeCellGridView.Config(self)
    }

    public override func createCell<T: Cell>(x: Int, y: Int, color ignore: Colour) -> T? {
        let cell: LifeCell = LifeCell(cellGridView: self, x: x, y: y) // as? T
        if (self.activeCells.contains(cell.location)) {
            cell.activate(nowrite: true, nonotify: true)
        }
        return cell as? T
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
        self.activeCells.insert(cell.location)
        self.recentInactiveCells.remove(cell.location)
    }

    internal func noteCellDeactivated(_ cell: LifeCell) {
        self.activeCells.remove(cell.location)
    }

    internal func erase() {
        for cellLocation in self.activeCells {
            if let cell: LifeCell = super.gridCell(cellLocation) {
                cell.deactivate()
            }
        }
        for cellLocation in self.recentInactiveCells {
            if let cell: LifeCell = super.gridCell(cellLocation) {
                cell._inactiveGenerationNumber = nil
                cell.write()
            }
        }
        self.onChangeImage()
    }

    private func nextGeneration()
    {
        print("NEXTGEN: \(self.generationNumber) -> \(self.generationNumber + 1)")
        self.generationNumber += 1
        self.inactiveColorRandomDynamicNumber += 1

        var neighbors: [CellLocation: Int] = [:]

        // Count neighbors for all live cells and their neighbors.

        for cellLocation in self.activeCells {
            for dy in -1...1 {
                for dx in -1...1 {
                    if ((dx == 0) && (dy == 0)) { continue }
                    let neighborLocation = CellLocation(
                        (cellLocation.x + dx + self.gridColumns) % self.gridColumns,
                        (cellLocation.y + dy + self.gridRows)    % self.gridRows
                    )
                    neighbors[neighborLocation, default: 0] += 1
                }
            }
        }

        var newLiveCells: Set<CellLocation> = []

        // Determine which cells live in the next generation.

        for (cellLocation, count) in neighbors {
            let isAlive = self.activeCells.contains(cellLocation)
            if (isAlive) {
                //
                // Survival rules.
                //
                if ((count == 2) || (count == 3)) {
                    newLiveCells.insert(cellLocation)
                }
                else if (self.variantOverpopulate && (count > 3)) {
                    newLiveCells.insert(cellLocation)
                }
            }
            else {
                //
                // Birth rule.
                // Death rule falls out as we a populating a new set of live cells.
                //
                if (count == 3) {
                    newLiveCells.insert(cellLocation)
                }
                else if (self.variantHighLife && (count == 6)) {
                    newLiveCells.insert(cellLocation)
                }
            }
        }

        if (self.variantInactiveFade) {
            for cellLocation in self.recentInactiveCells {
                if let cell: LifeCell = self.gridCell(cellLocation.x, cellLocation.y) {
                    if (cell.inactiveAge > self.recentInactiveCellsMax) {
                        cell._inactiveGenerationNumber = nil
                        self.recentInactiveCells.remove(cellLocation)
                    }
                    cell.write()
                }
            }
        }

        // Update the underlying grid and cell colors;
        // deactivate cells that die; activate new live cells.

        for oldLocation in self.activeCells.subtracting(newLiveCells) {
            if let cell: LifeCell = self.gridCell(oldLocation.x, oldLocation.y) {
                cell.deactivate(nonotify: true)
                self.recentInactiveCells.insert(oldLocation)
                cell._inactiveGenerationNumber = self.generationNumber - 1
                cell.write() // TODO
            }
        }

        for newLocation in newLiveCells.subtracting(self.activeCells) {
            if let cell: LifeCell = self.gridCell(newLocation.x, newLocation.y) {
                cell.activate(nonotify: true)
            }
        }

        self.activeCells = newLiveCells

        for location in self.recentInactiveCells {
            if let cell: LifeCell = self.gridCell(location.x, location.y) {
                // print("RIC: \(location) \(cell._inactiveGenerationNumber) [\(self.generationNumber)]")
            }
        }
    }
}
