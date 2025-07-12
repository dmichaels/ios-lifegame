import Foundation
import CellGridView
import Utils

public class LatixCell: Equatable {

    private let _cellGridView: LifeCellGridView
    private let _x: Int
    private let _y: Int
    private let _color: Colour
    private var _radius: Int
    private var _radiusMax: Int

    private init(_ cell: LifeCell, color: Colour, radius: Int) {
        self._cellGridView = cell.cellGridView
        self._x = cell.x
        self._y = cell.y
        self._color = color
        self._radius = radius
        self._radiusMax = LatixCell.edgeDistance(self._x, self._y, ncolumns: self._cellGridView.gridColumns,
                                                                   nrows: self._cellGridView.gridRows)
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
            center: self._x, self._y,
            radius: self._radius
        )
        for perimeterCellLocation in perimeterCellLocations {
            if let lifeCell: LifeCell = self._cellGridView.gridCell(perimeterCellLocation.x, perimeterCellLocation.y) {
                lifeCell.color = Colour.random(tint: self._color, tintBy: 0.75, lighten: 0.25)
                lifeCell.write()
            }
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
                    (fx + 0.5, fy + 0.5),
                    (fx,       fy),
                    (fx + 1.0, fy),
                    (fx,       fy + 1.0),
                    (fx + 1.0, fy + 1.0)
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

    internal static func circleCellLocationsPreload(radius: Int = 500) {
        DispatchQueue.global(qos: .background).async {
            for r in 3...radius {
                _ = LatixCell.circleCellLocations(center: 0, 0, radius: r)
            }
        }
    }

    private static func edgeDistance(_ x: Int, _ y: Int, ncolumns: Int, nrows: Int) -> Int {
        let corners: [(Int, Int)] = [
            (0, 0),
            (ncolumns - 1, 0),
            (0, nrows - 1),
            (ncolumns - 1, nrows - 1)
        ]
        return Int(ceil(corners.map { (cx, cy) in
            let fx: Float = Float(cx - x)
            let fy: Float = Float(cy - y)
            return sqrt(fx * fx + fy * fy)
        }.max() ?? 0.0))
    }

    private static func nextColor() -> Colour {
        struct cache {
            static var colors: [Colour] = [
                Colour.red, Colour.green, Colour.blue, Colour.yellow, Colour.purple,
                Colour.cyan, Colour.orange, Colour.magenta
            ]
            static var index: Int = 0
        }
        let color: Colour = cache.colors[cache.index]
        cache.index = cache.index < cache.colors.count - 1 ? cache.index + 1 : 0
        return color
    }

    public static func == (lhs: LatixCell, rhs: LatixCell) -> Bool {
        return lhs === rhs
    }
}
