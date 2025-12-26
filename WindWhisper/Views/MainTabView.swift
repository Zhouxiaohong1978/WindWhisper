//
//  MainTabView.swift
//  WindWhisper
//
//  主标签视图 - 采集、生成、疗愈三步闭环
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CaptureView()
                .tabItem {
                    Image(systemName: "mic.circle.fill")
                    Text("采集")
                }
                .tag(0)

            GenerateView()
                .tabItem {
                    Image(systemName: "waveform.circle.fill")
                    Text("生成")
                }
                .tag(1)

            HealingView()
                .tabItem {
                    Image(systemName: "leaf.circle.fill")
                    Text("疗愈")
                }
                .tag(2)
        }
        .tint(ZenTheme.freshLeaf)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(ZenTheme.forestDeep)

        // 未选中状态
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(ZenTheme.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(ZenTheme.textSecondary)
        ]

        // 选中状态
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(ZenTheme.freshLeaf)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(ZenTheme.freshLeaf)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
