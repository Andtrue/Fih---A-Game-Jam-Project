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
# --- rod animation (degrees / seconds) ---
@export var windup_angle: float = 70.0
@export var windup_time: float = 0.3
@export var whip_angle: float = 60.0
@export var whip_skew: float = 20.0
@export var whip_squash: float = 0.45
@export var whip_time: float = 0.1
@export var settle_time: float = 0.15
@export var return_time: float = 0.35
# --- line and bait ---
@export var idle_hang: float = 60.0                      # px the bait dangles below the tip when idle
@export var land_near_offset: Vector2 = Vector2(-150, 120)  # 0 cast: offset from idle tip (negative x = left)
@export var land_far_offset: Vector2 = Vector2(-450, -40)   # 100 cast: offset from idle tip
@export var line_width: float = 2.0
@export var line_color: Color = Color(0.9, 0.9, 0.9)
@export var line_sag: float = 25.0
@export var fly_time: float = 0.45
var power := 0.0
var charging := false
var lagging := false
var waiting_for_bite := false
var locked := false
var cast_id := 0
var blink_tween: Tween
var rod_tween: Tween
var bait_tween: Tween
var rod_base_scale: Vector2
var tip_idle: Vector2
var line_end: Vector2
var bait_in_water := false
func _ready() -> void:
	rod_base_scale = %FishingRod.scale
	tip_idle = %Tip.global_position
	# draw order: line under rod, bait on top
	%FishingLine.top_level = true
	%FishingLine.position = Vector2.ZERO
	%FishingLine.z_index = 1
	%FishingLine.width = line_width
	%FishingLine.default_color = line_color
	%FishingRod.z_index = 2
	%Bait.z_index = 3
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
	_rod_reset()
	_bait_reset()
	_set_prompt("Hold SPACE to cast", idle_blink_speed)
func _process(delta: float) -> void:
	_update_line()
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
	if locked:
		return
	if event.is_action_pressed("cast"):
		if waiting_for_bite:
			print("RECAST?")
			_reset_for_cast()
		if not charging and not lagging:
			charging = true
			power = 0.0
			_set_prompt("")
			_rod_windup()
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
	_rod_cast()
	_bait_cast(distance)
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
	locked = true
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
# --- rod animation ---
func _rod_kill() -> void:
	if rod_tween:
		rod_tween.kill()
		rod_tween = null
func _rod_reset() -> void:
	_rod_kill()
	%FishingRod.scale = rod_base_scale
	%FishingRod.rotation = 0.0
	%FishingRod.skew = 0.0
func _rod_windup() -> void:
	_rod_kill()
	rod_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	rod_tween.tween_property(%FishingRod, "rotation", deg_to_rad(windup_angle), windup_time)
func _rod_cast() -> void:
	_rod_kill()
	rod_tween = create_tween()
	rod_tween.set_parallel(true)
	rod_tween.tween_property(%FishingRod, "rotation", deg_to_rad(whip_angle), whip_time).set_ease(Tween.EASE_OUT)
	rod_tween.tween_property(%FishingRod, "skew", deg_to_rad(whip_skew), whip_time).set_ease(Tween.EASE_OUT)
	rod_tween.tween_property(%FishingRod, "scale:y", rod_base_scale.y * whip_squash, whip_time).set_ease(Tween.EASE_OUT)
	rod_tween.set_parallel(false)
	rod_tween.tween_interval(settle_time)
	rod_tween.set_parallel(true)
	rod_tween.tween_property(%FishingRod, "rotation", 0.0, return_time).set_ease(Tween.EASE_IN_OUT)
	rod_tween.tween_property(%FishingRod, "skew", 0.0, return_time).set_ease(Tween.EASE_IN_OUT)
	rod_tween.tween_property(%FishingRod, "scale:y", rod_base_scale.y, return_time).set_ease(Tween.EASE_IN_OUT)
# --- line and bait ---
func _bait_kill() -> void:
	if bait_tween:
		bait_tween.kill()
		bait_tween = null
func _bait_reset() -> void:
	_bait_kill()
	bait_in_water = false
	%Bait.visible = true
func _bait_cast(distance: float) -> void:
	_bait_kill()
	var t: float = clampf(distance / 100.0, 0.0, 1.0)
	var target := tip_idle + land_near_offset.lerp(land_far_offset, t)
	GameState.line_end = target
	line_end = %Tip.global_position + Vector2(0, idle_hang)
	bait_in_water = true
	bait_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	bait_tween.tween_property(self, "line_end", target, fly_time)
	bait_tween.tween_callback(func(): %Bait.visible = false)
func _update_line() -> void:
	var a: Vector2 = %Tip.global_position
	if not bait_in_water:
		line_end = a + Vector2(0, idle_hang)
	var mid := (a + line_end) * 0.5 + Vector2(0, line_sag)
	%FishingLine.points = PackedVector2Array([a, mid, line_end])
	%Bait.global_position = line_end
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
