import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public class Config: CellGridView.Config
    {
        public var activeColor: Colour
        public var inactiveColor: Colour
        public var inactiveColorRandom: Bool
        public var inactiveColorRandomDynamic: Bool
        public var inactiveColorRandomColorMode: ColourMode
        public var inactiveColorRandomColorFilter: ColourFilter?

        public var dragThreshold: Int  = 3
        public var swipeThreshold: Int = 100
        public var soundEnabled: Bool  = false
        public var hapticEnabled: Bool = false

        // Initializes this instance of LifeCellGridView.Config with the properties from the given
        // LifeCellGridView, or with the default values from Settings.Defaults is nil is given.
        //
        // Note that this constructor does in fact effectively hide the base
        // class constructor which takes a CellGridView, which is what we want;
        // i.e. only allow creation of LifeCellGridView.Config with a LifeCellGridView.
        //
        public init(_ cellGridView: LifeCellGridView? = nil) {

            // Life Game specific properties.

            self.activeColor                    = cellGridView?.activeColor                    ?? Settings.Defaults.activeColor
            self.inactiveColor                  = cellGridView?.inactiveColor                  ?? Settings.Defaults.inactiveColor
            self.inactiveColorRandom            = cellGridView?.inactiveColorRandom            ?? Settings.Defaults.inactiveColorRandom
            self.inactiveColorRandomDynamic     = cellGridView?.inactiveColorRandomDynamic     ?? Settings.Defaults.inactiveColorRandomDynamic
            self.inactiveColorRandomColorMode   = cellGridView?.inactiveColorRandomColorMode   ?? Settings.Defaults.inactiveColorRandomColorMode
            self.inactiveColorRandomColorFilter = cellGridView?.inactiveColorRandomColorFilter ?? Settings.Defaults.inactiveColorRandomColorFilter
            self.dragThreshold                  = cellGridView?.dragThreshold                  ?? Settings.Defaults.dragThreshold
            self.swipeThreshold                 = cellGridView?.swipeThreshold                 ?? Settings.Defaults.swipeThreshold
            self.soundEnabled                   = cellGridView?.soundEnabled                   ?? Settings.Defaults.soundEnabled
            self.hapticEnabled                  = cellGridView?.hapticEnabled                  ?? Settings.Defaults.hapticEnabled

            // CellGridView base class specific properties.

            super.init(cellGridView)

            super.viewBackground     = cellGridView?.viewBackground     ?? Settings.Defaults.viewBackground
            super.viewScaling        = cellGridView?.viewScaling        ?? Settings.Defaults.viewScaling
            super.cellSize           = cellGridView?.cellSize           ?? Settings.Defaults.cellSize
            super.cellPadding        = cellGridView?.cellPadding        ?? Settings.Defaults.cellPadding
            super.cellShape          = cellGridView?.cellShape          ?? Settings.Defaults.cellShape
            super.gridColumns        = cellGridView?.gridColumns        ?? Settings.Defaults.gridColumns
            super.gridRows           = cellGridView?.gridRows           ?? Settings.Defaults.gridRows
            super.restrictShift      = cellGridView?.restrictShift      ?? Settings.Defaults.restrictShift
            super.unscaledZoom       = cellGridView?.unscaledZoom       ?? Settings.Defaults.unscaledZoom
            super.cellAntialiasFade  = cellGridView?.cellAntialiasFade  ?? Settings.Defaults.cellAntialiasFade
            super.cellRoundedRadius  = cellGridView?.cellRoundedRadius  ?? Settings.Defaults.cellRoundedRadius
            super.selectMode         = cellGridView?.selectMode         ?? Settings.Defaults.selectMode
            super.automationMode     = cellGridView?.automationMode     ?? Settings.Defaults.automationMode
            super.automationInterval = cellGridView?.automationInterval ?? Settings.Defaults.automationInterval
        }

        // TODO: Hmmmm
        //
        internal init(_ cellGridView: LifeCellGridView, _ settings: Settings) {

            // Life Game specific properties.

            self.activeColor                  = settings.activeColor
            self.inactiveColor                = settings.inactiveColor
            self.inactiveColorRandom          = settings.inactiveColorRandom
            self.inactiveColorRandomDynamic   = settings.inactiveColorRandomDynamic
            self.inactiveColorRandomColorMode = settings.inactiveColorRandomColorMode
            self.dragThreshold                = settings.dragThreshold
            self.swipeThreshold               = settings.swipeThreshold
            self.soundEnabled                 = settings.soundEnabled
            self.hapticEnabled                = settings.hapticEnabled

            // CellGridView base class specific properties.

            super.init(cellGridView)

            super.viewBackground     = settings.viewBackground
            super.viewScaling        = settings.viewScaling
            super.viewTransparency   = settings.viewTransparency
            super.cellSize           = settings.cellSize
            super.cellPadding        = settings.cellPadding
            super.cellShape          = settings.cellShape
            super.gridColumns        = settings.gridColumns
            super.gridRows           = settings.gridRows
            super.restrictShift      = settings.restrictShift
            super.unscaledZoom       = settings.unscaledZoom
            super.cellAntialiasFade  = settings.cellAntialiasFade
            super.cellRoundedRadius  = settings.cellRoundedRadius
            super.selectMode         = settings.selectMode
            super.automationMode     = settings.automationMode
            super.automationInterval = settings.automationInterval
        }
    }
}

extension Settings
{
}
