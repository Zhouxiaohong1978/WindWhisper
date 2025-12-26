//
//  StorageManager.swift
//  WindWhisper
//
//  存储管理器 - UserDefaults存储
//

import Foundation

final class StorageManager {
    // MARK: - Keys

    private enum Keys {
        static let recordings = "windwhisper_recordings"
        static let recentBGMs = "windwhisper_recent_bgms"
        static let userProgress = "windwhisper_user_progress"
        static let dailyTasks = "windwhisper_daily_tasks"
        static let subscriptionInfo = "windwhisper_subscription"
        static let lastTaskGenerationDate = "windwhisper_last_task_date"
    }

    // MARK: - Singleton

    static let shared = StorageManager()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    // MARK: - Recordings

    func saveRecording(_ recording: SoundRecording) {
        var recordings = getRecordings()
        recordings.insert(recording, at: 0)

        // 保留最近50条
        if recordings.count > 50 {
            recordings = Array(recordings.prefix(50))
        }

        saveObject(recordings, forKey: Keys.recordings)

        // 更新进度
        var progress = getUserProgress()
        progress.totalRecordings += 1
        saveUserProgress(progress)
    }

    func getRecordings() -> [SoundRecording] {
        return getObject([SoundRecording].self, forKey: Keys.recordings) ?? []
    }

    func deleteRecording(_ id: UUID) {
        var recordings = getRecordings()
        recordings.removeAll { $0.id == id }
        saveObject(recordings, forKey: Keys.recordings)
    }

    // MARK: - BGMs (最近5首)

    func saveBGM(_ bgm: GeneratedBGM) {
        var bgms = getRecentBGMs()
        bgms.insert(bgm, at: 0)

        // 只保留5首
        if bgms.count > 5 {
            // 删除多余的音频文件
            for bgm in bgms.suffix(from: 5) {
                if let path = bgm.audioFileURL {
                    try? FileManager.default.removeItem(atPath: path)
                }
            }
            bgms = Array(bgms.prefix(5))
        }

        saveObject(bgms, forKey: Keys.recentBGMs)

        // 更新进度
        var progress = getUserProgress()
        progress.totalBGMGenerated += 1
        saveUserProgress(progress)
    }

    func getRecentBGMs() -> [GeneratedBGM] {
        return getObject([GeneratedBGM].self, forKey: Keys.recentBGMs) ?? []
    }

    func deleteBGM(_ id: UUID) {
        var bgms = getRecentBGMs()
        if let bgm = bgms.first(where: { $0.id == id }),
           let path = bgm.audioFileURL {
            try? FileManager.default.removeItem(atPath: path)
        }
        bgms.removeAll { $0.id == id }
        saveObject(bgms, forKey: Keys.recentBGMs)
    }

    // MARK: - User Progress

    func getUserProgress() -> UserProgress {
        return getObject(UserProgress.self, forKey: Keys.userProgress) ?? UserProgress()
    }

    func saveUserProgress(_ progress: UserProgress) {
        saveObject(progress, forKey: Keys.userProgress)
    }

    func addLeaves(_ count: Int) {
        var progress = getUserProgress()
        progress.totalLeaves += count

        // 检查升级
        let newLevel = calculateLevel(leaves: progress.totalLeaves)
        progress.gardenLevel = newLevel

        saveUserProgress(progress)
    }

    private func calculateLevel(leaves: Int) -> Int {
        // 每100叶子升一级
        return max(1, leaves / 100 + 1)
    }

    // MARK: - Daily Tasks

    func getDailyTasks() -> [DailyTask] {
        let tasks = getObject([DailyTask].self, forKey: Keys.dailyTasks) ?? []

        // 检查是否需要生成新任务
        if shouldGenerateNewTasks(existingTasks: tasks) {
            let newTasks = generateDailyTasks()
            saveObject(newTasks, forKey: Keys.dailyTasks)
            defaults.set(Date(), forKey: Keys.lastTaskGenerationDate)
            return newTasks
        }

        return tasks
    }

    func updateTask(_ task: DailyTask) {
        var tasks = getDailyTasks()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task

            // 检查是否完成
            if task.isCompleted {
                addLeaves(task.rewardLeaves)
            }
        }
        saveObject(tasks, forKey: Keys.dailyTasks)
    }

    private func shouldGenerateNewTasks(existingTasks: [DailyTask]) -> Bool {
        guard let lastDate = defaults.object(forKey: Keys.lastTaskGenerationDate) as? Date else {
            return true
        }

        return !Calendar.current.isDateInToday(lastDate)
    }

    private func generateDailyTasks() -> [DailyTask] {
        return [
            DailyTask(
                title: "声音探索者",
                description: "采集3种不同环境的声音",
                targetCount: 3,
                rewardLeaves: 50
            ),
            DailyTask(
                title: "音乐创作者",
                description: "生成2首疗愈音乐",
                targetCount: 2,
                rewardLeaves: 30
            ),
            DailyTask(
                title: "冥想时刻",
                description: "聆听疗愈音乐5分钟",
                targetCount: 5,
                rewardLeaves: 20
            )
        ]
    }

    // MARK: - Subscription

    func getSubscriptionInfo() -> SubscriptionInfo {
        return getObject(SubscriptionInfo.self, forKey: Keys.subscriptionInfo) ?? SubscriptionInfo()
    }

    func saveSubscriptionInfo(_ info: SubscriptionInfo) {
        saveObject(info, forKey: Keys.subscriptionInfo)
    }

    // MARK: - Helper Methods

    private func saveObject<T: Encodable>(_ object: T, forKey key: String) {
        if let data = try? encoder.encode(object) {
            defaults.set(data, forKey: key)
        }
    }

    private func getObject<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    // MARK: - Cleanup

    func clearAllData() {
        defaults.removeObject(forKey: Keys.recordings)
        defaults.removeObject(forKey: Keys.recentBGMs)
        defaults.removeObject(forKey: Keys.userProgress)
        defaults.removeObject(forKey: Keys.dailyTasks)
        defaults.removeObject(forKey: Keys.lastTaskGenerationDate)

        // 删除音频文件
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if let files = try? FileManager.default.contentsOfDirectory(atPath: documentsPath.path) {
            for file in files where file.hasSuffix(".wav") {
                try? FileManager.default.removeItem(atPath: documentsPath.appendingPathComponent(file).path)
            }
        }
    }
}
