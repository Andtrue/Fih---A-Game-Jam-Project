extends Node2D

var is_on_bar = false
var is_fishing = false
var fish_count = 0
var leaving = false # ADDED
var elapsed_time: float = 0.0
var tracking_time := false
@export var cast_scene: String = "res://Scenes/CastMinigame.tscn" # ADDED
@export var return_delay: float = 2.0 # ADDED

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
	# ADDED: restore count, pick fish from cast distance, apply difficulty, auto-start
	fish_count = GameState.fish_count # ADDED
	%FishCounter.text = str(fish_count) + " Fih" # ADDED
	var fish: FishData = $FishManager.select_fish(GameState.cast_distance) # ADDED
	if fish: # ADDED
		GameState.current_fish = fish # ADDED
		print("hooked: ", fish.fish_name, " difficulty ", fish.difficulty) # ADDED
		
		#the commend code below I put in case we want to adjust difficulty based on the fish type
		
		#$Fish.move_distance = 20 + fish.difficulty * 0.6 # ADDED
		#$Fish.move_time = 0.6 - fish.difficulty * 0.004 # ADDED
	start_cast() # ADDED

func _process(delta: float) -> void:
	if tracking_time:
		elapsed_time += delta

func start_tracking() -> void:
	elapsed_time = 0.0
	tracking_time = true
	

func stop_tracking() -> void:
	tracking_time = false
	print("Final time: ", elapsed_time)

func _input(event: InputEvent) -> void:
	if leaving: # ADDED
		return # ADDED
	if event.is_action_pressed("ui_accept") and !is_fishing:
		start_cast()

func start_cast() -> void:
	# Prevent another cast while waiting
	is_fishing = true
		
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
	tracking_time = true

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
	_return_to_cast() # ADDED

func _return_to_cast() -> void: # ADDED
	leaving = true # ADDED
	await get_tree().create_timer(return_delay).timeout # ADDED
	get_tree().change_scene_to_file(cast_scene) # ADDED

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
		GameState.fish_count = fish_count # ADDED
		%FishCounter.text = str(fish_count) + " Fih"
		FihTopLayer.spawn_fish(fish_count)			# To change the fih spawn thresholds, put inside if and elif statements
		if fish_count == 2:		# Game win condition
			print("you win")
			tracking_time = false
			$Timer.stop()
			$Node/EventTimer.stop()
			$FishingStartTimer.stop()
			$GameEnd.dialog_text = ("You fished for %.1f seconds" % elapsed_time)
			$GameEnd.popup_centered()
			await $GameEnd.confirmed
			%CastPrompt.text = "FISH CAUGHT!" # ADDED
			end_fishing()
			return
			
		%CastPrompt.text = "FISH CAUGHT!" # ADDED
		end_fishing()
	elif %TextureProgressBar.value <= 0:
		print("fish escaped")
		%CastPrompt.text = "FISH ESCAPED!" # ADDED
		end_fishing()
