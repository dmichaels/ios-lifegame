import Foundation
import SwiftUI
import CellGridView
import Utils

public class Defaults
{
    // CellGridView base class specific properties.

    public static let viewBackground: Colour            = Colour.darkGray
    public static let viewTransparency: UInt8           = CellGridView.Defaults.viewTransparency
    public static let viewScaling: Bool                 = CellGridView.Defaults.viewScaling

    public static let cellSize: Int                     = 20
    public static let cellSizeFit: Bool                 = true
    public static let cellPadding: Int                  = 1
    public static let cellShape: CellShape              = CellShape.rounded
    public static let cellColorMode: ColourMode         = ColourMode.color

    public static let gridCenter: Bool                  = true
    public static let restrictShiftStrict: Bool         = true
    public static let unscaledZoom: Bool                = false
    public static let automationEnabled: Bool           = true
    public static let automationInterval: Double        = 0.5

    // Life Game specific properties.

    public static let cellInactiveColorRandom: Bool        = true
    public static let cellInactiveColorRandomDynamic: Bool = true

    public static let gridColumns: Int                  = 1000
    public static let gridRows: Int                     = 2000

    public static let cellActiveColor: Colour           = Colour.red
    public static let cellInactiveColor: Colour         = Colour.white

    public static let dragThreshold: Int                = 3
    public static let swipeThreshold: Int               = 100

    public static let soundEnabled: Bool                = true
    public static let hapticEnabled: Bool               = true
}

class Settings: ObservableObject
{
    // CellGridView base class specific properties.

    @Published var viewBackground: Colour            = Defaults.viewBackground
    @Published var viewTransparency: UInt8           = Defaults.viewTransparency
    @Published var viewScaling: Bool                 = Defaults.viewScaling

    @Published var cellSize: Int                     = Defaults.cellSize
    @Published var cellSizeFit: Bool                 = Defaults.cellSizeFit
    @Published var cellPadding: Int                  = Defaults.cellPadding
    @Published var cellShape: CellShape              = Defaults.cellShape
    @Published var cellColorMode: ColourMode         = Defaults.cellColorMode

    // Life Game specific properties.

    @Published var cellInactiveColorRandom: Bool        = Defaults.cellInactiveColorRandom
    @Published var cellInactiveColorRandomDynamic: Bool = Defaults.cellInactiveColorRandomDynamic

    @Published var gridColumns: Int                  = Defaults.gridColumns
    @Published var gridRows: Int                     = Defaults.gridRows

    @Published var cellActiveColor: Colour           = Colour.red
    @Published var cellInactiveColor: Colour         = Colour.white

    @Published var automationEnabled: Bool           = Defaults.automationEnabled
    @Published var automationInterval: Double        = Defaults.automationInterval

    @Published var soundEnabled: Bool                = Defaults.soundEnabled
    @Published var hapticEnabled: Bool               = Defaults.hapticEnabled
}
