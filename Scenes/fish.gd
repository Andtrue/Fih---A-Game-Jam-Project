extends Sprite2D


var move_distance = 50
var move_time = 0.5

func _ready() -> void:
	randomize()


func _on_timer_timeout() -> void:
	var direction = randi_range(-1, 1)
	var target_position = position
	var t = create_tween()

	target_position.y += direction * move_distance

	if direction != 0:
		t.tween_property(self, "position:y", clamp(target_position.y, -25, 25), move_time)
