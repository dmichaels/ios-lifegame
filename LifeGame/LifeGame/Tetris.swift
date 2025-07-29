import Foundation
import CellGridView
import Utils

internal class TetrisView {
    //
    // DEV: Temporary static container for common Tetris stuff.
    //
    internal static var blocks: [TetrisBlock] = []
    internal static var dragStartCellLocation: CellLocation? = nil
    internal static var dragLastCellLocation: CellLocation? = nil
    internal static var dragBlock: TetrisBlock? = nil

    public static func onCellSelect(_ cellGridView: CellGridView, _ cell: Cell, dragging: Bool?) {
        if (dragging != nil) {
            //
            // DEV: On tap/drag on a block, move it.
            //
            if (TetrisView.dragStartCellLocation == nil) {
                TetrisView.dragStartCellLocation = cell.location
                if let block: TetrisBlock = TetrisView.findBlock(cell.location) {
                    TetrisView.dragBlock = block
                    TetrisView.dragLastCellLocation = cell.location
                }
            }
            else if let dragLastCellLocation: CellLocation = TetrisView.dragLastCellLocation {
                let offsetX: Int = cell.x - dragLastCellLocation.x
                let offsetY: Int = cell.y - dragLastCellLocation.y
                TetrisView.dragBlock!.move(offsetX: offsetX, offsetY: offsetY, stepFrom: cell)
                TetrisView.dragLastCellLocation = dragging == true ? cell.location : nil
            }
            if (dragging == false) {
                TetrisView.dragStartCellLocation = nil
                TetrisView.dragLastCellLocation = nil
                TetrisView.dragBlock = nil
            }
        }
        else {
            //
            // DEV: On single tap on a block, rotate it.
            //
            if let block: TetrisBlock = TetrisView.findBlock(cell.location) {
                block.rotate(by: Rotation.degrees_270)
            }
        }
    }

    public static func onLongTap(_ cellGridView: CellGridView, _ viewPoint: CGPoint) {
        if let cell: LifeCell = cellGridView.gridCell(viewPoint: viewPoint) {
            TetrisView.blocks.append(TetrisBlock(Tetromino.L, at: cell, write: true))
        }
    }

    public static func onDoubleTap(_ cellGridView: LifeCellGridView) {
        TetrisView.blocks.append(TetrisBlock(Tetromino.O, at: CellLocation(3,  2), cellGridView, write: true))
        TetrisView.blocks.append(TetrisBlock(Tetromino.I, at: CellLocation(3,  7), cellGridView, write: true))
        TetrisView.blocks.append(TetrisBlock(Tetromino.S, at: CellLocation(3, 12), cellGridView, write: true))
        TetrisView.blocks.append(TetrisBlock(Tetromino.Z, at: CellLocation(3, 17), cellGridView, write: true))
        TetrisView.blocks.append(TetrisBlock(Tetromino.L, at: CellLocation(3, 23), cellGridView, write: true))
        TetrisView.blocks.append(TetrisBlock(Tetromino.J, at: CellLocation(3, 28), cellGridView, write: true))
        TetrisView.blocks.append(TetrisBlock(Tetromino.T, at: CellLocation(3, 33), cellGridView, write: true))
    }

    public static func findBlock(_ location: CellLocation) -> TetrisBlock? {
        //
        // Returns the first block which has a cell which is one of the cells in the given list of locations.
        //
        for block in TetrisView.blocks {
            for blockLocation in block.locations {
                if (blockLocation == location) {
                    return block
                }
            }
        }
        return nil
    }
}

internal class TetrisBlock
{
    private var _locations: [CellLocation]
    private var _color: Colour
    private var _cellGridView: LifeCellGridView

    convenience public init(_ tetromino: Tetromino,
                            at cell: LifeCell,
                            color: Colour? = nil,
                            rotation: Rotation? = nil, write: Bool = false)
    {
        self.init(tetromino, at: cell.location, cell.cellGridView, color: color, rotation: rotation, write: write)
    }

