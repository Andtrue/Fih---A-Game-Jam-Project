extends Node

const EVENT1 := preload("res://Data/Events/scissors.tscn")
const EVENT2 := preload("res://Data/Events/seagull.tscn")
const EVENT3 := preload("res://Data/Events/slip.tscn")

const EVENTS: Array[PackedScene] = [
	EVENT1,
	EVENT2,
	EVENT3
]

@export var event_timer : float = randf_range(5,15)
@export_range(0.0,1.0) var event_chance : float = 1	# chance for an event (currently 100%)

@onready var timer = $EventTimer

var active_event: AcceptDialog

func _ready():
	timer.wait_time = event_timer
	#timer.one_shot = true		# use if you want only 1 event to play in the scene
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func roll_event():
	# don't play another event if one is active
	if is_instance_valid(active_event):
		return
	
	var roll = randf_range(0.0, 1.0)
	if(roll <= event_chance):
		play_event()
	else:
		timer.start()

func play_event():
	var selected_event = EVENTS.pick_random()	# pick random event
	active_event = selected_event.instantiate()	# instantiate scene
	add_child(active_event)	# add to scene tree
	
	#delete popup when pressing ok
	active_event.confirmed.connect(_on_event_finished.bind(active_event))
	
	show_event_at_random_position(active_event)	# show the event
	
func _on_event_finished(event: AcceptDialog):
	if is_instance_valid(event):
		event.queue_free()
		
	if active_event == event:
		active_event = null

func show_event_at_random_position(event: AcceptDialog) -> void:
	# Open the popup so Godot calculates its size.
	event.popup()

	var viewport_size := Vector2i(
		get_viewport().get_visible_rect().size
	)
	var popup_size := event.size
	var margin := 20

	# Calculate the furthest position that keeps the popup onscreen.
	var max_x: int = maxi(
		margin,
		viewport_size.x - popup_size.x - margin
	)

	var max_y: int = maxi(
		margin,
		viewport_size.y - popup_size.y - margin
	)

	# Assign a random position.
	event.position = Vector2i(
		randi_range(margin, max_x),
		randi_range(margin, max_y)
	)

func _on_timer_timeout():
	roll_event()
