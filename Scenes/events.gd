extends Node

const EVENT1 := preload("res://Data/Events/fih_spit.tscn")
const EVENT2 := preload("res://Data/Events/seagull.tscn")
const EVENT3 := preload("res://Data/Events/slip.tscn")

const EVENTS: Array[PackedScene] = [
	EVENT1,
	EVENT2,
	EVENT3
]

@export_range(0.0, 1.0) var event_chance : float = 1

@onready var timer = $EventTimer

var active_event: AcceptDialog


func _ready():
	timer.wait_time = randf_range(5, 10)
	timer.timeout.connect(_on_timer_timeout)

	print("EVENT SYSTEM READY")


func start_events():
	print("STARTING EVENT TIMER")
	timer.start()


func stop_events():
	timer.stop()


func roll_event():
	print("EVENT TIMER FIRED")

	if is_instance_valid(active_event):
		print("EVENT ALREADY ACTIVE")
		return

	var roll = randf_range(0.0, 1.0)

	print("EVENT ROLL: ", roll)

	if roll <= event_chance:
		play_event()
	else:
		print("EVENT FAILED ROLL")
		timer.start()


func play_event():
	print("PLAYING EVENT")

	timer.stop()

	var selected_event = EVENTS.pick_random()

	active_event = selected_event.instantiate()
	add_child(active_event)

	active_event.confirmed.connect(_on_event_finished.bind(active_event))

	show_event_at_random_position(active_event)


func _on_event_finished(event: AcceptDialog):
	if is_instance_valid(event):
		event.queue_free()

	if active_event == event:
		active_event = null
		
	timer.wait_time = randf_range(7, 10)
	timer.start()


func show_event_at_random_position(event: AcceptDialog) -> void:
	event.popup()

	var viewport_size := Vector2i(
		get_viewport().get_visible_rect().size
	)

	var popup_size := event.size
	var margin := 20

	var max_x: int = maxi(
		margin,
		viewport_size.x - popup_size.x - margin
	)

	var max_y: int = maxi(
		margin,
		viewport_size.y - popup_size.y - margin
	)

	event.position = Vector2i(
		randi_range(margin, max_x),
		randi_range(margin, max_y)
	)


func _on_timer_timeout():
	roll_event()
