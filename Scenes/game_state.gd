extends Node

var fish_count: int = 0
var cast_distance: float = 0.0
var current_fish: FishData = null
var spawn_spinning_fish_next_cast: bool = false
var line_end: Vector2 = Vector2.ZERO

var fishing_start_time: int = -1


func start_fishing_timer() -> void:
	# Only record the first cast's time.
	if fishing_start_time == -1:
		fishing_start_time = Time.get_ticks_msec()


func get_fishing_time() -> float:
	if fishing_start_time == -1:
		return 0.0

	var elapsed_msec: int = (
		Time.get_ticks_msec() - fishing_start_time
	)

	return elapsed_msec / 1000.0


func reset_fishing_timer() -> void:
	fishing_start_time = -1
