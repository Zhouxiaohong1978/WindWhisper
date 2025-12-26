//
//  GardenCanvasView.swift
//  WindWhisper
//
//  声景花园 Canvas 动画视图
//

import SwiftUI

struct GardenCanvasView: View {
    let level: Int
    let leaves: Int

    @State private var animationPhase: Double = 0
    @State private var growthProgress: CGFloat = 0

    private var treeCount: Int {
        min(level, 5)
    }

    private var flowerCount: Int {
        min(leaves / 10, 20)
    }

    var body: some View {
        Canvas { context, size in
            let centerX = size.width / 2
            let groundY = size.height * 0.85

            // 绘制地面
            drawGround(context: context, size: size, groundY: groundY)

            // 绘制树木
            for i in 0..<treeCount {
                let treeX = size.width * (0.2 + CGFloat(i) * 0.15)
                let treeHeight = 60 + CGFloat(level) * 10
                drawTree(
                    context: context,
                    x: treeX,
                    y: groundY,
                    height: treeHeight * growthProgress,
                    phase: animationPhase + Double(i) * 0.5
                )
            }

            // 绘制花朵
            for i in 0..<flowerCount {
                let flowerX = size.width * (0.1 + CGFloat(i % 10) * 0.08)
                let flowerY = groundY - 10 - CGFloat(i / 10) * 15
                drawFlower(
                    context: context,
                    x: flowerX,
                    y: flowerY,
                    phase: animationPhase + Double(i) * 0.3,
                    colorIndex: i % 4
                )
            }

            // 绘制飘落的叶子
            for i in 0..<min(level * 2, 10) {
                drawFallingLeaf(
                    context: context,
                    size: size,
                    index: i,
                    phase: animationPhase
                )
            }

            // 绘制蝴蝶（高等级解锁）
            if level >= 3 {
                for i in 0..<(level - 2) {
                    drawButterfly(
                        context: context,
                        size: size,
                        index: i,
                        phase: animationPhase
                    )
                }
            }
        }
        .onAppear {
            // 生长动画
            withAnimation(.easeOut(duration: 1.5)) {
                growthProgress = 1.0
            }

            // 持续动画
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
    }

    // MARK: - Drawing Functions

    private func drawGround(context: GraphicsContext, size: CGSize, groundY: CGFloat) {
        let groundPath = Path { path in
            path.move(to: CGPoint(x: 0, y: groundY))
            path.addQuadCurve(
                to: CGPoint(x: size.width, y: groundY),
                control: CGPoint(x: size.width / 2, y: groundY - 20)
            )
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()
        }

        context.fill(
            groundPath,
            with: .linearGradient(
                Gradient(colors: [
                    Color(hex: "2D5016"),
                    Color(hex: "1A3009")
                ]),
                startPoint: CGPoint(x: 0, y: groundY),
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    private func drawTree(context: GraphicsContext, x: CGFloat, y: CGFloat, height: CGFloat, phase: Double) {
        guard height > 0 else { return }

        // 树干
        let trunkWidth: CGFloat = 8
        let trunkPath = Path { path in
            path.move(to: CGPoint(x: x - trunkWidth/2, y: y))
            path.addLine(to: CGPoint(x: x - trunkWidth/3, y: y - height * 0.4))
            path.addLine(to: CGPoint(x: x + trunkWidth/3, y: y - height * 0.4))
            path.addLine(to: CGPoint(x: x + trunkWidth/2, y: y))
            path.closeSubpath()
        }
        context.fill(trunkPath, with: .color(Color(hex: "4A3728")))

        // 树冠（多层圆形）
        let swayOffset = sin(phase) * 3

        for i in 0..<3 {
            let layerY = y - height * 0.4 - CGFloat(i) * height * 0.2
            let layerRadius = (height * 0.3) * (1.0 - CGFloat(i) * 0.2)

            let leafPath = Path(ellipseIn: CGRect(
                x: x - layerRadius + swayOffset,
                y: layerY - layerRadius,
                width: layerRadius * 2,
                height: layerRadius * 1.5
            ))

            let greenShade = 0.4 + Double(i) * 0.15
            context.fill(leafPath, with: .color(Color(
                red: 0.2 + greenShade * 0.3,
                green: 0.5 + greenShade * 0.3,
                blue: 0.2
            )))
        }
    }

    private func drawFlower(context: GraphicsContext, x: CGFloat, y: CGFloat, phase: Double, colorIndex: Int) {
        let colors: [Color] = [
            Color(hex: "FF6B9D"),
            Color(hex: "FFD93D"),
            Color(hex: "6BCB77"),
            Color(hex: "4D96FF")
        ]
        let color = colors[colorIndex]

        let sway = sin(phase) * 2
        let scale = 0.8 + sin(phase * 2) * 0.1

        // 花茎
        var stemPath = Path()
        stemPath.move(to: CGPoint(x: x, y: y + 15))
        stemPath.addQuadCurve(
            to: CGPoint(x: x + sway, y: y),
            control: CGPoint(x: x + sway/2, y: y + 7)
        )
        context.stroke(stemPath, with: .color(Color(hex: "2D5016")), lineWidth: 1.5)

        // 花瓣
        for i in 0..<5 {
            let angle = Double(i) * .pi * 2 / 5 + phase * 0.1
            let petalX = x + sway + cos(angle) * 6 * scale
            let petalY = y + sin(angle) * 6 * scale

            let petalPath = Path(ellipseIn: CGRect(
                x: petalX - 4,
                y: petalY - 3,
                width: 8,
                height: 6
            ))
            context.fill(petalPath, with: .color(color.opacity(0.9)))
        }

        // 花心
        let centerPath = Path(ellipseIn: CGRect(
            x: x + sway - 3,
            y: y - 3,
            width: 6,
            height: 6
        ))
        context.fill(centerPath, with: .color(Color(hex: "FFE66D")))
    }

    private func drawFallingLeaf(context: GraphicsContext, size: CGSize, index: Int, phase: Double) {
        let startX = size.width * (0.1 + CGFloat(index) * 0.09)
        let cyclePhase = (phase + Double(index) * 0.7).truncatingRemainder(dividingBy: .pi * 2)
        let progress = cyclePhase / (.pi * 2)

        let x = startX + sin(cyclePhase * 3) * 20
        let y = size.height * 0.1 + progress * size.height * 0.6

        let rotation = sin(cyclePhase * 2) * .pi / 4

        var leafContext = context
        leafContext.translateBy(x: x, y: y)
        leafContext.rotate(by: Angle(radians: rotation))

        let leafPath = Path { path in
            path.move(to: CGPoint(x: 0, y: -8))
            path.addQuadCurve(to: CGPoint(x: 0, y: 8), control: CGPoint(x: 6, y: 0))
            path.addQuadCurve(to: CGPoint(x: 0, y: -8), control: CGPoint(x: -6, y: 0))
        }

        leafContext.fill(leafPath, with: .color(Color(hex: "7CB342").opacity(0.7)))
    }

    private func drawButterfly(context: GraphicsContext, size: CGSize, index: Int, phase: Double) {
        let baseX = size.width * (0.3 + CGFloat(index) * 0.2)
        let baseY = size.height * 0.4

        let flyPhase = phase + Double(index) * 1.5
        let x = baseX + sin(flyPhase * 0.5) * 50
        let y = baseY + cos(flyPhase * 0.7) * 30

        let wingFlap = abs(sin(flyPhase * 8)) * 0.8 + 0.2

        // 翅膀
        let colors: [Color] = [.purple, .orange, .pink]
        let wingColor = colors[index % 3]

        // 左翅
        var leftWing = Path()
        leftWing.addEllipse(in: CGRect(x: x - 12, y: y - 6, width: 10, height: 12 * wingFlap))
        context.fill(leftWing, with: .color(wingColor.opacity(0.7)))

        // 右翅
        var rightWing = Path()
        rightWing.addEllipse(in: CGRect(x: x + 2, y: y - 6, width: 10, height: 12 * wingFlap))
        context.fill(rightWing, with: .color(wingColor.opacity(0.7)))

        // 身体
        let bodyPath = Path(ellipseIn: CGRect(x: x - 2, y: y - 4, width: 4, height: 8))
        context.fill(bodyPath, with: .color(.black))
    }
}

// MARK: - Garden Stats View

struct GardenStatsView: View {
    let progress: UserProgress

    var body: some View {
        HStack(spacing: 24) {
            statItem(icon: "leaf.fill", value: "\(progress.totalLeaves)", label: "叶子")
            statItem(icon: "tree.fill", value: "Lv.\(progress.gardenLevel)", label: "等级")
            statItem(icon: "flame.fill", value: "\(progress.consecutiveDays)", label: "连续天数")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(ZenTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(ZenTheme.freshLeaf)
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ZenTheme.textPrimary)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(ZenTheme.textSecondary)
        }
    }
}

#Preview {
    ZStack {
        ZenTheme.backgroundGradient
            .ignoresSafeArea()

        VStack {
            GardenCanvasView(level: 5, leaves: 150)
                .frame(height: 300)

            GardenStatsView(progress: UserProgress())
                .padding()
        }
    }
}
