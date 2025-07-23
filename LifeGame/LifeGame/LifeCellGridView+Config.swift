import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public class Config: CellGridView.Config
    {
        public var gameMode: GameMode
        public var activeColor: Colour
        public var inactiveColor: Colour
        public var inactiveColorRandom: Bool
        public var inactiveColorRandomDynamic: Bool
        public var inactiveColorRandomPalette: ColourPalette
        public var inactiveColorRandomFilter: ColourFilter?
        public var variantHighLife: Bool
        public var variantOverPopulate: Bool
        public var variantInactiveFade: Bool
        public var variantInactiveFadeAgeMax: Int
        public var variantLatixOcclude: Bool
        public var variantLatixConserve: Bool
        public var selectModeFat: Bool
        public var selectModeExtraFat: Bool
        public var lifehashValue: String

        public var dragThreshold: Int  = 3
        public var swipeThreshold: Int = 100

        // Initializes this instance of LifeCellGridView.Config with the properties from the given
        // Settings; or if this is nil then with the properties from the given LifeCellGridView;
        // or if that is nil then from the default values in Settings.Defaults.
        //
        // Note that this constructor does in fact effectively hide the base
        // class constructor which takes a CellGridView, which is what we want;
        // i.e. only allow creation of LifeCellGridView.Config with a LifeCellGridView.
        //
        // Note that the call to this with a Settings object (and non-nil LifeCellGridView object)
        // is done from the Settings.toConfig method. We do not just initialize from Settings
        // directly there because we need to initialize its CellGridView.Config base class
        // properties, particularly those base properties which we are not interested in here.
        //
        internal init(_ cellGridView: LifeCellGridView? = nil, _ settings: Settings? = nil) {

            // Shorter names/aliases; to easier see/check what is being initialized here.

            let v: LifeCellGridView? = cellGridView
            let s: Settings?         = settings
            let d: Settings          = Settings.Defaults

            // LifeCellGridView specific properties.

            self.gameMode                   = s?.gameMode                   ?? v?.gameMode                   ?? d.gameMode
            self.activeColor                = s?.activeColor                ?? v?.activeColor                ?? d.activeColor
            self.inactiveColor              = s?.inactiveColor              ?? v?.inactiveColor              ?? d.inactiveColor
            self.inactiveColorRandom        = s?.inactiveColorRandom        ?? v?.inactiveColorRandom        ?? d.inactiveColorRandom
            self.inactiveColorRandomDynamic = s?.inactiveColorRandomDynamic ?? v?.inactiveColorRandomDynamic ?? d.inactiveColorRandomDynamic
            self.inactiveColorRandomPalette = s?.inactiveColorRandomPalette ?? v?.inactiveColorRandomPalette ?? d.inactiveColorRandomPalette
            self.inactiveColorRandomFilter  = s?.inactiveColorRandomFilter  ?? v?.inactiveColorRandomFilter  ?? d.inactiveColorRandomFilter
            self.variantHighLife            = s?.variantHighLife            ?? v?.variantHighLife            ?? d.variantHighLife
            self.variantOverPopulate        = s?.variantOverPopulate        ?? v?.variantOverPopulate        ?? d.variantOverPopulate
            self.variantInactiveFade        = s?.variantInactiveFade        ?? v?.variantInactiveFade        ?? d.variantInactiveFade
            self.variantInactiveFadeAgeMax  = s?.variantInactiveFadeAgeMax  ?? v?.variantInactiveFadeAgeMax  ?? d.variantInactiveFadeAgeMax
            self.variantLatixOcclude        = s?.variantLatixOcclude        ?? v?.variantLatixOcclude        ?? d.variantLatixOcclude
            self.variantLatixConserve       = s?.variantLatixConserve       ?? v?.variantLatixConserve       ?? d.variantLatixConserve
            self.selectModeFat              = s?.selectModeFat              ?? v?.selectModeFat              ?? d.selectModeFat
            self.selectModeExtraFat         = s?.selectModeExtraFat         ?? v?.selectModeExtraFat         ?? d.selectModeExtraFat
            self.lifehashValue              = s?.lifehashValue              ?? v?.lifehashValue              ?? d.lifehashValue
            self.dragThreshold              = s?.dragThreshold              ?? v?.dragThreshold              ?? d.dragThreshold
            self.swipeThreshold             = s?.swipeThreshold             ?? v?.swipeThreshold             ?? d.swipeThreshold

            // CellGridView base class specific properties.

            super.init(
                viewBackground:       s?.viewBackground       ?? v?.viewBackground       ?? d.viewBackground,
                viewTransparency:     s?.viewTransparency     ?? v?.viewTransparency     ?? d.viewTransparency,
                viewScaling:          s?.viewScaling          ?? v?.viewScaling          ?? d.viewScaling,
                cellSize:             s?.cellSize             ?? v?.cellSize             ?? d.cellSize,
                cellPadding:          s?.cellPadding          ?? v?.cellPadding          ?? d.cellPadding,
                cellShape:            s?.cellShape            ?? v?.cellShape            ?? d.cellShape,
                cellShading:          s?.cellShading          ?? v?.cellShading          ?? d.cellShading,
                gridColumns:          s?.gridColumns          ?? v?.gridColumns          ?? d.gridColumns,
                gridRows:             s?.gridRows             ?? v?.gridRows             ?? d.gridRows,
                fit:                  s?.fit                  ?? v?.fit                  ?? d.fit,
                center:               s?.center               ?? v?.center               ?? d.center,
                cellAntialiasFade:    s?.cellAntialiasFade    ?? v?.cellAntialiasFade    ?? d.cellAntialiasFade,
                cellRoundedRadius:    s?.cellRoundedRadius    ?? v?.cellRoundedRadius    ?? d.cellRoundedRadius,
                restrictShift:        s?.restrictShift        ?? v?.restrictShift        ?? d.restrictShift,
                unscaledZoom:         s?.unscaledZoom         ?? v?.unscaledZoom         ?? d.unscaledZoom,
                selectRandomInterval: s?.selectRandomInterval ?? v?.selectRandomInterval ?? d.selectRandomInterval,
                automationInterval:   s?.automationInterval   ?? v?.automationInterval   ?? d.automationInterval,
                undulationInterval:   s?.undulationInterval   ?? v?.undulationInterval   ?? d.undulationInterval)
        }
    }
}
