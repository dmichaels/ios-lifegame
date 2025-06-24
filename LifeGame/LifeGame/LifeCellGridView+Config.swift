import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public class Config: CellGridView.Config
    {
        private var _activeColor: Colour                           = Colour.black
        private var _inactiveColor: Colour                         = Colour.white
        private var _inactiveColorRandom: Bool                     = false
        private var _inactiveColorRandomDynamic: Bool              = false
        private var _inactiveColorRandomColorMode: ColourMode      = ColourMode.color
        private var _inactiveColorRandomColorFilter: ColourFilter? = nil

        private var _dragThreshold: Int  = 3
        private var _swipeThreshold: Int = 100
        private var _soundEnabled: Bool  = false
        private var _hapticEnabled: Bool = false

        internal init(_ cellGridView: LifeCellGridView)
        {
            super.init(cellGridView)
            self._activeColor = cellGridView.activeColor
            self._inactiveColor = cellGridView.inactiveColor
            self._inactiveColorRandom = cellGridView.inactiveColorRandom
            self._inactiveColorRandomDynamic = cellGridView.inactiveColorRandomDynamic
            self._inactiveColorRandomColorMode = cellGridView.inactiveColorRandomColorMode
            // self._dragThreshold = Settings.dragThreshold
        }

        /*
        public override func with(viewBackground value: Colour) -> Config {
            return super.with(viewBackground: value)
            // var copy = self ; copy.viewBackground = value; return copy
        }
        */

        public func with(activeColor value: Colour) -> Config {
            var copy = self ; copy._activeColor = value; return copy
        }

        public func with(inactiveColor value: Colour) -> Config {
            var copy = self ; copy._inactiveColor = value; return copy
        }
    }
}

extension Settings
{
    // Sets up this Settings object from the given LifeCellGridView.
    // This is called when we are instantiating the SettingsView.
    // For example in ContentView we will have something like this:
    //
    //     func gotoSettingsView() {
    //         self.settings.setupFrom(self.cellGridView)
    //         self.showSettingsView = true
    //     }
    //
    internal func setupFrom(_ cellGridView: LifeCellGridView)
    {
        let config: CellGridView.Config = cellGridView.config
        self.viewBackground     = config.viewBackground
        self.viewTransparency   = config.viewTransparency
        self.viewScaling        = config.viewScaling
        self.cellSize           = config.cellSize
        self.cellPadding        = config.cellPadding
        self.cellShape          = config.cellShape
        self.gridColumns        = config.gridColumns
        self.gridRows           = config.gridRows
        self.restrictShift      = config.restrictShift
        self.unscaledZoom       = config.unscaledZoom
        self.cellAntialiasFade  = config.cellAntialiasFade
        self.cellRoundedRadius  = config.cellRoundedRadius
        self.selectMode         = config.selectMode
        self.automationMode     = config.automationMode
        self.automationInterval = config.automationInterval
    }

    // Creates and returns a LifeCellGridView.Config object, which
    // is derived from CellGridView.Config, from this Settings object.
    // This is called when we return from the SettingsView.
    // For example in ContentView we will have something like this:
    //
    //     func onSettingsChange() {
    //         let config: LifeCellGridView.Config = self.settings.toConfig(self.cellGridView)
    //         self.cellGridView.configure(config)
    //     }
    //
    internal func toConfig() -> LifeCellGridView.Config?
    {
        return nil
    }

    internal func toConfig(_ cellGridView: LifeCellGridView) -> LifeCellGridView.Config
    {
        // return LifeCellGridView.Config(cellGridView)
        return
            LifeCellGridView.Config(cellGridView)
            /*
                .with(viewBackground:     self.viewBackground)
                .with(viewTransparency:   self.viewTransparency)
                .with(viewScaling:        self.viewScaling)
                .with(cellSize:           self.cellSize)
                .with(cellPadding:        self.cellPadding)
                .with(cellShape:          self.cellShape)
                .with(gridColumns:        self.gridColumns)
                .with(gridRows:           self.gridRows)
                .with(restrictShift:      self.restrictShift)
                .with(unscaledZoom:       self.unscaledZoom)
                .with(cellAntialiasFade:  self.cellAntialiasFade)
                .with(cellRoundedRadius:  self.cellRoundedRadius)
                .with(selectMode:         self.selectMode)
                .with(automationMode:     self.automationMode)
                .with(automationInterval: self.automationInterval)
                */
    }
}
