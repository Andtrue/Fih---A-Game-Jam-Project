extends Node2D

var is_on_bar = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	is_on_bar = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	is_on_bar = false

func _on_timer_timeout() -> void:
	if is_on_bar:
		%TextureProgressBar.value += 5
	else:
		%TextureProgressBar.value -= 5
	if %TextureProgressBar.value >= 100:
		print('fish caught')
