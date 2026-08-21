# 土豆兄弟

Godot 4.5 横屏生存射击小游戏，可在编辑器直接运行，也可通过红糖云服 CLI（`htyf`）打包或真机调试。

主场景：`res://scenes/arena/arena.tscn`  
小程序配置：根目录 `app.json`（`htyf` 字段）

---

## 环境要求

- [Godot 4.5](https://godotengine.org/download)（与 `project.godot` 的 `config/features` 一致）
- Node.js >= 16.20.0（仅打包 / 真机调试需要）
- 真机调试时：电脑已安装依赖，手机已安装红糖云服 App，且手机与电脑在同一局域网（或已配置端口转发）

---

## 正常使用（编辑器开发）

1. 用 Godot 4.5 打开本仓库根目录（识别到 `project.godot` 即可）。
2. 首次打开会导入资源，等导入完成。
3. 按 **F5**（或点击运行）启动游戏。
4. 必须同时选择角色和武器后，才能点 Continue 进入战斗。

### 操作

| 平台 | 移动 | 冲刺 |
| --- | --- | --- |
| 桌面 | WASD / 方向键 | 空格 |
| 触屏 / 编辑器预览 | 按住左半屏任意位置出现虚拟摇杆 | 右下角「冲刺」 |

暂停、选角、升级、商店界面会自动隐藏虚拟控件。编辑器里也会显示摇杆，方便用鼠标试手感。

### 常用路径

- 游戏逻辑：`scenes/`、`resources/`、`autoloads/`
- 移动端控件：`scenes/ui/mobile_controls/`
- 红糖云服 SDK：`_HTYF_SDK/`

改完脚本或场景后，在编辑器里重新运行即可验证，无需先跑 `htyf`。

---

## 安装 Node 依赖

打包和真机调试走 `@htyf-mp/cli`。在项目根目录执行：

```bash
npm install
```

`package.json` 中的脚本：

```json
"scripts": {
  "htyf": "htyf"
}
```

`npm run htyf` 会调用本地安装的 CLI（`@htyf-mp/cli`），读取根目录 `app.json` 里的 `htyf` 配置。必须在**含有 `app.json` 的项目根**执行。

等价写法：

```bash
npx @htyf-mp/cli
# 需要详细日志时
npx @htyf-mp/cli --debug
```

---

## 调用 htyf（交互菜单）

```bash
npm run htyf
```

进入菜单后常见选项：

| 选项 | 作用 |
| --- | --- |
| 🔍 小程序 - 打包小程序 | 导出 Godot 资源并打 ZIP（如 `dist.*.dgz`） |
| 📦 小程序 - 真机调试 | 构建 + 启动本地调试服务 + 显示二维码 |
| 🧹 清理模式 - 清理临时文件 | 清理 `dist`、`.htyf`、日志、缓存 |
| 👋 退出 | 退出 CLI |

本仓库根目录有 `project.godot`，CLI 会按 **Godot 游戏** 流程导出，而不是普通 RN/Web 小程序。

版本号：按提示输入 `x.y.z`，或直接回车，使用当前 `app.json.htyf.version` 自动递增。确认后会写回 `app.json`。

不进入菜单的清理示例：

```bash
npx @htyf-mp/cli --clean all     # 全部
npx @htyf-mp/cli --clean build   # 仅 dist
npx @htyf-mp/cli --clean temp    # 仅 .htyf
npx @htyf-mp/cli --help
```

---

## 真机调试

1. 确保已执行 `npm install`。
2. 在项目根运行：

   ```bash
   npm run htyf
   ```

3. 选择 **📦 小程序 - 真机调试**，按提示确认版本号。
4. 等待 Godot 导出与构建完成。CLI 会启动本地服务，并在终端显示二维码；同时会更新调试相关配置。
5. 打开手机上的 **红糖云服 App**，扫描二维码进入本游戏。

注意：

- 手机与电脑需同一局域网，否则扫码后无法拉到本地资源。
- 构建产物在 `dist/`，临时文件与日志在 `.htyf/`（均已 gitignore）。
- 横屏已在 `app.json` 中配置为 `"rotate": "landscape"`，与项目 `window/handheld/orientation=4` 一致。
- 具体扫码入口以红糖云服 App 当前版本为准。官方说明：[快速开始](https://mp.dagouzhi.com/docs)。

---

## 打包发布

同样执行 `npm run htyf`，选择 **🔍 小程序 - 打包小程序**。

完成后将 `dist` 中的产物上传到 `app.json` 里 `zipUrl` 对应的地址，供线上拉取。当前配置摘要：

| 字段 | 含义 | 当前值 |
| --- | --- | --- |
| `type` | 项目类型 | `game` |
| `name` | 展示名 | `土豆兄弟` |
| `version` | 版本号 | `0.0.2`（CLI 可能改写） |
| `appid` | 小程序 ID | `htyfappf49da0bb73f392e688e9754211` |
| `rotate` | 屏幕方向 | `landscape` |
| `zipUrl` | 资源包地址 | 见 `app.json`（`[PLATFORM]` 由平台替换） |
| `appUrlConfig` | 线上配置地址 | 见 `app.json` |

不要手改 `dist/app.json`，它是构建输出。改配置请编辑根目录 `app.json`。

---

## 操作验收

- 编辑器：F5 后能选角、进战斗、WASD 移动、空格冲刺。
- 触屏 / 真机：左半屏摇杆移动，右下角冲刺；中文 UI 正常显示。
- `npm run htyf`：能打开 CLI 菜单；真机调试能出二维码，App 扫码后能进游戏。
