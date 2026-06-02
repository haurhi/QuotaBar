# QuotaBar

中文：QuotaBar 是一个 macOS 状态栏应用，用来观察搜索 API 与 LLM coding plan 的额度状态，减少反复登录各家后台查询额度的成本。

English: QuotaBar is a macOS menu bar app for monitoring search API and LLM coding-plan quota status without repeatedly logging in to provider dashboards.

![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## 功能 / Features

- 中文：状态栏磨砂玻璃弹窗，按 `AI Search` 和 `LLM` 分组展示额度。
- English: Frosted-glass menu bar popover grouped by `AI Search` and `LLM`.
- 中文：支持多个 provider、多个凭据，并按 provider 内剩余额度排序。
- English: Supports multiple providers and credentials, with credentials sorted by remaining quota inside each provider.
- 中文：支持 API Key 与控制台会话 Cookie 两类凭据。
- English: Supports both API keys and dashboard-session cookies.
- 中文：可从 `.env` 或 `~/.claude/settings.json` 导入支持的凭据。
- English: Can import supported credentials from `.env` or `~/.claude/settings.json`.
- 中文：真实凭据存储在 `~/Library/Application Support/QuotaBar/secrets.json`，权限为 `0600`；偏好设置只保存 metadata。
- English: Secrets are stored in `~/Library/Application Support/QuotaBar/secrets.json` with `0600` permissions; preferences store metadata only.

## 支持的服务商 / Supported Providers

### AI Search

| Provider | 中文说明 | English Notes |
| --- | --- | --- |
| Tavily | 月度 credits，通常每月 1 日重置 | Monthly credits, normally reset on day 1 |
| Brave Search | 搜索响应 header 额度 | Quota from search response headers |
| SerpAPI | Account API | Account API |
| Serper | Account API | Account API |
| Exa | 公开 search key 不直接暴露用量 | Search keys do not expose usage directly |
| Bocha | 余额 API | Balance API |
| AnySearch | 当前按免费无限处理 | Treated as free unlimited usage |
| Querit | Dashboard 手动查看 | Manual dashboard check |
| 微信搜索 | 账户剩余金额 | Remaining account balance |

### LLM / Coding Plan

| Provider | 凭据类型 | Credential Type |
| --- | --- | --- |
| DeepSeek | API Key | API Key |
| Anthropic | Dashboard 手动查看 | Manual dashboard check |
| 讯飞星火 | 控制台会话 Cookie | Dashboard session cookie |
| 火山引擎 | 控制台会话 Cookie | Dashboard session cookie |
| OpenCode Go | 控制台会话 Cookie | Dashboard session cookie |

## 要求 / Requirements

- 中文：macOS 14.0 或更高版本，Xcode/Command Line Tools，Swift 5.9。
- English: macOS 14.0 or newer, Xcode/Command Line Tools, and Swift 5.9.

## 构建与安装 / Build And Install

```bash
./install.sh --bundle-only --rebuild
open build/QuotaBar.app
```

中文：复制到 `/Applications`：

English: Install into `/Applications`:

```bash
./install.sh
```

中文：`./install.sh` 默认复用已有 `build/QuotaBar.app`，需要重新构建时使用 `--rebuild`。

English: `./install.sh` reuses the existing `build/QuotaBar.app` by default. Use `--rebuild` when you need a fresh build.

## 使用 / Usage

1. 中文：点击状态栏电池图标打开额度面板。
   English: Click the menu bar battery icon to open the quota panel.
2. 中文：进入 `配置凭据`，添加凭据或从 `.env` 导入。
   English: Open `Credentials` to add credentials or import from `.env`.
3. 中文：普通服务商填写 API Key；讯飞星火、火山引擎、OpenCode Go 填控制台会话 Cookie。
   English: Use API keys for normal providers; use dashboard-session cookies for XFYun, Volcengine, and OpenCode Go.
4. 中文：点击单个 provider 的刷新按钮更新该 provider。
   English: Click a provider-level refresh button to update that provider.

## .env 导入 / .env Import

中文：支持的变量名包括：

English: Supported variable names include:

```env
TAVILY_API_KEY=...
BRAVE_API_KEY=...
SERPAPI_API_KEY=...
SERPER_API_KEY=...
EXA_API_KEY=...
BOCHA_API_KEY=...
ANYSEARCH_API_KEY=...
QUERIT_API_KEY=...
WX_MP_SEARCH_API_KEY=...
WECHAT_API_KEY=...
DEEPSEEK_API_KEY=...
XFYUN_CODING_PLAN_COOKIE=...
VOLCENGINE_CODING_PLAN_COOKIE=...
OPENCODE_GO_COOKIE=...
```

中文：Dashboard session provider 请只粘贴 Cookie header value，或使用 JSON 占位结构。不要把真实 Cookie 提交到 Git。

English: For dashboard-session providers, paste only the Cookie header value or use a JSON placeholder shape. Never commit real cookies to Git.

```env
VOLCENGINE_CODING_PLAN_COOKIE='{"cookie":"<cookie-header-value>","csrfToken":"<csrf-token>","projectName":"default"}'
OPENCODE_GO_COOKIE='{"cookie":"<cookie-header-value>","workspaceID":"wrk_example","serverID":"server-example","serverInstance":"server-fn:11"}'
```

## Claude Code 初始化 / Claude Code Import

中文：首次启动且尚未配置凭据时，QuotaBar 会读取 `~/.claude/settings.json` 的 `env` 字段并导入支持的变量。

English: On first launch, if no credentials are configured, QuotaBar reads the `env` section from `~/.claude/settings.json` and imports supported variables.

中文：导入后的真实值进入 QuotaBar 的本地 secret 文件；源码和偏好设置不保存真实密钥。

English: Imported secret values go into QuotaBar's local secret file; source code and preferences do not store real keys.

## 架构 / Architecture

```text
QuotaBar/
├── Models/
│   ├── APIKey.swift
│   ├── AppAppearance.swift
│   ├── AppLanguage.swift
│   └── QuotaMonitor.swift
├── Services/
│   ├── APIKeyStore.swift
│   ├── FileSecretStore.swift
│   ├── QuotaService.swift
│   ├── EnvImporter.swift
│   └── DashboardReauth.swift
├── Views/
│   ├── Components.swift
│   ├── MenuContentView.swift
│   └── SettingsView.swift
├── AppDelegate.swift
└── QuotaBarApp.swift
```

## 新增 Provider / Adding A Provider

中文：新增 provider 通常需要修改：

English: Adding a provider usually requires changes in:

- `QuotaBar/Models/APIKey.swift`: provider case, category, icon, credential type, dashboard URL, reset summary.
- `QuotaBar/Services/EnvImporter.swift`: environment-variable detection.
- `QuotaBar/Services/QuotaService.swift`: quota check and parser.
- `QuotaBar/Assets.xcassets/ProviderIcons/`: provider icon assets.
- `Tests/run_behavior_tests.sh`: behavior and parser coverage.

## 测试 / Tests

```bash
bash Tests/run_behavior_tests.sh
```

中文：该脚本会做源码安全检查、图标资源检查、导入/解析行为测试、SwiftPM 编译和 bundle 构建。

English: The script runs source safety checks, provider icon checks, importer/parser behavior tests, SwiftPM build, and bundle creation.

## 隐私 / Privacy

- 中文：不内置任何真实 API Key、Cookie 或 token。
- English: No real API keys, cookies, or tokens are embedded.
- 中文：真实凭据仅存储在用户本机 `Application Support/QuotaBar`。
- English: Real credentials are stored only under the user's local `Application Support/QuotaBar`.
- 中文：所有请求直接发送到对应 provider，没有中间服务器。
- English: All requests go directly to the provider; there is no proxy server.

## License

MIT
