import SwiftUI
import CellGridView

public final class LifeCell: Cell {

    private var _active: Bool

    init(cellGridView: LifeCellGridView, x: Int, y: Int,  active: Bool = false) {
        self._active = active
        let color: CellColor = active ? cellGridView.cellActiveColor : cellGridView.cellInactiveColor
        super.init(cellGridView: cellGridView, x: x, y: y, color: color)
    }

    public override var cellGridView: LifeCellGridView {
        return super.cellGridView as! LifeCellGridView
    }

    public override var color: CellColor {
        get { self._active ? self.cellGridView.cellActiveColor : self.cellGridView.cellInactiveColor }
        set { super.color = newValue }
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
            self.cellGridView.noteCellActivated(self)
        }
    }

    public func deactivate(nowrite: Bool = false) {
        if (self._active) {
            self._active = false
            if (!nowrite)  {
                self.write()
            }
            self.cellGridView.noteCellDeactivated(self)
        }
    }

    public func toggle(nowrite: Bool = false) {
        self._active ? self.deactivate(nowrite: nowrite) : self.activate(nowrite: nowrite)
    }
}
