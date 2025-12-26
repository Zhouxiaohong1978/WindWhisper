//
//  AudioCaptureService.swift
//  WindWhisper
//
//  音频采集服务 - AVAudioEngine实时录音
//

import AVFoundation
import Combine

@MainActor
final class AudioCaptureService: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var isRecording = false
    @Published private(set) var audioLevel: Float = 0.0
    @Published private(set) var recordingDuration: TimeInterval = 0
    @Published private(set) var permissionGranted = false
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties

    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioFile: AVAudioFile?
    private var recordingTimer: Timer?
    private var startTime: Date?

    private let bufferSize: AVAudioFrameCount = 1024

    // 音频数据回调
    var onAudioBuffer: (([Float]) -> Void)?

    // MARK: - Singleton

    static let shared = AudioCaptureService()

    private init() {
        Task {
            await checkPermission()
        }
    }

    // MARK: - Permission

    func checkPermission() async {
        if #available(iOS 17.0, *) {
            let status = AVAudioApplication.shared.recordPermission
            switch status {
            case .granted:
                permissionGranted = true
            case .denied:
                permissionGranted = false
            case .undetermined:
                permissionGranted = await requestPermission()
            @unknown default:
                permissionGranted = false
            }
        } else {
            let status = AVAudioSession.sharedInstance().recordPermission
            switch status {
            case .granted:
                permissionGranted = true
            case .denied:
                permissionGranted = false
            case .undetermined:
                permissionGranted = await requestPermission()
            @unknown default:
                permissionGranted = false
            }
        }
    }

    private func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    // MARK: - Recording Control

    func startRecording() async throws -> URL {
        guard permissionGranted else {
            throw AudioCaptureError.permissionDenied
        }

        // 配置音频会话
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)

        // 创建音频引擎
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else {
            throw AudioCaptureError.engineCreationFailed
        }

        inputNode = engine.inputNode
        guard let input = inputNode else {
            throw AudioCaptureError.inputNodeUnavailable
        }

        let format = input.outputFormat(forBus: 0)

        // 创建录音文件
        let fileURL = getRecordingFileURL()
        audioFile = try AVAudioFile(forWriting: fileURL, settings: format.settings)

        // 安装tap获取音频数据
        input.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            Task { @MainActor in
                self?.processAudioBuffer(buffer)
            }

            // 写入文件
            try? self?.audioFile?.write(from: buffer)
        }

        // 启动引擎
        try engine.start()

        isRecording = true
        startTime = Date()
        errorMessage = nil

        // 启动计时器
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let start = self.startTime else { return }
                self.recordingDuration = Date().timeIntervalSince(start)
            }
        }

        return fileURL
    }

    func stopRecording() -> SoundRecording? {
        recordingTimer?.invalidate()
        recordingTimer = nil

        inputNode?.removeTap(onBus: 0)
        audioEngine?.stop()

        let duration = recordingDuration

        isRecording = false
        audioLevel = 0
        recordingDuration = 0
        startTime = nil

        // 停用音频会话
        try? AVAudioSession.sharedInstance().setActive(false)

        guard duration > 0.5 else { return nil }

        // 创建录音记录（分类将在后续处理）
        return SoundRecording(
            soundType: .unknown,
            duration: duration,
            audioFileURL: audioFile?.url.path
        )
    }

    // MARK: - Audio Processing

    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // 计算RMS音量
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))

        // 转换为0-1范围
        let level = min(1.0, max(0.0, rms * 5))
        audioLevel = level

        // 提取特征用于分类
        var samples = [Float](repeating: 0, count: frameLength)
        for i in 0..<frameLength {
            samples[i] = channelData[i]
        }
        onAudioBuffer?(samples)
    }

    // MARK: - Helpers

    private func getRecordingFileURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "recording_\(Date().timeIntervalSince1970).wav"
        return documentsPath.appendingPathComponent(fileName)
    }
}

// MARK: - Errors

enum AudioCaptureError: LocalizedError {
    case permissionDenied
    case engineCreationFailed
    case inputNodeUnavailable
    case recordingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "需要麦克风权限才能录音"
        case .engineCreationFailed:
            return "音频引擎创建失败"
        case .inputNodeUnavailable:
            return "无法访问麦克风输入"
        case .recordingFailed:
            return "录音失败"
        }
    }
}
