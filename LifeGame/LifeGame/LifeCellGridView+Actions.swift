import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public func onLongTap(_ viewPoint: CGPoint) {
        if (self.gameMode == GameMode.tetris) {
            TetrisView.onLongTap(self, viewPoint)
            return
        }
    }
}
