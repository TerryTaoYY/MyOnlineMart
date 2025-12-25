//
//  MyOnlineMartDesktopApp.swift
//  MyOnlineMartDesktop
//
//  Created by Yueyang Tao on 12/25/25.
//

import SwiftUI

@main
struct MyOnlineMartDesktopApp: App {
    @StateObject private var session = AppSession()
    @StateObject private var cart = CartStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(cart)
        }
    }
}
