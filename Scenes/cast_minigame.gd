extends Node2D

signal cast_finished(distance: float)
signal bite

# --- tuning ---
@export var fill_speed: float = 90.0
@export var twitchy_above: float = 85.0
@export var twitchy_multiplier: float = 3.0
@export var release_lag: float = 0.25
@export var overshoot_distance: float = 5.0
@export var overshoot_drain_time: float = 0.4
@export var bite_wait_min: float = 2
@export var bite_wait_max: float = 5
@export var idle_blink_speed: float = 0.5
@export var bite_blink_speed: float = 0.15
@export var nice_threshold: float = 85.0
@export var perfect_threshold: float = 98.0
@export var fade_time: float = 0.5
@export var fishing_scene: String = "res://Scenes/FishingMinigame.tscn"

var power := 0.0
var charging := false
var lagging := false
var waiting_for_bite := false
var cast_id := 0
var blink_tween: Tween


func _ready() -> void:
	%FishCounter.text = str(GameState.fish_count) + " Fih"
	%Fade.modulate.a = 0.0
	_reset_for_cast()


func _reset_for_cast() -> void:
	cast_id += 1
	power = 0.0
	charging = false
	lagging = false
	waiting_for_bite = false
	%TextureProgressBar.value = 0
	%DistanceLabel.text = ""
	_set_prompt("Hold SPACE to cast", idle_blink_speed)


func _process(delta: float) -> void:
	if not (charging or lagging):
		return
	var speed := fill_speed
	if power > twitchy_above:
		speed *= twitchy_multiplier
	power += speed * delta
	%TextureProgressBar.value = power
	if power >= 100.0:
		_overshoot()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cast"):
		if waiting_for_bite:
			print("RECAST?")
			_reset_for_cast()
		if not charging and not lagging:
			charging = true
			power = 0.0
			_set_prompt("")
	elif event.is_action_released("cast") and charging:
		charging = false
		lagging = true
		var my_id := cast_id
		await get_tree().create_timer(release_lag).timeout
		if my_id != cast_id or not lagging:
			return
		lagging = false
		_finish(power)


func _overshoot() -> void:
	charging = false
	lagging = false
	print("OVERSHOOT")
	var my_id := cast_id
	var t := create_tween()
	t.tween_property(%TextureProgressBar, "value", overshoot_distance, overshoot_drain_time)
	await t.finished
	if my_id != cast_id:
		return
	_finish(overshoot_distance)


func _finish(distance: float) -> void:
	print("cast distance: ", distance)
	GameState.cast_distance = distance
	%DistanceLabel.text = "Cast: %d / 100  %s" % [int(distance), _rating(distance)]
	if distance >= perfect_threshold:
		%PerfectSound.play()
	elif distance >= nice_threshold:
		%NiceSound.play()
	cast_finished.emit(distance)
	_wait_for_bite()


func _rating(d: float) -> String:
	if d >= perfect_threshold: return "Perfect"
	if d >= nice_threshold: return "Nice"
	if d >= 60.0: return "Good"
	if d >= 30.0: return "Meh"
	return "Weak"


func _wait_for_bite() -> void:
	var my_id := cast_id
	waiting_for_bite = true
	_set_prompt("Hold Space to Recast\n Or Wait for Bite!", idle_blink_speed)
	var wait := randf_range(bite_wait_min, bite_wait_max)
	print("bite in %.1f s" % wait)
	await get_tree().create_timer(wait).timeout
	if my_id != cast_id: return
	waiting_for_bite = false
	_set_prompt("BITE!", bite_blink_speed)
	print("BITE")
	bite.emit()
	_go_to_fishing()


func _go_to_fishing() -> void:
	await get_tree().create_timer(0.6).timeout
	var t := create_tween()
	t.tween_property(%Fade, "modulate:a", 1.0, fade_time)
	await t.finished
	get_tree().change_scene_to_file(fishing_scene)


# --- prompt helpers ---
func _set_prompt(text: String, blink_speed: float = 0.0) -> void:
	_stop_blink()
	%CastPrompt.text = text
	if blink_speed > 0.0:
		blink_tween = create_tween().set_loops()
		blink_tween.tween_property(%CastPrompt, "modulate:a", 0.2, blink_speed)
		blink_tween.tween_property(%CastPrompt, "modulate:a", 1.0, blink_speed)


func _stop_blink() -> void:
	if blink_tween:
		blink_tween.kill()
		blink_tween = null
	%CastPrompt.modulate.a = 1.0
