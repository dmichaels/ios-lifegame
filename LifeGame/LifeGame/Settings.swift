import Foundation
import SwiftUI
import CellGridView
import Utils


class Settings: ObservableObject
{
    // CellGridView (Config) base class specific properties we are interested in controlling.
    // See CellGridView.Defaults for all.

    @Published var viewBackground: Colour       = Colour.darkGray
    @Published var viewTransparency: UInt8      = Colour.TRANSPARENT
    @Published var viewScaling: Bool            = true

    @Published var cellSize: Int                = 13
    @Published var cellPadding: Int             = 1
    @Published var cellShape: CellShape         = CellShape.rounded
    @Published var cellShading: Bool            = false

    @Published var gridColumns: Int             = 150
    @Published var gridRows: Int                = 250
    @Published var fit: CellGridView.Fit        = CellGridView.Fit.enabled
    @Published var center: Bool                 = true

    @Published var cellAntialiasFade: Float     = CellGridView.Defaults.cellAntialiasFade
    @Published var cellRoundedRadius: Float     = CellGridView.Defaults.cellRoundedRadius
    @Published var restrictShift: Bool          = true
    @Published var unscaledZoom: Bool           = false
   
    @Published var selectRandomInterval: Double = CellGridView.Defaults.selectRandomInterval
    @Published var automationInterval: Double   = CellGridView.Defaults.automationInterval

    // Other CellGridView (non-Config) base class specific properties we are interested in controlling.

    @Published var automationMode: Bool   = true
    @Published var selectMode: Bool       = true
    @Published var selectRandomMode: Bool = false

    // LifeCellGridView specific properties.

    @Published var gameMode: GameMode                        = GameMode.life
    @Published var activeColor: Colour                       = Colour.black
    @Published var inactiveColor: Colour                     = Colour.white
    @Published var inactiveColorRandom: Bool                 = false
    @Published var inactiveColorRandomDynamic: Bool          = false
    @Published var inactiveColorRandomPalette: ColourPalette = ColourPalette.color
    @Published var inactiveColorRandomFilter: ColourFilter?  = nil

    @Published var variantHighLife: Bool                     = false
    @Published var variantOverPopulate: Bool                 = false
    @Published var variantInactiveFade: Bool                 = true
    @Published var variantInactiveFadeAgeMax: Int            = 5
    @Published var variantLatixOcclude: Bool                 = true
    @Published var selectModeFat: Bool                       = false
    @Published var selectModeExtraFat: Bool                  = false
    @Published var lifehashValue: String                     = ""

    @Published var dragThreshold: Int                        = 2
    @Published var swipeThreshold: Int                       = 100

    // ContentView specific properties.

    @Published var ignoreSafeArea: Bool = true
    @Published var hideStatusBar: Bool  = true
    @Published var soundsEnabled: Bool  = false
    @Published var hapticsEnabled: Bool = true

    // This just allows this Settings object to be the single place where we define the default parameters
    // for this app, which are easily accessible elsewhere, without having to define a separate Defaults class;
    // note that we still instantiate this class normally when passing to ContentView; it would otherwise be odd.
    //
    public static let Defaults: Settings = Settings()

    public func fromConfig(_ cellGridView: LifeCellGridView)
    {
        let config: LifeCellGridView.Config = cellGridView.config

        // CellGridView (Config) base class specific properties.

        self.viewBackground     = config.viewBackground
        self.viewTransparency   = config.viewTransparency
        self.viewScaling        = config.viewScaling
        self.cellSize           = config.cellSize
        self.cellPadding        = config.cellPadding
        self.cellShape          = config.cellShape
        self.cellShading        = config.cellShading
        self.gridColumns        = config.gridColumns
        self.gridRows           = config.gridRows
        self.fit                = config.fit
        //
        // This center property we treat as not really persistent;
        // we always use its false state when going into SettingsView.
        //
        self.center                    = false
        self.cellAntialiasFade         = config.cellAntialiasFade
        self.cellRoundedRadius         = config.cellRoundedRadius
        self.restrictShift             = config.restrictShift
        self.unscaledZoom              = config.unscaledZoom
        self.selectRandomInterval      = config.selectRandomInterval
        self.automationInterval        = config.automationInterval
        self.variantHighLife           = config.variantHighLife
        self.variantOverPopulate       = config.variantOverPopulate
        self.variantInactiveFade       = config.variantInactiveFade
        self.variantInactiveFadeAgeMax = config.variantInactiveFadeAgeMax
        self.variantLatixOcclude       = config.variantLatixOcclude
        self.selectModeFat             = config.selectModeFat
        self.selectModeExtraFat        = config.selectModeExtraFat
        self.lifehashValue             = config.lifehashValue

        // Other CellGridView (non-Config) base class specific properties.

        self.automationMode             = self.automationMode
        self.selectMode                 = self.selectMode
        self.selectRandomMode           = self.selectRandomMode

        // LifeCellGridView specific properties.

        self.gameMode                   = config.gameMode
        self.activeColor                = config.activeColor
        self.inactiveColor              = config.inactiveColor
        self.inactiveColorRandom        = config.inactiveColorRandom
        self.inactiveColorRandomDynamic = config.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = config.inactiveColorRandomPalette
        self.inactiveColorRandomFilter  = config.inactiveColorRandomFilter
        self.dragThreshold              = config.dragThreshold
        self.swipeThreshold             = config.swipeThreshold
    }

    // Creates and returns a new LifeCellGridView.Config (derived from CellGridView.Config)
    // object, with properties initialized from this Settings object. Intended to be called,
    // for example, on return from SettingsView in ContentView, something like this:
    //
    //     @EnvironmentObject var cellGridView: LifeCellGridView
    //     @EnvironmentObject var settings: Settings
    //     func onSettingsChange() {
    //         let config: LifeCellGridView.Config = self.settings.toConfig(self.cellGridView)
    //         self.cellGridView.configure(config)
    //     }
    //
    internal func toConfig(_ cellGridView: LifeCellGridView) -> LifeCellGridView.Config
    {
        return LifeCellGridView.Config(cellGridView, self)
    }
}
