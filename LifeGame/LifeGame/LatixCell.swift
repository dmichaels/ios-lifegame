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
                lifeCell.color = Colour.random(tint: self._color, tintBy: 0.7, lighten: 0.2)
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
                                            threshold: Float = 1.0) -> [CellLocation]
    {
        guard r > 0 else { return [] }
        guard r > 1 else { return [CellLocation(cx, cy)] }
        guard r > 2 else { return [CellLocation(cx, cy), CellLocation(cx - 1, cy), CellLocation(cx + 1, cy),
                                                         CellLocation(cx, cy - 1), CellLocation(cx, cy + 1)] }
        struct Cache {
            private static var _locations: [Int: [CellLocation]] = [:]
            private static let _queue = DispatchQueue(label: "circleCellLocations.queue")
            static var locations: [Int: [CellLocation]] {
                get { _queue.sync { _locations } }
                set { _queue.sync { _locations = newValue } }
            }
        }

        let radius = r - 1

        if let cached = Cache.locations[radius] {
            return cached.map { CellLocation($0.x + cx, $0.y + cy) }
        }

        let rsq: Float = Float(radius * radius)
        let cxf: Float = 0.5
        let cyf: Float = 0.5
        var cells: [CellLocation] = []

        for y in -radius...radius {
            for x in -radius...radius {
                let samples: [(Float, Float)] = [
                    (Float(x) + 0.5, Float(y) + 0.5),
                    (Float(x),       Float(y)),
                    (Float(x) + 1.0, Float(y)),
                    (Float(x),       Float(y) + 1.0),
                    (Float(x) + 1.0, Float(y) + 1.0)
                ]
                let insideCount: Float = samples.reduce(0) { count, point in
                    let dx = point.0 - cxf
                    let dy = point.1 - cyf
                    return (dx * dx + dy * dy) <= rsq ? count + 1 : count
                }
                if insideCount >= threshold {
                    var hasOutsideNeighbor = false
                    for (dx, dy) in [(-1,0), (1,0), (0,-1), (0,1)] {
                        let nx: Float = Float(x + dx) + 0.5
                        let ny: Float = Float(y + dy) + 0.5
                        let ndx: Float = nx - cxf
                        let ndy: Float = ny - cyf
                        if (ndx * ndx + ndy * ndy) > rsq {
                            hasOutsideNeighbor = true
                            break
                        }
                    }
                    if hasOutsideNeighbor {
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

    public static func == (lhs: LatixCell, rhs: LatixCell) -> Bool {
        return lhs === rhs
    }
}
