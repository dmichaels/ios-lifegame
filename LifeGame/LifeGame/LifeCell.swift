import SwiftUI
import CellGridView
import Utils

public final class LifeCell: Cell {

    private var _active: Bool
    private var _inactiveColorRandomDynamicNumber: Int
    private var _inactiveColorRandomNumber: Int

    init(cellGridView: LifeCellGridView, x: Int, y: Int,  active: Bool = false) {
        self._active = active
        self._inactiveColorRandomDynamicNumber = cellGridView.generationNumber + 1
        self._inactiveColorRandomNumber = cellGridView.inactiveColorRandomNumber + 1
        super.init(cellGridView: cellGridView, x: x, y: y, color: cellGridView.inactiveColor)
    }

    public override var cellGridView: LifeCellGridView {
        super.cellGridView as! LifeCellGridView
    }

    public override var color: Colour {
        get {
            if (self._active) {
                return self.cellGridView.activeColor
            }
            return Colour.random(tint: Colour.red, tintBy: 0.5).darken(by: 0.4)
            // return Colour.random(tint: Colour.red.opacity(0.5), tintBy: 1.0)
            // return Colour.random().opacity(0.3).tint(toward: Colour.red.opacity(0.5), by: 1.0, opacity: false)
/*
            else if (self.cellGridView.inactiveColorRandomDynamic) {
                if (self._inactiveColorRandomDynamicNumber != self.cellGridView.generationNumber) {
                    super.color = self.cellGridView.inactiveColorRandomColor()
                    self._inactiveColorRandomDynamicNumber = self.cellGridView.generationNumber
                }
                return super.color
            }
            else if (self.cellGridView.inactiveColorRandom) {
                if (self._inactiveColorRandomNumber != self.cellGridView.inactiveColorRandomNumber) {
                    super.color = self.cellGridView.inactiveColorRandomColor()
                    self._inactiveColorRandomNumber = self.cellGridView.inactiveColorRandomNumber
                }
                return super.color
            }
            return self.cellGridView.inactiveColor
*/
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
