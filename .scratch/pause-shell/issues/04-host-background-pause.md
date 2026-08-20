# 04: 切到后台会进入同一张暂停层

**What to build:** 战斗中宿主报进入后台时，自动打开和点「暂停」同一张层；回前台仍停着，必须点「继续」。只用 `_HTYF_SDK` 的生命周期回调（`lifecycle` 推送 / `set_host_lifecycle_callback`），不接到出怪、伤害、商店。编辑器里用同一套「打开暂停」入口接 Godot 的 application paused/focus-out，方便 F5 验。

**Blocked by:** 01 战斗中能暂停、能继续

**Status:** ready-for-agent

- [ ] 战斗中模拟/收到进入后台 → 暂停层出现，计时停
- [ ] 回前台不会自动继续，必须点「继续」
- [ ] 非战斗（选角/升级/商店/结算）收到后台事件，不额外弹出暂停层
- [ ] 没有把 SDK 接到出怪、伤害或商店购买
