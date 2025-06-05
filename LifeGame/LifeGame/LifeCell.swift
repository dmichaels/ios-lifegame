import SwiftUI
import CellGridView

public final class LifeCell: Cell {

    private var _active: Bool
    private var _activeColor: CellColor = Defaults.cellActiveColor
    private var _inactiveColor: CellColor = Defaults.cellInactiveColor

    init(cellGridView: CellGridView, x: Int, y: Int, foreground: CellColor, active: Bool = false) {
        self._active = active
        super.init(cellGridView: cellGridView, x: x, y: y, foreground: foreground)
    }

    public override func select(dragging: Bool = false) {
        dragging ? self.activate() : self.toggle()
    }

    public var active: Bool {
        self._active
    }

    public var inactive: Bool {
        !self._active
    }

    public func activate(nowrite: Bool = false) {
        if (!self._active) {
            self._active = true
            if (!nowrite)  {
                self.write()
            }
        }
    }

    public func deactivate(nowrite: Bool = false) {
        if (self._active) {
            self._active = false
            if (!nowrite)  {
                self.write()
            }
        }
    }

    public func toggle(nowrite: Bool = false) {
        self._active ? self.deactivate(nowrite: nowrite) : self.activate(nowrite: nowrite)
    }

    func write() {
        self.write(foreground: self._active ? self._activeColor : self._inactiveColor)
    }
}
