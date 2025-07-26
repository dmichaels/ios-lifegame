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
        print("TT: \(self._locations) w: \(self._width) h: \(self._height)")
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
        let minX = rotatedLocations.map { $0.x }.min() ?? 0
        let minY = rotatedLocations.map { $0.y }.min() ?? 0
        let normalized = rotatedLocations.map {
            CellLocation($0.x - minX, $0.y - minY)
        }
        return Tetromino(normalized)
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
    private let _tetromino: Tetromino
    private let _color: Colour
    private var _cell: Cell

    public init(_ tetromino: Tetromino, at cell: Cell, color: Colour, rotation: Rotation? = nil) {
        self._tetromino = rotation != nil ? tetromino.rotated(by: rotation!) : tetromino
        self._color = color
        self._cell = cell
    }

    public func move(_ location: CellLocation) {
        //
        // TODO
        //
    }

    public func rotate(by rotation: Rotation) {
        //
        // TODO
        //
    }

    public func write(_ cell: Cell) {
        for location in  self._tetromino.locations {
            let gridCellX: Int =  cell.x + location.x
            let gridCellY: Int =  cell.y + location.y
            if let cell: LifeCell = self._cell.cellGridView.gridCell(gridCellX, gridCellY) {
                cell.write(color: self._color)
            }
        }
    }
}
