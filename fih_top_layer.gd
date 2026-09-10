extends CanvasLayer

const FISH_SCENES: Array[PackedScene] = [
	preload("res://Data/Events/talking_fih.tscn"),
	preload("res://Data/Events/talking_fih_2.tscn"),
	preload("res://Data/Events/talking_fih_3.tscn"),
	preload("res://Data/Events/talking_fih_4.tscn"),
	preload("res://Data/Events/talking_fih_5.tscn"),
	preload("res://Data/Events/talking_fih_6.tscn"),
	preload("res://Data/Events/talking_fih_7.tscn")
]

# Screen positions for fih
const FISH_POSITIONS: Array[Vector2] = [
	Vector2(150, 150),
	Vector2(150, 375),
	Vector2(150, 600),
	Vector2(625, 150),
	Vector2(625, 375),
	Vector2(625, 600),
	Vector2(950, 375)
]

var spawned_fish: Dictionary = {}


func spawn_fish(fish_number: int) -> void:
	var index: int = fish_number - 1

	if index < 0 or index >= FISH_SCENES.size():
		push_error("No scene exists for fish number " + str(fish_number))
		return

	if spawned_fish.has(fish_number):
		return

	var fish: Node2D = FISH_SCENES[index].instantiate() as Node2D

	if fish == null:
		push_error("The spinning fish scene root must be a Node2D.")
		return

	# Add the fish directly to the persistent CanvasLayer.
	add_child(fish)

	fish.position = FISH_POSITIONS[index]
	fish.scale = Vector2(1.5, 1.5)

	spawned_fish[fish_number] = fish
