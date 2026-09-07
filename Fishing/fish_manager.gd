class_name FishManager
extends Node

@export var all_fish: Array[FishData] = []


func get_eligible_fish(cast_distance: float) -> Array[FishData]:
	var eligible: Array[FishData] = []
	for fish in all_fish:
		if cast_distance >= fish.min_cast_distance and cast_distance <= fish.max_cast_distance:
			eligible.append(fish)
	return eligible


func select_fish(cast_distance: float) -> FishData:
	var eligible := get_eligible_fish(cast_distance)
	if eligible.is_empty():
		return null

	var total_weight := 0.0
	for fish in eligible:
		total_weight += fish.catch_weight

	var roll := randf() * total_weight
	for fish in eligible:
		roll -= fish.catch_weight
		if roll <= 0.0:
			return fish

	return eligible.back()
