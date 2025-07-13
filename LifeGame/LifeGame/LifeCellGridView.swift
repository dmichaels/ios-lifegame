import Foundation
import SwiftUI
import CellGridView
import Utils

public final class LifeCellGridView: CellGridView
{
    internal private(set) var gameMode: GameMode
    internal private(set) var activeColor: Colour
    internal private(set) var inactiveColor: Colour
    internal private(set) var inactiveColorRandom: Bool
    internal private(set) var inactiveColorRandomDynamic: Bool
    internal private(set) var inactiveColorRandomPalette: ColourPalette
    internal private(set) var inactiveColorRandomFilter: ColourFilter?
    internal private(set) var dragThreshold: Int
    internal private(set) var swipeThreshold: Int
    internal private(set) var soundsEnabled: Bool
    internal private(set) var hapticsEnabled: Bool
    internal private(set) var generationNumber: Int = 0
    internal private(set) var inactiveColorRandomNumber: Int = 0
    internal private(set) var inactiveColorRandomDynamicNumber: Int = 0
    private               var activeCells: Set<CellLocation> = []
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
    internal private(set) var variantOverPopulate: Bool
    //
    // In the InactiveFade variant of Conway's Life, an inactive cell will
    // be colored in a faded fashion depending on its "age" as defined by
    // how long it has been inactive (up to variantInactiveFadeAgeMax).
    //
    internal private(set) var variantInactiveFade: Bool
    internal private(set) var variantInactiveFadeAgeMax: Int
    private               var variantInactiveFadeCells: Set<CellLocation> = []
    internal private(set) var variantLatixOcclude: Bool
    internal              var latixCells: [LatixCell] = []
    internal private(set) var selectModeFat: Bool
    internal private(set) var selectModeExtraFat: Bool
    internal private(set) var automationRandom: Bool
    internal private(set) var automationRandomInterval: Double
    private               var automationRandomTimer: Timer?

    public init(_ config: LifeCellGridView.Config? = nil) {
        let config: LifeCellGridView.Config = config ?? LifeCellGridView.Config()
        self.gameMode                   = config.gameMode
        self.activeColor                = config.activeColor
        self.inactiveColor              = config.inactiveColor
        self.inactiveColorRandom        = config.inactiveColorRandom
        self.inactiveColorRandomDynamic = config.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = config.inactiveColorRandomPalette
        self.inactiveColorRandomFilter  = config.inactiveColorRandomFilter
        self.variantHighLife            = config.variantHighLife
        self.variantOverPopulate        = config.variantOverPopulate
        self.variantInactiveFade        = config.variantInactiveFade
        self.variantInactiveFadeAgeMax  = config.variantInactiveFadeAgeMax
        self.variantLatixOcclude        = config.variantLatixOcclude
        self.selectModeFat              = config.selectModeFat
        self.selectModeExtraFat         = config.selectModeExtraFat
        self.automationRandom       = config.automationRandom
        self.automationRandomInterval   = config.automationRandomInterval
        self.automationRandomTimer      = nil
        self.dragThreshold              = config.dragThreshold
        self.swipeThreshold             = config.swipeThreshold
        self.soundsEnabled              = config.soundsEnabled
        self.hapticsEnabled             = config.hapticsEnabled
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
        self.gameMode = settings.gameMode
        self.activeColor = settings.activeColor
        self.inactiveColor = settings.inactiveColor
        self.inactiveColorRandom = settings.inactiveColorRandom
        self.inactiveColorRandomDynamic = settings.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = settings.inactiveColorRandomPalette
        self.inactiveColorRandomFilter = settings.inactiveColorRandomFilter
        self.variantHighLife = settings.variantHighLife
        self.variantOverPopulate = settings.variantOverPopulate
        self.variantInactiveFade = settings.variantInactiveFade
        self.variantInactiveFadeAgeMax = settings.variantInactiveFadeAgeMax
        self.variantLatixOcclude = settings.variantLatixOcclude
        self.selectModeFat = settings.selectModeFat
        self.selectModeExtraFat = settings.selectModeExtraFat
        self.automationRandom = settings.automationRandom
        self.automationRandomInterval = settings.automationRandomInterval
        self.soundsEnabled = settings.soundsEnabled
        self.hapticsEnabled = settings.hapticsEnabled
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

    public override func createCell<T: Cell>(x: Int, y: Int, color: Colour) -> T? {
        let cell: LifeCell = LifeCell(cellGridView: self, x: x, y: y, color: color)
        if (config.gameMode == GameMode.life) {
            if (self.activeCells.contains(cell.location)) {
                cell.activate(nowrite: true, nonotify: true)
            }
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
                          filter: self.inactiveColorRandomFilter)
        }
        return inactiveColorRandomColorFunction
    }

    internal func noteCellActivated(_ cell: LifeCell) {
        self.activeCells.insert(cell.location)
        self.variantInactiveFadeCells.remove(cell.location)
    }

    internal func noteCellDeactivated(_ cell: LifeCell) {
        self.activeCells.remove(cell.location)
    }

