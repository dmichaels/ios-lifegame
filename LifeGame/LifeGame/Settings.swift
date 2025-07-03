import Foundation
import SwiftUI
import CellGridView
import Utils

class Settings: ObservableObject
{
    // CellGridView base class specific properties we are interested in controlling; see CellGridView.Defaults for all.

    @Published var viewBackground: Colour     = Colour.darkGray
    @Published var viewTransparency: UInt8    = Colour.OPAQUE
    @Published var viewScaling: Bool          = true

    @Published var cellSize: Int              = 23
    @Published var cellPadding: Int           = 1
    @Published var cellShape: CellShape       = CellShape.rounded
    @Published var cellShading: Bool          = false

    @Published var gridColumns: Int           = 100
    @Published var gridRows: Int              = 250
    @Published var fit: CellGridView.Fit      = CellGridView.Fit.enabled
    @Published var center: Bool               = true

    @Published var cellAntialiasFade: Float   = CellGridView.Defaults.cellAntialiasFade
    @Published var cellRoundedRadius: Float   = CellGridView.Defaults.cellRoundedRadius
    @Published var restrictShift: Bool        = true
    @Published var unscaledZoom: Bool         = false

    @Published var selectMode: Bool           = true
    @Published var automationMode: Bool       = true
    @Published var automationInterval: Double = CellGridView.Defaults.automationInterval

    // LifeCellGridView specific properties.

    @Published var activeColor: Colour                       = Colour.black
    @Published var inactiveColor: Colour                     = Colour.white
    @Published var inactiveColorRandom: Bool                 = false
    @Published var inactiveColorRandomDynamic: Bool          = false
    @Published var inactiveColorRandomPalette: ColourPalette = ColourPalette.color
    @Published var inactiveColorRandomFilter: ColourFilter?  = nil

    @Published var dragThreshold: Int                        = 2
    @Published var swipeThreshold: Int                       = 100
    @Published var soundEnabled: Bool                        = false
    @Published var hapticEnabled: Bool                       = false

    // This just allows this Settings object to be the single place where we define the default parameters
    // for this app, which are easily accessible elsewhere, without having to define a separate Defaults class;
    // note that we still instantiate this class normally when passing to ContentView; it would otherwise be odd.
    //
    public static let Defaults: Settings = Settings()

    // Sets up this Settings object from the given LifeCellGridView.Config.
    // Intended to be called, for example, before showing SettingsView
    // from ContentView, something like this:
    //
    //     @EnvironmentObject var cellGridView: LifeCellGridView
    //     @EnvironmentObject var settings: Settings
    //     func gotoSettingsView() {
    //         self.settings.fromConfig(self.cellGridView.config)
    //         self.showSettingsView = true
    //     }
    //
    public func fromConfig(_ config: LifeCellGridView.Config)
    {
        // CellGridView base class specific properties.

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
        // This center property we treat as not really persistent; we always
        // use its initial/default (noop/false) state when going to SettingsView.
        //
        self.center             = false
        self.cellAntialiasFade  = config.cellAntialiasFade
        self.cellRoundedRadius  = config.cellRoundedRadius
        self.restrictShift      = config.restrictShift
        self.unscaledZoom       = config.unscaledZoom
        self.selectMode         = config.selectMode
        self.automationMode     = config.automationMode
        self.automationInterval = config.automationInterval

        // LifeCellGridView specific properties.

        self.activeColor                = config.activeColor
        self.inactiveColor              = config.inactiveColor
        self.inactiveColorRandom        = config.inactiveColorRandom
        self.inactiveColorRandomDynamic = config.inactiveColorRandomDynamic
        self.inactiveColorRandomPalette = config.inactiveColorRandomPalette
        self.inactiveColorRandomFilter  = config.inactiveColorRandomFilter
        self.dragThreshold              = config.dragThreshold
        self.swipeThreshold             = config.swipeThreshold
        self.soundEnabled               = config.soundEnabled
        self.hapticEnabled              = config.hapticEnabled
    }

    public func fromConfig(_ cellGridView: LifeCellGridView)
    {
        self.fromConfig(cellGridView.config)
    }

    // Creates and returns a new LifeCellGridView.Config (derived from CellGridView.Config)
    // object, with properties initializes from this Settings object. Intended to be called,
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
