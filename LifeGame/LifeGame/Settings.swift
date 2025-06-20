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

    public static let cellSize: Int                     = 18
    public static let cellSizeFit: Bool                 = false
    public static let cellPadding: Int                  = 1
    public static let cellShape: CellShape              = CellShape.rounded

    public static let gridCenter: Bool                  = true
    public static let restrictShiftStrict: Bool         = true
    public static let unscaledZoom: Bool                = false
    public static let automationInterval: Double        = 0.5

    // Life Game specific properties.

    public static let gridColumns: Int                  = 1000
    public static let gridRows: Int                     = 2000

    public static let activeColor: Colour                           = Colour.black
    public static let inactiveColor: Colour                         = Colour.white
    public static let inactiveColorRandom: Bool                     = false
    public static let inactiveColorRandomDynamic: Bool              = false
    public static let inactiveColorRandomColorMode: ColourMode      = ColourMode.color
    public static let inactiveColorRandomColorFilter: ColourFilter? = nil // ColourFilters.Reds

    public static let dragThreshold: Int                = 3
    public static let swipeThreshold: Int               = 100

    public static let soundEnabled: Bool                = true
    public static let hapticEnabled: Bool               = true
}

class Settings: ObservableObject
{
    // CellGridView base class specific properties.

    @Published var viewBackground: Colour            = LifeGame.Defaults.viewBackground
    @Published var viewTransparency: UInt8           = LifeGame.Defaults.viewTransparency
    @Published var viewScaling: Bool                 = LifeGame.Defaults.viewScaling

    @Published var cellSize: Int                     = LifeGame.Defaults.cellSize
    @Published var cellSizeFit: Bool                 = LifeGame.Defaults.cellSizeFit
    @Published var cellPadding: Int                  = LifeGame.Defaults.cellPadding
    @Published var cellShape: CellShape              = LifeGame.Defaults.cellShape

    @Published var automationInterval: Double        = LifeGame.Defaults.automationInterval

    // Life Game specific properties.

    @Published var gridColumns: Int                  = LifeGame.Defaults.gridColumns
    @Published var gridRows: Int                     = LifeGame.Defaults.gridRows
    @Published var gridCenter: Bool                  = LifeGame.Defaults.gridCenter

    @Published var activeColor: Colour                           = LifeGame.Defaults.activeColor
    @Published var inactiveColor: Colour                         = LifeGame.Defaults.inactiveColor
    @Published var inactiveColorRandom: Bool                     = LifeGame.Defaults.inactiveColorRandom
    @Published var inactiveColorRandomDynamic: Bool              = LifeGame.Defaults.inactiveColorRandomDynamic
    @Published var inactiveColorRandomColorMode: ColourMode      = LifeGame.Defaults.inactiveColorRandomColorMode
    @Published var inactiveColorRandomColorFilter: ColourFilter? = LifeGame.Defaults.inactiveColorRandomColorFilter

    @Published var soundEnabled: Bool                = LifeGame.Defaults.soundEnabled
    @Published var hapticEnabled: Bool               = LifeGame.Defaults.hapticEnabled
}
