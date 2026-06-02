# QuotaBar Quickstart / 快速启动

## 1. 构建 / Build

中文：在项目根目录运行：

English: Run from the project root:

```bash
./install.sh --bundle-only --rebuild
open build/QuotaBar.app
```

中文：安装到 `/Applications`：

English: Install into `/Applications`:

```bash
./install.sh
```

## 2. 打开界面 / Open The UI

中文：点击 macOS 状态栏里的 QuotaBar 电池图标。

English: Click the QuotaBar battery icon in the macOS menu bar.

中文：Dock 图标会打开主窗口；状态栏弹窗用于快速查看额度。

English: The Dock icon opens the main window; the menu bar popover gives quick quota visibility.

## 3. 配置凭据 / Configure Credentials

中文：打开主窗口左侧的 `配置凭据`。

English: Open `Credentials` from the main window sidebar.

中文：普通 provider 使用 API Key；讯飞星火、火山引擎、OpenCode Go 使用控制台会话 Cookie，不是模型调用 API key。

English: Normal providers use API keys. XFYun, Volcengine, and OpenCode Go use dashboard-session cookies, not model invocation API keys.

## 4. 从 .env 导入 / Import From .env

中文：点击页面内 `从 .env 导入`，选择包含变量的文件。

English: Click the in-page `Import from .env` action and choose a file containing variables.

示例 / Example:

```env
TAVILY_API_KEY=...
BRAVE_API_KEY=...
DEEPSEEK_API_KEY=...
XFYUN_CODING_PLAN_COOKIE=...
VOLCENGINE_CODING_PLAN_COOKIE=...
OPENCODE_GO_COOKIE=...
```

中文：上面的 `...` 是占位符。不要提交真实 `.env`、Cookie 或 API Key。

English: The `...` values are placeholders. Do not commit real `.env` files, cookies, or API keys.

## 5. 观察额度 / Monitor Quotas

中文：左侧 `观察额度` 页面展示各 provider 的额度概览。

English: The `Quota Overview` page shows provider-level quota summaries.

中文：状态栏弹窗按 `AI Search` 和 `LLM` 分组，可折叠 provider，并支持单个 provider 刷新。

English: The menu bar popover groups providers by `AI Search` and `LLM`, supports collapsible providers, and refreshes one provider at a time.

## 6. 语言与外观 / Language And Appearance

中文：在 `语言与外观` 页面切换英文/简体中文，并调整状态栏透明度。

English: Use `Language & Appearance` to switch English/Simplified Chinese and adjust menu bar popover transparency.

## 7. 本地数据位置 / Local Data Locations

中文：真实凭据文件：

English: Secret file:

```text
~/Library/Application Support/QuotaBar/secrets.json
```

中文：该文件不属于代码仓库，不应该推送到 GitHub。

English: This file is outside the repository and should never be pushed to GitHub.

## 8. 测试 / Test

```bash
bash Tests/run_behavior_tests.sh
```

中文：如果只是安装已有 bundle，不需要重新构建：

English: To install the existing bundle without rebuilding:

```bash
./install.sh
```

中文：如果源码改了，需要显式重建：

English: If source code changed, rebuild explicitly:

```bash
./install.sh --rebuild
```
