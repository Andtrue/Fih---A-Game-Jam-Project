extends Node2D

const SPINNING_FISH_SCENE: PackedScene = preload("res://Data/Events/talking_fih.tscn")

var spinning_fish: Node2D
var spawn_spinning_fish_next_cast := false

var is_on_bar = false
var is_fishing = false
var fish_count = 0

func _ready() -> void:
	# Stop all timers at the beginning
	$Timer.stop()
	$Node/EventTimer.stop()
	$FishingStartTimer.stop()

	# White Box Pause
	
	# Hide the fishing UI
	$Outside.hide()
	$Fish.hide()
	%TextureProgressBar.hide()

	# Disable the fishing bar
	$Outside/RigidBody2D.set_process_input(false)

	# Stop fish movement
	$Fish.process_mode = Node.PROCESS_MODE_DISABLED

	# Show cast prompt
	%CastPrompt.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and !is_fishing:
		start_cast()


func start_cast() -> void:
	# Prevent another cast while waiting
	is_fishing = true

	# Spawn fish when fishing begins again after the first catch.
	if spawn_spinning_fish_next_cast:
		spawn_spinning_fish()
		spawn_spinning_fish_next_cast = false
		
	%TextureProgressBar.value = 30
	
	# Hide prompt
	%CastPrompt.hide()

	# Show fishing UI
	$Outside.show()
	$Fish.show()
	%TextureProgressBar.show()

	# Start the 1 second delay
	$FishingStartTimer.start()


func _on_fishing_start_timer_timeout() -> void:
	# The 1 second delay is over.
	# Now actual fishing starts.
	$FishingStartTimer.stop()

	$Outside/RigidBody2D.set_process_input(true)
	$Fish.process_mode = Node.PROCESS_MODE_INHERIT

	$Timer.start()
	$Node.start_events()


func end_fishing() -> void:
	is_fishing = false

	# Stop all fishing systems
	$Timer.stop()
	$Node/EventTimer.stop()
	$FishingStartTimer.stop()

	# Disable fishing bar
	$Outside/RigidBody2D.set_process_input(false)

	# Stop fish movement
	$Fish.process_mode = Node.PROCESS_MODE_DISABLED

	# Hide fishing UI
	$Outside.hide()
	$Fish.hide()
	%TextureProgressBar.hide()

	# Show cast prompt
	%CastPrompt.show()

func spawn_spinning_fish() -> void:
	# Prevent more than one from being created.
	if is_instance_valid(spinning_fish):
		return

	spinning_fish = SPINNING_FISH_SCENE.instantiate() as Node2D

	if spinning_fish == null:
		push_error("Spinning fish scene root must be a Node2D.")
		return

	spinning_fish.name = "SpinningFish"
	add_child(spinning_fish)

	# Change this to the desired position.
	spinning_fish.position = Vector2(-45, -25)
	spinning_fish.scale = Vector2(0.42, 0.42)


func _on_area_2d_body_entered(body: Node2D) -> void:
	is_on_bar = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	is_on_bar = false


func _on_timer_timeout() -> void:
	if !is_fishing:
		return

	if is_on_bar:
		%TextureProgressBar.value += 4
	else:
		%TextureProgressBar.value -= 3

	if %TextureProgressBar.value >= 100:
		print("fish caught")

		fish_count += 1
		%FishCounter.text = str(fish_count) + " Fih"
		
		if fish_count == 1:
			spawn_spinning_fish_next_cast = true
		
		end_fishing()

	elif %TextureProgressBar.value <= 0:
		print("fish escaped")
		end_fishing()
