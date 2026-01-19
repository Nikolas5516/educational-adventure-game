extends Control

@export var main_scene_path: String = "res://scenes/UI/Evil_Dino/Main_evil_dino.tscn"



func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene_path)
