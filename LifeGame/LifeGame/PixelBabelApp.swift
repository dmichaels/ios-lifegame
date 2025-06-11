//
//  PixelBabelApp.swift
//  PixelBabel
//
//  Created by David Michaels on 4/14/25.
//

import SwiftUI
import CellGridView

@main
struct PixelBabelApp: App {
    @StateObject var cellGridView: LifeCellGridView = LifeCellGridView()
    @StateObject var settings: Settings = Settings()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cellGridView)
                .environmentObject(settings)
        }
    }
}
