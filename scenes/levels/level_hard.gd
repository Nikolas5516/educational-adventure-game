# level_hard.gd
extends Node2D

const MAP_UNLOCK_THRESHOLD: int = 50  

func add_points(amount: int):
	DataManager.add_score(amount)
	print("Score updated: ", DataManager.get_score())
	if DataManager.get_score() >= MAP_UNLOCK_THRESHOLD:
		print("Map Quiz Unlocked!")

func goto_scene(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Failed to load scene: " + path)
		
