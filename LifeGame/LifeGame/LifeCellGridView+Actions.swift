import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public func onLongTap(_ viewPoint: CGPoint) {
        if (self.gameMode == GameMode.tetris) {
            for tetrisBlock in TetrisView.blocks {
                tetrisBlock.rotate(by: Rotation.degrees_90)
            }
            return
        }
    }

    public func onDoubleTap() {
        if (self.gameMode == GameMode.tetris) {
            for tetrisBlock in TetrisView.blocks {
                tetrisBlock.move(offsetX: 1, offsetY: 1)
            }
            return
        }
    }
}
