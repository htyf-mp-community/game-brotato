# 03: 开局金币显示为 20

**What to build:** 选角和开打时金币 HUD 为 20。`RunState.STARTING_COINS` 已是 20；若 `coins_bag` 场景占位仍是「30」，改掉以免编辑器和第一帧看起来像 30。

**Blocked by:** None (can start immediately)

**Status:** done

- [x] 开局 / 再来重置后 `Global.coins` 为 20，HUD 显示 20
- [x] `coins_bag` 场景里的占位数字不是 30
- [x] 没有改 `gold_drop`、没有改商店物价
