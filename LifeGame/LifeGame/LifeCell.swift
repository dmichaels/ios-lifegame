import SwiftUI
import CellGridView
import Utils

public final class LifeCell: Cell {

    private var _active: Bool
    private var _generationNumber: Int

    init(cellGridView: LifeCellGridView, x: Int, y: Int,  active: Bool = false) {
        self._active = active
        self._generationNumber = cellGridView.generationNumber + 1
        let color: Colour = active ? cellGridView.cellActiveColor : cellGridView.cellInactiveColor
        super.init(cellGridView: cellGridView, x: x, y: y, color: color)
    }

    public override var cellGridView: LifeCellGridView {
        super.cellGridView as! LifeCellGridView
    }

    public override var color: Colour {
        get {
            if (self._active) {
                return self.cellGridView.cellActiveColor
            }
            else {
                if (self.cellGridView.generationNumber != self._generationNumber) {
                    self.color = Colour.random(mode: ColourMode.color, filter: ColourFilters.Greens)
                    self._generationNumber = self.cellGridView.generationNumber
                }
                return super.color
            }
        }
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
