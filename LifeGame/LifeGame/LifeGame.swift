import SwiftUI
import CellGridView

@main
struct LifeGame: App {
    init() { LatixCell.circleCellLocationsPreload() }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LifeCellGridView())
                .environmentObject(Settings())
        }
    }
}
