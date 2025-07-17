import Foundation
import CellGridView
import Utils

public class LatixCell: Equatable {

    private let _cellGridView: LifeCellGridView
    private let _location: CellLocation
    private let _color: Colour
    private var _radius: Int
    private var _radiusMax: Int
    private var _ordinal: Int = 0
    private static var _count: Int = 0

    private init(_ cell: LifeCell, color: Colour, radius: Int) {
        LatixCell._count += 1
        self._ordinal = LatixCell._count
        self._cellGridView = cell.cellGridView
        self._location = cell.location
        self._color = color
        self._radius = radius
        //
        // Base the maximum radius on the set of visible cells in the grid-view.
        //
        if let viewCellLocation: ViewLocation = cell.cellGridView.viewCellLocation(gridCellX: cell.location.x,
                                                                                   gridCellY: cell.location.y) {
            self._radiusMax = LatixCell.edgeDistance(
                viewCellLocation.x, viewCellLocation.y,
                ncolumns: cell.cellGridView.viewCellEndX, nrows: cell.cellGridView.viewCellEndY)
        }
        else {
            //
            // This cell is outside of the grid-view; should not normally happen because we
            // only create a LatixCell in response to a select/tap on an actually visible cell.
            //
            self._radiusMax = 0
        }
    }

    internal var location: CellLocation {
        self._location
    }

    internal var age: Int {
        LatixCell._count - self._ordinal
    }

    public static func select(_ lifeCell: LifeCell) -> LatixCell {
        let color: Colour = LatixCell.nextColor()
        let cell: LatixCell = LatixCell(lifeCell, color: color, radius: 1)
        lifeCell.color = color
        lifeCell.write()
        return cell
    }

    public func expand() {
        guard self._radius <= self._radiusMax else {
            self._cellGridView.latixCellDeselect(self)
            return
        }
        self._radius += 1
        let perimeterCellLocations: [CellLocation] = LatixCell.circleCellLocations(
            center: self._location.x, self._location.y,
            radius: self._radius
        )
        var update: Bool = false
        for perimeterCellLocation in perimeterCellLocations {
            if let lifeCell: LifeCell = self._cellGridView.gridCell(perimeterCellLocation.x, perimeterCellLocation.y) {
                //
                // Optionally (variantLatixOcclude) prevent older cell expansions from overwriting newer ones,
                // so that the newer ones always appear visually "on top" of older ones, i.e. so that circles
                // occluded one another as one might normally, visually expect.
                //
                // Also note that, unlike the Life game mode, for Latix mode if a cell is not currently visible
                // we don't write the cell at all, for performance reasons; with Life we do write such a (not
                // visible) cell because it is important that the model (whether a cell is activated or not)
                // be updated; but for Latix, if it is not visible, then not that important - if the cell-size
                // resized smaller (increasing the number of visible cells), we will see blank cells.
                //
                var skip: Bool = !self._cellGridView.cellVisible(lifeCell.x, lifeCell.y)
                if (!skip && self._cellGridView.variantLatixOcclude) {
                    let newerLatixCells: [LatixCell] = self._cellGridView.latixNewerCells(age: self.age)
                    for newerLatixCell in newerLatixCells {
                        //
                        // If this cell (perimeterCellLocation/lifeCell), on the perimeter of the outermost radius
                        // of this (self) cell, is within the circle defined by the entirety of the newer/younger
                        // latix-cell (newerLatixCell) within this loop (i.e. the circle whose center is the
                        // latix-cell in this loop and its extent being defined by its current radius), then
                        // do not update this cell color, as this cell is occluded by the newer latix-cell.
                        //
                        if (LatixCell.pointWithinCircle(lifeCell.x, lifeCell.y,
                                                        circle: newerLatixCell._location.x, newerLatixCell._location.y,
                                                        radius: newerLatixCell._radius)) {
                            skip = true
                            break
                        }
                    }
                }
                if (!skip) {
                    lifeCell.write(color: Colour.random(tint: self._color, tintBy: 0.75, lighten: 0.25))
                    update = true
                }
            }
        }
        if (update) {
            self._cellGridView.updateImage()
        }
    }

