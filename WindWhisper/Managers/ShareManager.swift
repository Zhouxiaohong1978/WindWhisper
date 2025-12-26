//
//  ShareManager.swift
//  WindWhisper
//
//  分享管理器 - UIActivityViewController分享到TikTok等平台
//

import UIKit
import SwiftUI

@MainActor
final class ShareManager {
    // MARK: - Singleton

    static let shared = ShareManager()

    private init() {}

    // MARK: - Share Methods

    /// 分享BGM音频文件
    func shareBGM(_ bgm: GeneratedBGM, from viewController: UIViewController? = nil) {
        guard let audioPath = bgm.audioFileURL else {
            print("没有音频文件可分享")
            return
        }

        let audioURL = URL(fileURLWithPath: audioPath)

        guard FileManager.default.fileExists(atPath: audioPath) else {
            print("音频文件不存在")
            return
        }

        // 创建分享文本
        let shareText = """
        🌿 \(bgm.name)

        用WindWhisper生成的自然疗愈音乐
        风格：\(bgm.style.displayName)
        时长：\(formatDuration(bgm.duration))

        #WindWhisper #自然疗愈 #冥想音乐
        """

        let items: [Any] = [shareText, audioURL]

        presentShareSheet(items: items, from: viewController)
    }

    /// 分享录音
    func shareRecording(_ recording: SoundRecording, from viewController: UIViewController? = nil) {
        var items: [Any] = []

        // 分享文本
        let shareText = """
        🎤 发现了\(recording.soundType.displayName)！

        📍 \(recording.locationName ?? "户外")
        ⏱ \(formatDuration(recording.duration))

        用WindWhisper探索自然之声
        #WindWhisper #自然声景
        """
        items.append(shareText)

        // 如果有音频文件，也分享
        if let audioPath = recording.audioFileURL {
            let audioURL = URL(fileURLWithPath: audioPath)
            if FileManager.default.fileExists(atPath: audioPath) {
                items.append(audioURL)
            }
        }

        presentShareSheet(items: items, from: viewController)
    }

    /// 分享成就
    func shareAchievement(title: String, description: String, from viewController: UIViewController? = nil) {
        let shareText = """
        🏆 \(title)

        \(description)

        在WindWhisper中解锁了这个成就！
        #WindWhisper #成就解锁
        """

        presentShareSheet(items: [shareText], from: viewController)
    }

    /// 分享应用邀请
    func shareAppInvite(from viewController: UIViewController? = nil) {
        let shareText = """
        🌿 发现一款超治愈的App - WindWhisper（风语者）

        ✨ 采集户外自然声音
        ✨ AI生成疗愈音乐
        ✨ 打造专属声景花园

        快来和我一起聆听自然的声音吧！
        """

        // 如果有App Store链接，可以添加
        // let appURL = URL(string: "https://apps.apple.com/app/windwhisper/...")!

        presentShareSheet(items: [shareText], from: viewController)
    }

    // MARK: - Private Methods

    private func presentShareSheet(items: [Any], from viewController: UIViewController?) {
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // 排除一些不相关的分享选项
        activityVC.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .markupAsPDF
        ]

        // 获取当前视图控制器
        let presenter = viewController ?? getTopViewController()

        // iPad需要设置popover位置
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter?.view
            popover.sourceRect = CGRect(
                x: presenter?.view.bounds.midX ?? 0,
                y: presenter?.view.bounds.midY ?? 0,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter?.present(activityVC, animated: true)
    }

    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              var topController = window.rootViewController else {
            return nil
        }

        while let presentedVC = topController.presentedViewController {
            topController = presentedVC
        }

        return topController
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - SwiftUI View Extension

struct ShareButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 20))
                .foregroundColor(ZenTheme.textSecondary)
        }
    }
}

// MARK: - Share Sheet View Representable

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
