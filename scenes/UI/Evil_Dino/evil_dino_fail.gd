extends Node2D

@export var scared_scene: PackedScene
@export var run_scene: PackedScene

func _ready() -> void:
	# 1) speriat
	var scared_inst := scared_scene.instantiate()
	add_child(scared_inst)

	if scared_inst.has_signal("finished"):
		await scared_inst.finished
	else:
		await get_tree().create_timer(1.0).timeout

	# salvează poziția unde era dino
	var pos: Vector2 = scared_inst.global_position

	# scoate scena speriată
	scared_inst.queue_free()

	# 2) fuga
	var run_inst := run_scene.instantiate()
	add_child(run_inst)
	run_inst.global_position = pos

	if run_inst.has_signal("finished"):
		await run_inst.finished
		
	#get_tree().change_scene_to_file("res://.../Harta.tscn")
