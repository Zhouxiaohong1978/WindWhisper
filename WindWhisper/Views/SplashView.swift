//
//  SplashView.swift
//  WindWhisper
//
//  启动画面 - 呼吸动画效果
//

import SwiftUI

struct SplashView: View {
    @State private var breatheScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var titleOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // 背景渐变
            ZenTheme.backgroundGradient
                .ignoresSafeArea()

            // 光晕效果
            Circle()
                .fill(ZenTheme.glowGradient)
                .frame(width: 300, height: 300)
                .scaleEffect(breatheScale)
                .opacity(glowOpacity)

            VStack(spacing: 24) {
                // 风叶图标
                ZStack {
                    // 外圈呼吸光环
                    Circle()
                        .stroke(ZenTheme.leafGradient, lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(breatheScale)
                        .opacity(glowOpacity)

                    // 中心图标
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(ZenTheme.leafGradient)
                        .scaleEffect(breatheScale * 0.9 + 0.1)
                }

                VStack(spacing: 8) {
                    // 英文名
                    Text("WindWhisper")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundColor(ZenTheme.textPrimary)
                        .opacity(titleOpacity)

                    // 中文名
                    Text("风语者")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(ZenTheme.textSecondary)
                        .opacity(titleOpacity)
                }

                // 标语
                Text("聆听自然，疗愈心灵")
                    .font(.system(size: 14))
                    .foregroundColor(ZenTheme.textSecondary)
                    .opacity(titleOpacity * 0.8)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            // 呼吸动画
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                breatheScale = 1.15
                glowOpacity = 0.6
            }

            // 文字淡入
            withAnimation(.easeIn(duration: 1.0).delay(0.3)) {
                titleOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
