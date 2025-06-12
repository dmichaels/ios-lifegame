import Foundation
import SwiftUI
import Utils
import CellGridView

public class Defaults
{
    // CellGridView base class specific properties.

    public static let viewBackground: CellColor         = CellGridView.Defaults.viewBackground
    public static let viewTransparency: UInt8           = CellGridView.Defaults.viewTransparency
    public static let viewScaling: Bool                 = CellGridView.Defaults.viewScaling

    public static let cellSize: Int                     = CellGridView.Defaults.cellSize
    public static let cellSizeFit: Bool                 = CellGridView.Defaults.cellSizeFit
    public static let cellPadding: Int                  = CellGridView.Defaults.cellPadding
    public static let cellShape: CellShape              = CellGridView.Defaults.cellShape
    public static let cellForeground: CellColor         = CellGridView.Defaults.cellForeground
    public static let cellColorMode: CellColorMode      = CellColorMode.monochrome

    public static let cellSizeMax: Int                  = CellGridView.Defaults.cellSizeMax
    public static let cellSizeInnerMin: Int             = 2
    public static let cellPaddingMax: Int               = CellGridView.Defaults.cellPaddingMax
    public static let cellPreferredSizeMarginMax: Int   = CellGridView.Defaults.cellPreferredSizeMarginMax
    public static let cellAntialiasFade: Float          = CellGridView.Defaults.cellAntialiasFade
    public static let cellRoundedRectangleRadius: Float = CellGridView.Defaults.cellRoundedRectangleRadius

    public static let gridCenter: Bool                  = false // true
    public static let restrictShiftStrict: Bool         = CellGridView.Defaults.restrictShiftStrict
    public static let unscaledZoom: Bool                = CellGridView.Defaults.unscaledZoom
    public static let automationEnabled: Bool           = true
    public static let automationInterval: Double        = 0.5

    // Life Game specific properties.

    public static let gridColumns: Int                  = 1000
    public static let gridRows: Int                     = 2000

    public static let cellActiveColor: CellColor        = CellColor.red
    public static let cellInactiveColor: CellColor      = CellColor.white

    public static let dragThreshold: Int                = 3
    public static let swipeThreshold: Int               = 100

    public static let soundEnabled: Bool                = true
    public static let hapticEnabled: Bool               = true

    public static let ignoreSafeArea: Bool              = true
}

class Settings: ObservableObject
{
    @Published var viewBackground: CellColor         = Defaults.viewBackground
    @Published var viewTransparency: UInt8           = Defaults.viewTransparency
    @Published var viewScaling: Bool                 = Defaults.viewScaling

    @Published var cellSize: Int                     = Defaults.cellSize
    @Published var cellSizeFit: Bool                 = Defaults.cellSizeFit
    @Published var cellPadding: Int                  = Defaults.cellPadding
    @Published var cellShape: CellShape              = Defaults.cellShape
    @Published var cellColorMode: CellColorMode      = Defaults.cellColorMode
    @Published var preferredCellSizes: [Int]         = []

    @Published var soundEnabled: Bool                = Defaults.soundEnabled
    @Published var hapticEnabled: Bool               = Defaults.hapticEnabled

    @Published var gridColumns: Int                  = Defaults.gridColumns
    @Published var gridRows: Int                     = Defaults.gridRows

    @Published var cellActiveColor: CellColor        = CellColor.red
    @Published var cellInactiveColor: CellColor      = CellColor.white

    @Published var automationEnabled: Bool           = Defaults.automationEnabled
    @Published var automationInterval: Double        = Defaults.automationInterval
}
