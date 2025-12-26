# EarthLord (地球新主)

一款末日主题的 iOS 应用，使用纯 SwiftUI 构建。

## 功能特性

- 地图模块 - 查看和探索地图
- 领地模块 - 管理你的领地
- 个人中心 - 查看个人信息
- 更多功能 - 扩展功能入口

## 技术栈

- **开发语言:** Swift 5.0
- **UI 框架:** SwiftUI
- **架构模式:** MVVM
- **最低支持:** iOS 16.6

## 项目结构

```
EarthLord/
├── EarthLordApp.swift          # 应用入口
├── ContentView.swift           # 备用入口视图
├── Theme/
│   └── ApocalypseTheme.swift   # 末日主题配色
├── Components/
│   └── PlaceholderView.swift   # 可复用占位组件
└── Views/
    ├── RootView.swift          # 启动页 → 主界面过渡控制
    ├── SplashView.swift        # 带呼吸动画的启动页
    ├── MainTabView.swift       # 四标签页导航
    └── Tabs/
        ├── MapTabView.swift        # 地图页
        ├── TerritoryTabView.swift  # 领地页
        ├── ProfileTabView.swift    # 个人页
        └── MoreTabView.swift       # 更多页
```

## 主题配色

应用采用末日风格配色方案：

| 颜色 | 用途 |
|------|------|
| #141416 | 背景色 (近黑) |
| #FF6619 | 主色调 (橙色) |
| 白色 | 主要文字 |
| 60% 白色 | 次要文字 |

## 运行项目

1. 使用 Xcode 打开 `EarthLord.xcodeproj`
2. 选择模拟器或真机
3. 按 `Cmd + R` 运行

## 开发规范

- 所有用户可见文本使用 `LocalizedStringKey` 支持国际化
- 每个视图文件包含 `#Preview` 宏
- 颜色必须使用 `ApocalypseTheme` 常量
- UI 文本使用简体中文

## License

MIT License
