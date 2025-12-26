//
//  SoundModels.swift
//  WindWhisper
//
//  数据模型定义
//

import Foundation
import CoreLocation

// MARK: - 声音类型分类

enum SoundType: String, Codable, CaseIterable {
    case wind = "wind"
    case bird = "bird"
    case rain = "rain"
    case stream = "stream"
    case leaves = "leaves"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .wind: return "风声"
        case .bird: return "鸟鸣"
        case .rain: return "雨声"
        case .stream: return "溪流"
        case .leaves: return "树叶"
        case .unknown: return "未知"
        }
    }

    var icon: String {
        switch self {
        case .wind: return "wind"
        case .bird: return "bird.fill"
        case .rain: return "drop.fill"
        case .stream: return "water.waves"
        case .leaves: return "leaf.fill"
        case .unknown: return "waveform"
        }
    }
}

// MARK: - 录音记录

struct SoundRecording: Codable, Identifiable {
    let id: UUID
    let soundType: SoundType
    let duration: TimeInterval
    let timestamp: Date
    let locationName: String?
    let latitude: Double?
    let longitude: Double?
    let audioFileURL: String?
    let confidence: Float

    init(
        id: UUID = UUID(),
        soundType: SoundType,
        duration: TimeInterval,
        timestamp: Date = Date(),
        locationName: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        audioFileURL: String? = nil,
        confidence: Float = 0.0
    ) {
        self.id = id
        self.soundType = soundType
        self.duration = duration
        self.timestamp = timestamp
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.audioFileURL = audioFileURL
        self.confidence = confidence
    }
}

// MARK: - 生成的BGM

struct GeneratedBGM: Codable, Identifiable {
    let id: UUID
    let name: String
    let style: BGMStyle
    let basedOnRecording: UUID?
    let duration: TimeInterval
    let createdAt: Date
    let audioFileURL: String?

    init(
        id: UUID = UUID(),
        name: String,
        style: BGMStyle,
        basedOnRecording: UUID? = nil,
        duration: TimeInterval,
        createdAt: Date = Date(),
        audioFileURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.style = style
        self.basedOnRecording = basedOnRecording
        self.duration = duration
        self.createdAt = createdAt
        self.audioFileURL = audioFileURL
    }
}

enum BGMStyle: String, Codable, CaseIterable {
    case gentle = "gentle"
    case meditation = "meditation"
    case nature = "nature"
    case deepSleep = "deepSleep"

    var displayName: String {
        switch self {
        case .gentle: return "轻柔"
        case .meditation: return "冥想"
        case .nature: return "自然"
        case .deepSleep: return "深眠"
        }
    }
}

// MARK: - 每日任务

struct DailyTask: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let targetCount: Int
    var currentCount: Int
    let rewardLeaves: Int
    let date: Date
    var isCompleted: Bool

    var progress: Float {
        return Float(currentCount) / Float(targetCount)
    }

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        targetCount: Int,
        currentCount: Int = 0,
        rewardLeaves: Int,
        date: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.rewardLeaves = rewardLeaves
        self.date = date
        self.isCompleted = isCompleted
    }
}

// MARK: - 用户进度

struct UserProgress: Codable {
    var totalLeaves: Int
    var gardenLevel: Int
    var totalRecordings: Int
    var totalBGMGenerated: Int
    var consecutiveDays: Int
    var lastActiveDate: Date?

    init() {
        self.totalLeaves = 0
        self.gardenLevel = 1
        self.totalRecordings = 0
        self.totalBGMGenerated = 0
        self.consecutiveDays = 0
        self.lastActiveDate = nil
    }
}

// MARK: - 订阅状态

enum SubscriptionStatus: String, Codable {
    case free = "free"
    case premium = "premium"
    case expired = "expired"
}

struct SubscriptionInfo: Codable {
    var status: SubscriptionStatus
    var expirationDate: Date?
    var productId: String?

    init() {
        self.status = .free
        self.expirationDate = nil
        self.productId = nil
    }
}
