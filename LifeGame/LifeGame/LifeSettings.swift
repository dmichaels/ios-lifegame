import SwiftUI
import CellGridView

public class DefaultLifeSettings
{
    public static let cellActiveColor: CellColor = CellColor.red
    public static let cellInactiveColor: CellColor = CellColor.white
}

class LifeSettings: Settings
{
    @Published var cellActiveColor: CellColor = CellColor.red
    @Published var cellInactiveColor: CellColor = CellColor.white
}