    // Returns the list of cell locations for the perimeter of a circle centered a the given (cx,cy) cell location,
    // and with the given cell radius (a radius of one means just the given cell). Since the circle is approximate,
    // the threshold argument gives some control over how conservative we are; a higher number means more conservative,
    // i.e. more strict in allowing cells to be considered part of the circle. N.B. This was mostly ChatGPT generated.
    //
    private static func circleCellLocations(center cx: Int, _ cy: Int, radius r: Int,
                                            threshold: Float = 1.0) -> [CellLocation]
    {
        guard r > 0 else { return [] }
        guard r > 1 else { return [CellLocation(cx, cy)] }
        guard r > 2 else { return [CellLocation(cx, cy), CellLocation(cx - 1, cy), CellLocation(cx + 1, cy),
                                                         CellLocation(cx, cy - 1), CellLocation(cx, cy + 1)] }
        struct Cache {
            private static var _locations: [Int: [CellLocation]] = [:]
            private static let _queue = DispatchQueue(label: "circleCellLocations.queue")
            internal static var locations: [Int: [CellLocation]] {
                get { _queue.sync { _locations } }
                set { _queue.sync { _locations = newValue } }
            }
            internal static let neighbors: [(Float, Float)] = [
                (Float(-1), Float(0)), (Float(1), Float(0)), (Float(0), Float(-1)), (Float(0), Float(1))
            ]
        }

        let radius: Int = r - 1

        if let cached: [CellLocation] = Cache.locations[radius] {
            return cached.map { CellLocation($0.x + cx, $0.y + cy) }
        }

        let rsq: Float = Float(radius * radius)
        let cxf: Float = 0.5
        let cyf: Float = 0.5
        var cells: [CellLocation] = []

        for y in -radius...radius {
            let fy: Float = Float(y)
            for x in -radius...radius {
                let fx: Float = Float(x)
                let points: [(Float, Float)] = [
                    (fx + 0.5, fy + 0.5), // center
                    (fx,       fy),       // top-left
                    (fx + 1.0, fy),       // top-right
                    (fx,       fy + 1.0), // bottom-left
                    (fx + 1.0, fy + 1.0)  // bottom-right
                ]
                let inside: Float = points.reduce(0) { count, point in
                    let ix: Float = point.0 - cxf
                    let iy: Float = point.1 - cyf
                    return (ix * ix + iy * iy) <= rsq ? count + 1 : count
                }
                if (inside >= threshold) {
                    var outsideNeighbor: Bool = false
                    for (nx, ny) in Cache.neighbors {
                        let dx: Float = (fx + nx + 0.5) - cxf
                        let dy: Float = (fy + ny + 0.5) - cyf
                        if (dx * dx + dy * dy) > rsq {
                            outsideNeighbor = true
                            break
                        }
                    }
                    if (outsideNeighbor) {
                        cells.append(CellLocation(x, y))
                    }
                }
            }
        }
        Cache.locations[radius] = cells
        return cells.map { CellLocation($0.x + cx, $0.y + cy) }
    }

    private static func pointWithinCircle(_ x: Int, _ y: Int,
                                          circle cx: Int, _ cy: Int,
                                          radius r: Int, threshold: Float = 1.0) -> Bool {
        guard r > 0 else { return false }
        let radius = r - 1
        let rsq: Float = Float(radius * radius)
        let cxf: Float = Float(cx) + 0.5
        let cyf: Float = Float(cy) + 0.5
        let fx: Float = Float(x)
        let fy: Float = Float(y)
        let points: [(Float, Float)] = [
            (fx + 0.5, fy + 0.5), // center
            (fx,       fy),       // top-left
            (fx + 1.0, fy),       // top-right
            (fx,       fy + 1.0), // bottom-left
            (fx + 1.0, fy + 1.0)  // bottom-right
        ]
        let inside: Float = points.reduce(0) { count, point in
            let ix: Float = point.0 - cxf
            let iy: Float = point.1 - cyf
            return (ix * ix + iy * iy) <= rsq ? count + 1 : count
        }
        return inside >= threshold
    }

    internal static func circleCellLocationsPreload(radius: Int = 250) {
        DispatchQueue.global(qos: .background).async {
            for r in 3...radius {
                _ = LatixCell.circleCellLocations(center: 0, 0, radius: r)
            }
        }
    }

    private static func edgeDistance(_ x: Int, _ y: Int, ncolumns: Int, nrows: Int) -> Int {
        let corners: [(Int, Int)] = [(0, 0), (ncolumns - 1, 0), (0, nrows - 1), (ncolumns - 1, nrows - 1)]
        return Int(ceil(corners.map { (cx, cy) in
            let fx: Float = Float(cx - x)
            let fy: Float = Float(cy - y)
            return sqrt(fx * fx + fy * fy)
        }.max() ?? 0.0))
    }

    private static func nextColor() -> Colour {
        struct Cache {
            private static let _colors: [Colour] = [
                Colour.red,
                Colour.green,
                Colour.blue,
                Colour.yellow,
                Colour.purple,
                Colour.cyan,
                Colour.orange,
                Colour.magenta,
                Colour.black,
            ]
            internal static let colors : [Colour] = (
                Cache._colors +
                Cache._colors.map { $0.lighten(by: 0.4) } +
                Cache._colors.map { $0.lighten(by: 0.7) } +
                Cache._colors.map { $0.lighten(by: 0.4) } +
                Cache._colors +
                Cache._colors.map { $0.darken(by: 0.4) } +
                Cache._colors.map { $0.darken(by: 0.8) } +
                Cache._colors.map { $0.darken(by: 0.4) }
            )
            internal static var index: Int = 0
        }
        Cache.index = (Cache.index + 1) % Cache.colors.count
        //
        // Tried randomizing but results were too, well, unpredicable and
        // not always great; remember, random doesn't feel all that random.
        //
        return Cache.colors[Cache.index]
    }

    public static func == (lhs: LatixCell, rhs: LatixCell) -> Bool {
        return lhs === rhs
    }
}
