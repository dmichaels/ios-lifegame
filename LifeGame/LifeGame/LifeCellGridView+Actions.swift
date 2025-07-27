import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    // public override func onTap(_ viewPoint: CGPoint) {
        // super.onTap(viewPoint)
        // TODO: feedback.trigger()
    // }

    public func onLongTap(_ viewPoint: CGPoint) {
        if (self.gameMode == GameMode.tetris) {
            for tetrisBlock in self.tetrisBlocks {
                tetrisBlock.rotate(by: Rotation.degrees_90)
            }
            return
        }
    }

    public func onDoubleTap() {
        if (self.gameMode == GameMode.tetris) {
            for tetrisBlock in self.tetrisBlocks {
                tetrisBlock.move(offsetX: 1, offsetY: 1)
            }
            return
        }
    }
}
