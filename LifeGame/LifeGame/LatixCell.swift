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

    public init(_ cell: LifeCell, color: Colour, radius: Int) {
        self._cellGridView = cell.cellGridView
        self._color = color
        self._x = cell.x
        self._y = cell.y
        self._radius = radius
        self._radiusMax = LatixCell.edgeDistance(cell.x, cell.y, ncolumns: self._cellGridView.gridColumns,
                                                                 nrows: self._cellGridView.gridRows)
    }

    public var x: Int { return self._x }
    public var y: Int { return self._y }

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

    public static func == (lhs: LatixCell, rhs: LatixCell) -> Bool {
        return lhs === rhs
    }
}
