//
//  ZenTheme.swift
//  WindWhisper
//
//  禅意风格主题 - 绿叶渐变配色
//

import SwiftUI

/// 禅意主题配色方案
enum ZenTheme {
    // MARK: - 主色调（绿叶渐变）

    /// 深森林绿 - 背景主色
    static let forestDeep = Color(hex: "1A2F1A")

    /// 自然绿 - 主强调色
    static let leafGreen = Color(hex: "4A7C59")

    /// 嫩叶绿 - 次强调色
    static let freshLeaf = Color(hex: "7CB342")

    /// 薄荷绿 - 高亮色
    static let mintGlow = Color(hex: "A5D6A7")

    // MARK: - 背景色

    /// 深色背景
    static let background = Color(hex: "0D1F0D")

    /// 卡片背景
    static let cardBackground = Color(hex: "1A2F1A").opacity(0.8)

    /// 浮层背景
    static let overlayBackground = Color.black.opacity(0.6)

    // MARK: - 文字颜色

    /// 主文字 - 白色
    static let textPrimary = Color.white

    /// 次文字 - 淡绿灰
    static let textSecondary = Color(hex: "A5D6A7").opacity(0.7)

    /// 禁用文字
    static let textDisabled = Color.white.opacity(0.3)

    // MARK: - 功能色

    /// 采集模式 - 风蓝色
    static let captureBlue = Color(hex: "64B5F6")

    /// 生成模式 - 金黄色
    static let generateGold = Color(hex: "FFD54F")

    /// 疗愈模式 - 薰衣草紫
    static let healingPurple = Color(hex: "CE93D8")

    // MARK: - 渐变

    /// 主背景渐变
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(hex: "0D1F0D"),
            Color(hex: "1A2F1A"),
            Color(hex: "0D1F0D")
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// 叶片渐变（用于按钮、图标）
    static let leafGradient = LinearGradient(
        colors: [freshLeaf, leafGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 光晕渐变（用于动画效果）
    static let glowGradient = RadialGradient(
        colors: [mintGlow.opacity(0.3), .clear],
        center: .center,
        startRadius: 0,
        endRadius: 150
    )
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("WindWhisper Theme")
            .font(.title)
            .foregroundColor(ZenTheme.textPrimary)

        HStack(spacing: 12) {
            Circle().fill(ZenTheme.leafGreen).frame(width: 50)
            Circle().fill(ZenTheme.freshLeaf).frame(width: 50)
            Circle().fill(ZenTheme.mintGlow).frame(width: 50)
        }

        HStack(spacing: 12) {
            Circle().fill(ZenTheme.captureBlue).frame(width: 40)
            Circle().fill(ZenTheme.generateGold).frame(width: 40)
            Circle().fill(ZenTheme.healingPurple).frame(width: 40)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ZenTheme.backgroundGradient)
}