    internal func erase() {
        if (self.gameMode == GameMode.latix) {
            self.latixErase()
            return
        }
        for cellLocation in self.activeCells {
            if let cell: LifeCell = super.gridCell(cellLocation) {
                cell.deactivate()
            }
        }
        for cellLocation in self.variantInactiveFadeCells {
            if let cell: LifeCell = super.gridCell(cellLocation) {
                cell._inactiveGenerationNumber = nil
                cell.write()
            }
        }
        self.onChangeImage()
    }

    private func nextGeneration()
    {
        if (self.gameMode == GameMode.latix) {
            self.latixNextGeneration()
            return
        }

        self.generationNumber += 1
        self.inactiveColorRandomDynamicNumber += 1

        var neighbors: [CellLocation: Int] = [:]

        // Count neighbors for all live cells and their neighbors.

        for cellLocation in self.activeCells {
            //
            // This loops through the cells that are currently active, collecting
            // the neighbors of each, and the neighbor counts of each/all of these.
            //
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

        var newActiveCells: Set<CellLocation> = []

        // Determine which cells survive, die, or are born in the next generation.

        for (cellLocation, count) in neighbors {
            let isAlive = self.activeCells.contains(cellLocation)
            if (isAlive) {
                //
                // Survival rules; i.e. cells that were active and are to remain active.
                //
                if ((count == 2) || (count == 3)) {
                    newActiveCells.insert(cellLocation)
                }
                else if (self.variantOverPopulate && (count > 3)) {
                    newActiveCells.insert(cellLocation)
                }
            }
            else {
                //
                // Birth rule; i.e. cells that were inactive but are to become active;
                // note that death rule falls out as we a populating a new set of live cells.
                //
                if (count == 3) {
                    newActiveCells.insert(cellLocation)
                }
                else if (self.variantHighLife && (count == 6)) {
                    newActiveCells.insert(cellLocation)
                }
            }
        }

        if (self.variantInactiveFade) {
            //
            // For the InactiveFade variant, inactive cell colors fade out depending on their age
            // as defined by how long they have been inactive; see LifeCell.color for more details.
            //
            for cellLocation in self.variantInactiveFadeCells {
                if let cell: LifeCell = self.gridCell(cellLocation.x, cellLocation.y) {
                    if (cell.inactiveAge > self.variantInactiveFadeAgeMax) {
                        cell._inactiveGenerationNumber = nil
                        self.variantInactiveFadeCells.remove(cellLocation)
                    }
                    cell.write()
                }
            }
        }

        for oldLocation in self.activeCells.subtracting(newActiveCells) {
            //
            // This loops through the cells that WERE active but
            // with this generation are now INACTIVE; i.e. death rule.
            //
            if let cell: LifeCell = self.gridCell(oldLocation.x, oldLocation.y) {
                cell.deactivate(nowrite: true, nonotify: true)
                self.variantInactiveFadeCells.insert(oldLocation)
                cell._inactiveGenerationNumber = self.generationNumber - 1
                cell.write()
            }
        }

        for newLocation in newActiveCells.subtracting(self.activeCells) {
            //
            // This loops through the cells that WERE inactive but
            // with this generation are now ACTIVE; i.e. birth rule.
            //
            if let cell: LifeCell = self.gridCell(newLocation.x, newLocation.y) {
                cell.activate(nonotify: true)
            }
        }

        self.activeCells = newActiveCells
    }

    private func latixNextGeneration()
    {
        self.generationNumber += 1
        for latixCell in self.latixCells {
            latixCell.expand()
        }
    }

    internal func latixErase() {
        self.latixCells.removeAll(keepingCapacity: true)
        for cell in self.cells {
            cell.write(color: self.inactiveColor)
        }
    }

    internal func latixCellSelect(_ lifeCell: LifeCell) {
        latixCells.append(LatixCell.select(lifeCell))
    }

    internal func latixCellDeselect(_ cell: LatixCell) {
        if let index: Int = self.latixCells.firstIndex(where: { $0 === cell }) {
            self.latixCells.remove(at: index)
        }
    }

    internal func latixNewerCells(age: Int) -> [LatixCell] {
        var newerLatixCells: [LatixCell] = []
        for latixCell in self.latixCells {
            if (latixCell.age < age) {
                newerLatixCells.append(latixCell)
            }
        }
        return newerLatixCells
    }

    internal func automationRandomToggle() {
        self.automationRandom ? automationRandomStop() : self.automationRandomStart()
    }

    internal func automationRandomStart() {
        self.automationRandom = true
        self.automationRandomTimer = Timer.scheduledTimer(withTimeInterval: self.automationRandomInterval,
                                                          repeats: true) { _ in
            self.selectRandom()
        }
    }

    internal func automationRandomStop() {
        self.automationRandom = false
        if let automationRandomTimer = self.automationRandomTimer {
            automationRandomTimer.invalidate()
            self.automationRandomTimer = nil
        }
    }
}
