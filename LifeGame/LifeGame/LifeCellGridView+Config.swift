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

        public init(_ cellGridView: LifeCellGridView? = nil) {

            self.activeColor                    = cellGridView?.activeColor                    ?? Settings.Defaults.activeColor
            self.inactiveColor                  = cellGridView?.inactiveColor                  ?? Settings.Defaults.inactiveColor
            self.inactiveColorRandom            = cellGridView?.inactiveColorRandom            ?? Settings.Defaults.inactiveColorRandom
            self.inactiveColorRandomDynamic     = cellGridView?.inactiveColorRandomDynamic     ?? Settings.Defaults.inactiveColorRandomDynamic
            self.inactiveColorRandomColorMode   = cellGridView?.inactiveColorRandomColorMode   ?? Settings.Defaults.inactiveColorRandomColorMode
            self.inactiveColorRandomColorFilter = cellGridView?.inactiveColorRandomColorFilter ?? Settings.Defaults.inactiveColorRandomColorFilter
            self.dragThreshold                  = cellGridView?.dragThreshold                  ?? Settings.Defaults.dragThreshold
            self.swipeThreshold                 = cellGridView?.swipeThreshold                 ?? Settings.Defaults.swipeThreshold
            self.soundEnabled                   = cellGridView?.soundEnabled                   ?? Settings.Defaults.soundEnabled
            self.hapticEnabled                   = cellGridView?.hapticEnabled                 ?? Settings.Defaults.hapticEnabled

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
    }
}

extension Settings
{
}
