class_name WaveHud
extends RefCounted

enum PipState {
	UPCOMING,
	CURRENT,
	COMPLETED,
}


static func format_wave_text(wave_index: int, last_wave: int) -> String:
	return "第 %s / %s 波" % [wave_index, last_wave]


static func pip_state(pip_index: int, wave_index: int, last_wave: int, wave_finished: bool) -> PipState:
	if last_wave <= 0:
		return PipState.UPCOMING
	if wave_finished and wave_index >= last_wave:
		return PipState.COMPLETED
	if wave_finished:
		if pip_index <= wave_index:
			return PipState.COMPLETED
		return PipState.UPCOMING
	if pip_index < wave_index:
		return PipState.COMPLETED
	if pip_index == wave_index:
		return PipState.CURRENT
	return PipState.UPCOMING
