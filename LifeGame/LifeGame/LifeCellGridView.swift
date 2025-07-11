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
    internal private(set) var variantLatix: Bool = false
    internal              var latixCells: [LatixCell] = []
    internal private(set) var selectModeFat: Bool
    internal private(set) var selectModeExtraFat: Bool

    public init(_ config: LifeCellGridView.Config? = nil) {
        let config: LifeCellGridView.Config = config ?? LifeCellGridView.Config()
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
        self.variantLatix               = config.variantLatix
        self.selectModeFat              = config.selectModeFat
        self.selectModeExtraFat         = config.selectModeExtraFat
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
        self.variantLatix = settings.variantLatix
        self.selectModeFat = settings.selectModeFat
        self.selectModeExtraFat = settings.selectModeExtraFat
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
        self.variantInactiveFadeCells.remove(cell.location)
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
        if (self.variantLatix) {
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

    internal func latixCellSelect(_ lifeCell: LifeCell) {
        latixCells.append(LatixCell.select(lifeCell))
    }

    internal func latixCellDeselect(_ cell: LatixCell) {
        if let index: Int = self.latixCells.firstIndex(where: { $0 === cell }) {
            self.latixCells.remove(at: index)
        }
    }
}

internal class LatixCell: Equatable {

    private let _cellGridView: LifeCellGridView
    private let _x: Int
    private let _y: Int
    private let _color: Colour
    private var _radius: Int
    private var _radiusMax: Int

    internal init(_ cell: LifeCell, color: Colour, radius: Int) {
        self._cellGridView = cell.cellGridView
        self._color = color
        self._x = cell.x
        self._y = cell.y
        self._radius = radius
        self._radiusMax = LatixCell.edgeDistance(cell.x, cell.y, ncolumns: self._cellGridView.gridColumns,
                                                                 nrows: self._cellGridView.gridRows)
    }

    internal var x: Int { return self._x }
    internal var y: Int { return self._y }

    internal static func select(_ lifeCell: LifeCell) -> LatixCell {
        let color: Colour = LatixCell.nextColor()
        let cell: LatixCell = LatixCell(lifeCell, color: color, radius: 1)
        lifeCell.color = color
        lifeCell.write()
        return cell
    }

    internal func expand() {
        guard self._radius <= self._radiusMax else {
            self._cellGridView.latixCellDeselect(self)
            return
        }
        self._radius += 1
        let perimeterCellLocations: [CellLocation] = LatixCell.circleCellLocations(
            center: self.x, self.y,
            radius: self._radius
        )
        for perimeterCellLocation in perimeterCellLocations {
            if let lifeCell: LifeCell = self._cellGridView.gridCell(perimeterCellLocation.x, perimeterCellLocation.y) {
                lifeCell.color = Colour.random(tint: self._color, tintBy: 0.5)
                lifeCell.write()
            }
        }
    }

    // Returns the list of cell locations for a circle centered a the given (cx,cy) cell location, and with
    // the given cell radius (a radius of one means just the given cell). If the filled argument is false
    // then returns cell locations only for the perimeter of the enclosing circle, otherwise returns the
    // cell locations for the whole of the circle. Since the circle is obviously approximate, the threshold
    // argument gives some control over how conservative we are; a higher number means more conservative,
    // i.e. more strict in allowing cells to be considered part of the circle.  N.B. Mostly ChatGPT generated.
    //
    private static func circleCellLocations(center cx: Int, _ cy: Int, radius r: Int,
                                            filled: Bool = false, threshold: Float = 1.0) -> [CellLocation]
    {
        guard r > 0 else { return [] }
        guard r > 1 else { return [CellLocation(cx, cy)] }
        guard r > 2 else { return [CellLocation(cx, cy), CellLocation(cx - 1, cy), CellLocation(cx + 1, cy),
                                                         CellLocation(cx, cy - 1), CellLocation(cx, cy + 1)] }

        struct cache { static var locations: [Int: [CellLocation]] = [:] }
        let radius: Int = r - 1

        if let cached = cache.locations[radius] {
            return cached.map { CellLocation($0.x + cx, $0.y + cy) }
        }

        var cells: [CellLocation] = []
        let rsq: Float = Float(radius) * Float(radius)
        let cxf: Float = Float(0.5)
        let cyf: Float = Float(0.5)
        for y in -radius...radius {
            for x in -radius...radius {
                let points: [(Float, Float)] = [
                    (Float(x) + 0.5, Float(y) + 0.5), // center
                    (Float(x),       Float(y)),       // top-left
                    (Float(x) + 1.0, Float(y)),       // top-right
                    (Float(x),       Float(y) + 1.0), // bottom-left
                    (Float(x) + 1.0, Float(y) + 1.0)  // bottom-right
                ]
                let insideCount: Float = points.reduce(0) { count, point in
                    let dx: Float = point.0 - cxf
                    let dy: Float = point.1 - cyf
                    return ((dx * dx + dy * dy) <= rsq) ? count + 1 : count
                }
                if (insideCount >= threshold) {
                    if (filled) {
                        cells.append(CellLocation(x, y))
                    } else {
                        let neighborOffsets: [(Int,Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
                        for (dx, dy) in neighborOffsets {
                            let nx: Int = x + dx
                            let ny: Int = y + dy
                            let neighborPoints: [(Float, Float)] = [
                                (Float(nx) + 0.5, Float(ny) + 0.5),
                                (Float(nx),       Float(ny)),
                                (Float(nx) + 1.0, Float(ny)),
                                (Float(nx),       Float(ny) + 1.0),
                                (Float(nx) + 1.0, Float(ny) + 1.0)
                            ]
                            let neighborInside: Float = neighborPoints.reduce(0) { count, point in
                                let dx: Float = point.0 - cxf
                                let dy: Float = point.1 - cyf
                                return ((dx * dx + dy * dy) <= rsq) ? count + 1 : count
                            }
                            if (neighborInside < 3.0) {
                                cells.append(CellLocation(x, y))
                                break
                            }
                        }
                    }
                }
            }
        }
        cache.locations[radius] = cells
        return cells.map { CellLocation($0.x + cx, $0.y + cy) }
    }

    private static func nextColor() -> Colour {
        struct cache {
            static var index: Int = 0
            static var colors: [Colour] = [Colour.red, Colour.green, Colour.blue, Colour.yellow, Colour.brown]
        }
        let color: Colour = cache.colors[cache.index]
        cache.index = cache.index < cache.colors.count - 1 ? cache.index + 1 : 0
        return color
    }

    private static func edgeDistance(_ x: Int, _ y: Int, ncolumns: Int, nrows: Int) -> Int {
        let corners = [
            (0, 0),
            (ncolumns - 1, 0),
            (0, nrows - 1),
            (ncolumns - 1, nrows - 1)
        ]
        return Int(ceil(corners.map { (cx, cy) in
            let dx = Float(cx - x)
            let dy = Float(cy - y)
            return sqrt(dx * dx + dy * dy)
        }.max() ?? 0.0))
    }

    static func == (lhs: LatixCell, rhs: LatixCell) -> Bool {
        return lhs === rhs
    }
}