    public init(_ tetromino: Tetromino,
                at location: CellLocation, _ cellGridView: LifeCellGridView,
                color: Colour? = nil,
                rotation: Rotation? = nil, write: Bool = false)
    {
        self._locations = []
        for tetrominoLocation in CellLocations.rotate(tetromino.locations, by: rotation) {
            self._locations.append(CellLocation(location.x + tetrominoLocation.x, location.y + tetrominoLocation.y))
        }
        self._color = color ?? tetromino.color
        self._cellGridView = cellGridView
        if (write) {
            self.write()
        }
    }

    public var locations: [CellLocation] { self._locations }

    public func rotate(by rotation: Rotation = Rotation.degrees_90) -> Bool {
        return self.transform(to: CellLocations.rotate(self._locations, by: rotation))
    }

    public func move(offsetX: Int, offsetY: Int) -> Bool {
        return self.transform(to: CellLocations.move(self._locations, offsetX, offsetY))
    }

    public func move(offsetX: Int, offsetY: Int, stepFrom: Cell) {
        //
        // Doing a straight move (above) with offset could allow us to go
        // THROUGH a block; this does the move step-wise to disallow that.
        //
        guard (offsetX != 0) || (offsetY != 0) else { return }
        var skip: Bool = false
        let endLocation: CellLocation = CellLocation(stepFrom.location.x + offsetX, stepFrom.location.y + offsetY)
        var lastLocation: CellLocation = stepFrom.location
        for intermediateLocation in CellLocations.intermediate(stepFrom.location, endLocation) {
            let offsetX: Int =  intermediateLocation.x - lastLocation.x
            let offsetY: Int =  intermediateLocation.y - lastLocation.y
            if (!self.move(offsetX: offsetX, offsetY: offsetY)) {
                skip = true
                break
            }
            lastLocation = intermediateLocation
        }
        if (!skip) {
            let offsetX: Int = endLocation.x - lastLocation.x
            let offsetY: Int = endLocation.y - lastLocation.y
            self.move(offsetX: offsetX, offsetY: offsetY)
        }
    }

    private func transform(to locationsNew: [CellLocation]) -> Bool {
        guard locationsNew.count > 0,
              CellLocations.inrange(locationsNew, gridWidth: self._cellGridView.gridColumns,
                                                  gridHeight: self._cellGridView.gridRows) else { return false }
        let locationsCurrent: [CellLocation] = self._locations
        //
        // Do not allow blocks to overlap each other; so make sure that none of the cells of the
        // new location for this block (locationsNew) intersect with the cells of any other existing
        // blocks, except of course, being careful to ignore the cell location of this current block.
        //
        for block in TetrisView.blocks {
            if (!CellLocations.equal(block.locations, self._locations)) {
                if (CellLocations.intersecting(block.locations, locationsNew)) {
                    return false
                }
            }
        }
        //
        // Unwrite cells in this current block which are NOT also in the new/transformed block.
        //
        self.write(color: self._cellGridView.inactiveColor, minus: locationsNew)
        //
        // Write cells of the new/transformed block which were NOT also in this current/untransformed block.
        //
        self._locations = locationsNew
        self.write(color: self._color, minus: locationsCurrent)
        return true
    }

    // Writes all of the cells comprising this block with the default/defined color.
    //
    public func write() {
        self.write(color: self._color)
    }

    // Writes all of the cells comprising this block with the given color. If the minus argument is
    // given then ignore (do not write) any of the cell locations specified therein; this facilitates
    // parsimony with respect to not writing cells of the block which are not necessary to (re)write.
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

    private func filled(row: Int) -> Bool {
        guard row < self._cellGridView.gridRows else { return false }
        var filled: Set<Int> = []
        for block in TetrisView.blocks {
            for location in block.locations {
                if (location.y == row) {
                    filled.insert(location.x)
                }
            }
        }
        return filled.count == self._cellGridView.gridColumns
    }
}

public class Tetromino {

    public let locations: [CellLocation]
    public let color: Colour

