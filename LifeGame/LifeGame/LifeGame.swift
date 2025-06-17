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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LifeCellGridView())
                .environmentObject(Settings())
        }
    }
}
