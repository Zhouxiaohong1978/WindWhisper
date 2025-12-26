//
//  RootView.swift
//  WindWhisper
//
//  根视图 - 控制启动画面到主界面的过渡
//

import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showSplash = false
            }
        }
    }
}

#Preview {
    RootView()
}
