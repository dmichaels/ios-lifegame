import SwiftUI
import CellGridView
import Utils

public final class LifeCell: Cell {

    private var _active: Bool
    private var _cellInactiveColorRandomDynamicNumber: Int
    private var _cellInactiveColorRandomNumber: Int

    init(cellGridView: LifeCellGridView, x: Int, y: Int,  active: Bool = false) {
        self._active = active
        self._cellInactiveColorRandomDynamicNumber = cellGridView.generationNumber + 1
        self._cellInactiveColorRandomNumber = cellGridView.cellInactiveColorRandomNumber + 1
        super.init(cellGridView: cellGridView, x: x, y: y, color: cellGridView.cellInactiveColor)
    }

    public override var cellGridView: LifeCellGridView {
        super.cellGridView as! LifeCellGridView
    }

    public override var color: Colour {
        get {
            if (self._active) {
                return self.cellGridView.cellActiveColor
            }
            else if (self.cellGridView.cellInactiveColorRandomDynamic) {
                if (self._cellInactiveColorRandomDynamicNumber != self.cellGridView.generationNumber) {
                    super.color = self.cellGridView.cellInactiveColorRandomColor()
                    self._cellInactiveColorRandomDynamicNumber = self.cellGridView.generationNumber
                }
                return super.color
            }
            else if (self.cellGridView.cellInactiveColorRandom) {
                if (self._cellInactiveColorRandomNumber != self.cellGridView.cellInactiveColorRandomNumber) {
                    super.color = self.cellGridView.cellInactiveColorRandomColor()
                    self._cellInactiveColorRandomNumber = self.cellGridView.cellInactiveColorRandomNumber
                }
                return super.color
            }
            return self.cellGridView.cellInactiveColor
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

    public func activate(nowrite: Bool = false, nonotify: Bool = false) {
        if (!self._active) {
            self._active = true
            if (!nowrite)  {
                self.write()
            }
            if (!nonotify) {
                self.cellGridView.noteCellActivated(self)
            }
        }
    }

    public func deactivate(nowrite: Bool = false, nonotify: Bool = false) {
        if (self._active) {
            self._active = false
            if (!nowrite)  {
                self.write()
            }
            if (!nonotify) {
                self.cellGridView.noteCellDeactivated(self)
            }
        }
    }

    public func toggle(nowrite: Bool = false) {
        self._active ? self.deactivate(nowrite: nowrite) : self.activate(nowrite: nowrite)
    }
}
