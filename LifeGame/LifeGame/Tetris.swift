import Foundation
import CellGridView
import Utils

public enum Rotation {
    case degrees_90
    case degrees_180
    case degrees_270
}

public class Tetromino {

    private let _locations: [CellLocation]
    private let _width: Int
    private let _height: Int

    public init(_ locations: [CellLocation]) {
        self._locations = locations
        self._width = (locations.map { $0.x }.max() ?? 0) + 1
        self._height = (locations.map { $0.y }.max() ?? 0) + 1
    }

    public var locations: [CellLocation] { return self._locations }
    public var width: Int                { return self._width }
    public var height: Int               { return self._height }

    public func rotated(by rotation: Rotation = .degrees_90) -> Tetromino {
        let rotatedLocations: [CellLocation] = self._locations.map { location in
            switch rotation {
            case .degrees_90:
                return CellLocation(location.y, -location.x)
            case .degrees_180:
                return CellLocation(-location.x, -location.y)
            case .degrees_270:
                return CellLocation(-location.y, location.x)
            }
        }
        let minx = rotatedLocations.map { $0.x }.min() ?? 0
        let miny = rotatedLocations.map { $0.y }.min() ?? 0
        let normalized = rotatedLocations.map {
            CellLocation($0.x - minx, $0.y - miny)
        }
        return Tetromino(normalized)
    }

    internal func minus(_ tetromino: Tetromino?) -> [CellLocation] {
        return (tetromino != nil) ? self.minusLocations(tetromino!.locations) : self.locations
    }

    internal func minusLocations(_ locations: [CellLocation]) -> [CellLocation] {
        var result: [CellLocation] = []
        for selfLocation in self._locations {
            var skip: Bool = false
            for location in locations {
                if (location == selfLocation) {
                    skip = true
                    break
                }
            }
            if (!skip) {
                result.append(selfLocation)
            }
        }
        return result
    }

    public static let O: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢▢
        CellLocation(1, 0), // ▢▢
        CellLocation(0, 1), //
        CellLocation(1, 1)  //
    ])

    public static let I: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢
        CellLocation(0, 1), // ▢
        CellLocation(0, 2), // ▢
        CellLocation(0, 3)  // ▢
    ])

    public static let S: Tetromino = Tetromino(
    [
        CellLocation(1, 0), //  ▢▢
        CellLocation(2, 0), // ▢▢
        CellLocation(0, 1), //
        CellLocation(1, 1)  //
    ])

    public static let Z: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢▢
        CellLocation(1, 0), //  ▢▢
        CellLocation(1, 1), //
        CellLocation(2, 1)  //
    ])

    public static let L: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢
        CellLocation(0, 1), // ▢
        CellLocation(0, 2), // ▢▢
        CellLocation(1, 2)  //
    ])

    public static let J: Tetromino = Tetromino(
    [
        CellLocation(1, 0), //  ▢
        CellLocation(1, 1), //  ▢
        CellLocation(0, 2), // ▢▢
        CellLocation(1, 2)  //
    ])

    public static let T: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢▢▢
        CellLocation(1, 0), //  ▢
        CellLocation(2, 0), //
        CellLocation(1, 1)  //
    ])
}

public class TetrisBlock
{
    private var _locations: [CellLocation]
    private var _color: Colour
    private var _cellGridView: LifeCellGridView

    public init(_ tetromino: Tetromino, at cell: LifeCell, color: Colour, rotation: Rotation? = nil) {
        self._locations = []
        for location in TetrisBlock.rotateLocations(tetromino.locations, by: rotation) {
            self._locations.append(CellLocation(cell.x + location.x, cell.y + location.y))
        }
        self._color = color
        self._cellGridView = cell.cellGridView
    }

    public func rotate(by rotation: Rotation = Rotation.degrees_90) {
        self.transform(to: TetrisBlock.rotateLocations(self._locations, by: rotation))
    }

    public func move(offsetX: Int, offsetY: Int) {
        print("MOVE> \(offsetX),\(offsetY)")
        self.transform(to: TetrisBlock.moveLocations(self._locations, offsetX, offsetY))
    }

    // Writes all of the cells comprising this block with the default/defined color.
    //
    public func write() {
        self.write(color: self._color)
    }

    // Writes all of the cells comprising this block with the given color. If the minus
    // argument is given then ignore (do not write) any of the cell locations specified therein. 
    //
    private func write(color: Colour, minus: [CellLocation] = []) {
        for location in self._locations {
            var skip: Bool = false
            for minusLocation in minus {
                if ((minusLocation.x == location.x) && (minusLocation.y == location.y)) {
                    skip = true
                    break
                }
            }
            if (!skip) {
                if let cell: LifeCell = self._cellGridView.gridCell(location.x, location.y) {
                    cell.write(color: color)
                }
            }
        }
    }

    private func transform(to locationsNew: [CellLocation]) {
        print("XFORM> \(self._locations[0].x) -> \(locationsNew[0].x)")
        let locationsCurrent: [CellLocation] = self._locations
        //
        // Unwrite cells in this current block which are NOT also in the new/transformed block.
        //
        self.write(color: self._cellGridView.inactiveColor, minus: locationsNew)
        //
        // Write cells of the new/transformed block which were NOT also in this current/untransformed block.
        //
        self._locations = locationsNew
        self.write(color: self._color, minus: locationsCurrent)
    }

    public static func rotateLocations(_ locations: [CellLocation], by rotation: Rotation?) -> [CellLocation] {
        //
        // Full disclosure: ChatGPT inspired implementation.
        //
        if let rotation: Rotation = rotation, locations.count > 0 {
            let minx:   Int = locations.map { $0.x }.min()!
            let maxx:   Int = locations.map { $0.x }.max()!
            let miny:   Int = locations.map { $0.y }.min()!
            let maxy:   Int = locations.map { $0.y }.max()!
            let width:  Int = maxx - minx + 1
            let height: Int = maxy - miny + 1
            return locations.map { location in
                let dx: Int = location.x - minx
                let dy: Int = location.y - miny
                switch rotation {
                    case .degrees_90:  return CellLocation(minx + (height - 1 - dy), miny + dx)
                    case .degrees_180: return CellLocation(minx + (width - 1 - dx), miny + (height - 1 - dy))
                    case .degrees_270: return CellLocation(minx + dy, miny + (width - 1 - dx))
                }
            }
        }
        return locations
    }

    private static func moveLocations(_ locations: [CellLocation], _ offsetX: Int, _ offsetY: Int) -> [CellLocation] {
        return locations.map { CellLocation($0.x + offsetX, $0.y + offsetY) }
    }
}
