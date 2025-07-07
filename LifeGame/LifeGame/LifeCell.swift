import SwiftUI
import CellGridView
import Utils

public final class LifeCell: Cell {

    private var _active: Bool
    private var _inactiveColorRandomDynamicNumber: Int
    private var _inactiveColorRandomNumber: Int
    //
    // The _inactiveGenerationNumber property is the
    // generation number at which this cell became inactive.
    //
    internal var _inactiveGenerationNumber: Int?

    init(cellGridView: LifeCellGridView, x: Int, y: Int, active: Bool = false) {
        self._active = active
        self._inactiveColorRandomDynamicNumber = cellGridView.inactiveColorRandomDynamicNumber + 1
        self._inactiveColorRandomNumber = cellGridView.inactiveColorRandomNumber + 1
        self._inactiveGenerationNumber = nil
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
            else if (self.cellGridView.variantInactiveFade) {
                if let inactiveGenerationNumber = self._inactiveGenerationNumber {
                    let inactiveAge: Int = self.inactiveAge
                    if (inactiveAge <= self.cellGridView.recentInactiveCellsMax) {
                        let lightenFactor: CGFloat = CGFloat(inactiveAge * 2) / 10.0
                        return self.cellGridView.activeColor.lighten(by: lightenFactor)
                    }
                }
            }
            else if (self.cellGridView.inactiveColorRandomDynamic) {
                if (self._inactiveColorRandomDynamicNumber != self.cellGridView.inactiveColorRandomDynamicNumber) {
                    super.color = self.cellGridView.inactiveColorRandomColor()
                    self._inactiveColorRandomDynamicNumber = self.cellGridView.inactiveColorRandomDynamicNumber
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

    internal var inactiveAge: Int {
        if let inactiveGenerationNumber = self._inactiveGenerationNumber {
            return self.cellGridView.generationNumber - inactiveGenerationNumber
        }
        return Int.max
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
