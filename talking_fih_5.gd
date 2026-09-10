extends Node2D

const MESSAGES: Array[String] = [
	"420blazeit",
	"git gud",
	"2fast4u"
]

@export_range(0.0, 1.0) var message_chance := 0.15
@export var message_interval := randf_range(2,4)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var speech_timer: Timer = $Timer

@export var minimum_speed: float = -10
@export var maximum_speed: float = 100
@export var cycle_duration: float = 10.0

var active_bubble: Label



func _ready() -> void:
	speech_timer.wait_time = message_interval
	speech_timer.timeout.connect(_on_speech_timer_timeout)
	speech_timer.start()
	animate_speed()

func _on_speech_timer_timeout() -> void:
	# Prevent multiple bubbles from overlapping.
	if is_instance_valid(active_bubble):
		return

	if randf() <= message_chance:
		create_text_bubble()


func create_text_bubble() -> void:
	active_bubble = Label.new()

	active_bubble.text = MESSAGES.pick_random()
	active_bubble.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	active_bubble.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	active_bubble.size = Vector2(160, 40)

	# Place it above the animated sprite.
	active_bubble.position = Vector2(-80, -70)
	active_bubble.z_index = 10

	# Create the bubble background.
	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = Color(1.0, 1.0, 1.0, 0.9)
	bubble_style.border_color = Color("#333333")
	bubble_style.set_border_width_all(2)
	bubble_style.set_corner_radius_all(12)
	bubble_style.set_content_margin_all(8)

	active_bubble.add_theme_stylebox_override(
		"normal",
		bubble_style
	)

	active_bubble.add_theme_color_override(
		"font_color",
		Color.BLACK
	)

	add_child(active_bubble)

	animate_bubble(active_bubble)


func animate_bubble(bubble: Label) -> void:
	var destination := bubble.position + Vector2(0, -30)

	var tween := create_tween()
	tween.set_parallel(true)

	# Move upward.
	tween.tween_property(
		bubble,
		"position",
		destination,
		2.5
	)

	# Remain visible, then fade out.
	tween.tween_property(
		bubble,
		"modulate:a",
		0.0,
		0.5
	).set_delay(2.0)

	await tween.finished

	if is_instance_valid(bubble):
		bubble.queue_free()

	if active_bubble == bubble:
		active_bubble = null

func animate_speed() -> void:
	animated_sprite.speed_scale = minimum_speed

	var speed_tween: Tween = create_tween()
	speed_tween.set_loops()

	# Increase speed for five seconds.
	speed_tween.tween_property(
		animated_sprite,
		"speed_scale",
		maximum_speed,
		cycle_duration / 2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Decrease speed for five seconds.
	speed_tween.tween_property(
		animated_sprite,
		"speed_scale",
		minimum_speed,
		cycle_duration / 2.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_timer_timeout() -> void:
	pass # Replace with function body.
