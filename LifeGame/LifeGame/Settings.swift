import Foundation
import SwiftUI
import CellGridView
import Utils

class Settings: ObservableObject
{
    // CellGridView base class specific properties.

    @Published var viewBackground: Colour     = Colour.darkGray
    @Published var viewTransparency: UInt8    = Colour.OPAQUE
    @Published var viewScaling: Bool          = true

    @Published var cellSize: Int              = 18
    @Published var cellSizeFit: Bool          = false
    @Published var cellPadding: Int           = 1
    @Published var cellShape: CellShape       = CellShape.rounded

    @Published var gridColumns: Int           = 50 // 500
    @Published var gridRows: Int              = 75 // 750
    @Published var centerCells: Bool          = false

    @Published var restrictShift: Bool        = true
    @Published var unscaledZoom: Bool         = false
    @Published var cellAntialiasFade: Float   = CellGridView.Defaults.cellAntialiasFade
    @Published var cellRoundedRadius: Float   = CellGridView.Defaults.cellRoundedRadius

    @Published var selectMode: Bool           = true
    @Published var automationMode: Bool       = true
    @Published var automationInterval: Double = 0.5

    // Life Game specific properties.

    @Published var activeColor: Colour                           = Colour.black
    @Published var inactiveColor: Colour                         = Colour.white
    @Published var inactiveColorRandom: Bool                     = false
    @Published var inactiveColorRandomDynamic: Bool              = false
    @Published var inactiveColorRandomColorMode: ColourMode      = ColourMode.color
    @Published var inactiveColorRandomColorFilter: ColourFilter? = nil

    @Published var dragThreshold: Int  = 3
    @Published var swipeThreshold: Int = 100
    @Published var soundEnabled: Bool  = false
    @Published var hapticEnabled: Bool = false
}
