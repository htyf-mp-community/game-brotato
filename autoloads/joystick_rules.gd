class_name JoystickRules
extends RefCounted


static func top_bar_exclusion(hud_rects: Array, stick_area: Rect2) -> Rect2:
	if hud_rects.is_empty() or stick_area.size.x <= 0.0:
		return Rect2()
	var top := INF
	var bottom := -INF
	for rect in hud_rects:
		var r: Rect2 = rect
		top = minf(top, r.position.y)
		bottom = maxf(bottom, r.position.y + r.size.y)
	if bottom <= top:
		return Rect2()
	return Rect2(stick_area.position.x, top, stick_area.size.x, bottom - top)


static func can_begin_press(point: Vector2, stick_area: Rect2, excluded: Rect2) -> bool:
	if not stick_area.has_point(point):
		return false
	if excluded.size.x > 0.0 and excluded.size.y > 0.0 and excluded.has_point(point):
		return false
	return true
