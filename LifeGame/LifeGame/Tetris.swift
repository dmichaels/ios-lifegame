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

    public init(_ tetromino: Tetromino, at cell: LifeCell, color: Colour, rotation: Rotation? = nil, write: Bool = false) {
        self._locations = []
        for location in TetrisBlock.rotateLocations(tetromino.locations, by: rotation) {
            self._locations.append(CellLocation(cell.x + location.x, cell.y + location.y))
        }
        self._color = color
        self._cellGridView = cell.cellGridView
        if (write) {
            self.write()
        }
    }

    public var locations: [CellLocation] { self._locations }

    public func rotate(by rotation: Rotation = Rotation.degrees_90) -> Bool {
        return self.transform(to: TetrisBlock.rotateLocations(self._locations, by: rotation))
    }

    public func move(offsetX: Int, offsetY: Int) -> Bool {
        return self.transform(to: TetrisBlock.moveLocations(self._locations, offsetX, offsetY))
    }

    public func stepMove(start: Cell, offsetX: Int, offsetY: Int) {
        guard (offsetX != 0) || (offsetY != 0) else { return }
        var skip: Bool = false
        let endLocation: CellLocation = CellLocation(start.location.x + offsetX, start.location.y + offsetY)
        var lastLocation: CellLocation = start.location
        let intermediateLocations = TetrisBlock.intermediateLocations(start.location, endLocation)
        for intermediateLocation in intermediateLocations {
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

    private func transform(to locationsNew: [CellLocation], sloppy: Bool = false) -> Bool {
        guard locationsNew.count > 0 else { return false }
        let locationsCurrent: [CellLocation] = self._locations
        if (!sloppy) {
            //
            // Do not allow blocks to overlop each other; so make sure that none of the cells of the
            // new location for this block (locationsNew) does not intersect with the cells of any other
            // existing blocks, except of course, being careful to ignore this blocks current cell location.
            //
            for block in TetrisView.blocks {
                if (!TetrisBlock.sameLocations(block.locations, self._locations)) {
                    if (TetrisBlock.intersectingLocations(block.locations, locationsNew)) {
                        return false
                    }
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

    private static func intersectingLocations(_ locationsA: [CellLocation], _ locationsB: [CellLocation]) -> Bool {
        for locationA in locationsA {
            for locationB in locationsB {
                if (locationA == locationB) {
                    return true
                }
            }
        }
        return false
    }

    private static func sameLocations(_ locationsA: [CellLocation], _ locationsB: [CellLocation]) -> Bool {
        guard locationsA.count == locationsB.count else { return false }
        for locationA in locationsA {
            if (!locationsB.contains(locationA)) {
                return false
            }
        }
        return true
    }

    internal static func intermediateLocations(_ locationA: CellLocation, _ locationB: CellLocation) -> [CellLocation] {
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
}

public class TetrisView {
    //
    // DEV: Temporary static container for common Tetris stuff.
    //
    internal static var blocks: [TetrisBlock] = []
    internal static var dragStartCellLocation: CellLocation? = nil
    internal static var dragLastCellLocation: CellLocation? = nil
    internal static var dragBlock: TetrisBlock? = nil

    internal static func findBlock(_ location: CellLocation) -> TetrisBlock? {
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

    internal static func onCellSelect(_ cellGridView: CellGridView, _ cell: Cell, dragging: Bool?) {
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
                if ((offsetX != 0) || (offsetY != 0)) {
                    let step: Bool = true
                    // var skip: Bool = false
                    if (step) {
                        TetrisView.dragBlock!.stepMove(start: cell, offsetX: offsetX, offsetY: offsetY)
                        /*
                        let endLocation: CellLocation = CellLocation(cell.location.x + offsetX, cell.location.y + offsetY)
                        var lastLocation: CellLocation = cell.location
                        let intermediateLocations = TetrisBlock.intermediateLocations(cell.location, endLocation)
                        for intermediateLocation in intermediateLocations {
                            let offsetX: Int =  intermediateLocation.x - lastLocation.x
                            let offsetY: Int =  intermediateLocation.y - lastLocation.y
                            if (!TetrisView.dragBlock!.move(offsetX: offsetX, offsetY: offsetY)) {
                                skip = true
                                break
                            }
                            lastLocation = intermediateLocation
                        }
                        if (!skip) {
                            let offsetX: Int =  endLocation.x - lastLocation.x
                            let offsetY: Int =  endLocation.y - lastLocation.y
                            TetrisView.dragBlock!.move(offsetX: offsetX, offsetY: offsetY)
                        }
                        */
                    }
                    else {
                        TetrisView.dragBlock!.move(offsetX: offsetX, offsetY: offsetY)
                    }
                }
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

    internal static func onLongTap(_ cellGridView: CellGridView, _ viewPoint: CGPoint) {
        if let cell: LifeCell = cellGridView.gridCell(viewPoint: viewPoint) {
            TetrisView.blocks.append(TetrisBlock(Tetromino.T, at: cell, color: Colour.blue, write: true))
        }
    }
}
