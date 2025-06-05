import Foundation
import SwiftUI
import Utils
import CellGridView

public class Defaults
{
    public static let ignoreSafeArea: Bool              = true
    public static let automationInterval: Double        = 0.2

    public static let viewScaling: Bool                 = CellGridView.Defaults.viewScaling
    public static let viewBackground: CellColor         = CellGridView.Defaults.viewBackground
    public static let viewTransparency: UInt8           = CellGridView.Defaults.viewTransparency

    public static let cellSize: Int                     = CellGridView.Defaults.cellSize
    public static let cellSizeFit: Bool                 = CellGridView.Defaults.cellSizeFit
    public static let cellPadding: Int                  = CellGridView.Defaults.cellPadding
    public static let cellShape: CellShape              = CellGridView.Defaults.cellShape
    public static let cellForeground: CellColor         = CellGridView.Defaults.cellForeground
    public static let cellAntialiasFade: Float          = CellGridView.Defaults.cellAntialiasFade
    public static let cellRoundedRectangleRadius: Float = CellGridView.Defaults.cellRoundedRectangleRadius
    public static let soundEnabled: Bool                = true
    public static let hapticEnabled: Bool               = true

    public static let gridColumns: Int                  = 50
    public static let gridRows: Int                     = 75

    public static let dragThreshold: Int                = 3
    public static let swipeThreshold: Int               = 100
    public static let updateMode: Bool                  = false

    public static let restrictShiftStrict: Bool         = false
    public static let centerCellGrid: Bool              = false
    public static let unscaledZoom: Bool                = false

    public static let cellActiveColor: CellColor = CellColor.red
    public static let cellInactiveColor: CellColor = CellColor.white
}

class Settings: ObservableObject
{
    @Published var viewBackground: CellColor         = Defaults.viewBackground
    @Published var viewScaling: Bool                 = Defaults.viewScaling

    @Published var cellSize: Int                     = Defaults.cellSize
    @Published var cellSizeFit: Bool                 = Defaults.cellSizeFit
    @Published var cellPadding: Int                  = Defaults.cellPadding
    @Published var cellShape: CellShape              = Defaults.cellShape
    @Published var cellAntialiasFade: Float          = Defaults.cellAntialiasFade
    @Published var cellRoundedRectangleRadius: Float = Defaults.cellRoundedRectangleRadius
    @Published var soundEnabled: Bool                = Defaults.soundEnabled
    @Published var hapticEnabled: Bool               = Defaults.hapticEnabled

    @Published var gridColumns: Int                  = Defaults.gridColumns
    @Published var gridRows: Int                     = Defaults.gridRows

    @Published var updateMode: Bool                  = Defaults.updateMode

    @Published var cellActiveColor: CellColor = CellColor.red
    @Published var cellInactiveColor: CellColor = CellColor.white
}
