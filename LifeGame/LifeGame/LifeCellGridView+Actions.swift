import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public func onLongTap(_ viewPoint: CGPoint) {
        if (self.gameMode == GameMode.tetris) {
            //
            // DEV: On long tap, create a new block.
            //
            if let cell: LifeCell = self.gridCell(viewPoint: viewPoint) {
                TetrisView.blocks.append(TetrisBlock(Tetromino.T, at: cell, color: Colour.blue, write: true))
            }
            return
        }
    }

    public func onDoubleTap() {
        if (self.gameMode == GameMode.tetris) {
            return
        }
    }
}