    private init(_ locations: [CellLocation], color: Colour) {
        self.locations = locations
        self.color = color
    }

    public static let O: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢▢
        CellLocation(1, 0), // ▢▢
        CellLocation(0, 1), //
        CellLocation(1, 1)  //
    ], color: Colour.yellow)

    public static let I: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢
        CellLocation(0, 1), // ▢
        CellLocation(0, 2), // ▢
        CellLocation(0, 3)  // ▢
    ], color: Colour.cyan)

    public static let S: Tetromino = Tetromino(
    [
        CellLocation(1, 0), //  ▢▢
        CellLocation(2, 0), // ▢▢
        CellLocation(0, 1), //
        CellLocation(1, 1)  //
    ], color: Colour.green)

    public static let Z: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢▢
        CellLocation(1, 0), //  ▢▢
        CellLocation(1, 1), //
        CellLocation(2, 1)  //
    ], color: Colour.red)

    public static let L: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢
        CellLocation(0, 1), // ▢
        CellLocation(0, 2), // ▢▢
        CellLocation(1, 2)  //
    ], color: Colour.orange)

    public static let J: Tetromino = Tetromino(
    [
        CellLocation(1, 0), //  ▢
        CellLocation(1, 1), //  ▢
        CellLocation(0, 2), // ▢▢
        CellLocation(1, 2)  //
    ], color: Colour.blue)

    public static let T: Tetromino = Tetromino(
    [
        CellLocation(0, 0), // ▢▢▢
        CellLocation(1, 0), //  ▢
        CellLocation(2, 0), //
        CellLocation(1, 1)  //
    ], color: Colour.purple)
}

public enum Rotation {
    case degrees_90
    case degrees_180
    case degrees_270
}

internal class CellLocations {

    public static func rotate(_ locations: [CellLocation], by rotation: Rotation?) -> [CellLocation] {
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

    public static func move(_ locations: [CellLocation], _ offsetX: Int, _ offsetY: Int) -> [CellLocation] {
        return locations.map { CellLocation($0.x + offsetX, $0.y + offsetY) }
    }

    public static func intersecting(_ locationsA: [CellLocation], _ locationsB: [CellLocation]) -> Bool {
        for locationA in locationsA {
            for locationB in locationsB {
                if (locationA == locationB) {
                    return true
                }
            }
        }
        return false
    }

    public static func intermediate(_ locationA: CellLocation, _ locationB: CellLocation) -> [CellLocation] {
        //
        // Full disclosure: ChatGPT inspired implementation.
        //
        var points: [CellLocation] = []
        let xa: Int = locationA.x
        let ya: Int = locationA.y
        let xb: Int = locationB.x
        let yb: Int = locationB.y
        let dx: Int = abs(xb - xa)
        let dy: Int = abs(yb - ya)
        if max(dx, dy) <= 1 {
            return []
        }
        let sx: Int = xa < xb ? 1 : -1
        let sy: Int = ya < yb ? 1 : -1
        var x: Int = xa
        var y: Int = ya
        var error: Int = dx - dy
        while true {
            x += (x != xb ? sx : 0)
            y += (y != yb ? sy : 0)
            if ((x == xb) && (y == yb)) {
                break
            }
            points.append(CellLocation(x, y))
            let e: Int = 2 * error
            if (e > -dy) { error -= dy }
            if (e < dx) { error += dx }
        }
        return points
    }

    public static func inrange(_ locations: [CellLocation], gridWidth: Int, gridHeight: Int) -> Bool {
        for location in locations {
            if ((location.x < 0) || (location.y < 0) || (location.x >= gridWidth) || (location.y >= gridHeight)) {
                return false
            }
        }
        return true
    }

    public static func equal(_ locationsA: [CellLocation], _ locationsB: [CellLocation]) -> Bool {
        guard locationsA.count == locationsB.count else { return false }
        for locationA in locationsA {
            if (!locationsB.contains(locationA)) {
                return false
            }
        }
        return true
    }
}
