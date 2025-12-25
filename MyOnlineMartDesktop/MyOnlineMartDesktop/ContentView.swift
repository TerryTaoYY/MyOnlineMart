//
//  ContentView.swift
//  MyOnlineMartDesktop
//
//  Created by Yueyang Tao on 12/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSession())
        .environmentObject(CartStore())
}
