import SwiftUI
import CellGridView

@main
struct LifeGame: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LifeCellGridView())
                .environmentObject(Settings())
        }
    }
}
