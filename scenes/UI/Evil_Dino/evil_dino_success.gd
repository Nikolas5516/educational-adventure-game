extends Node2D
signal finished

@export var happy_scene: PackedScene
@export var run_scene: PackedScene

func _ready() -> void:
	# 1) speriat
	var happy_inst := happy_scene.instantiate()
	add_child(happy_inst)

	if happy_inst.has_signal("finished"):
		await happy_inst.finished
	else:
		await get_tree().create_timer(1.0).timeout

	# scoate scena speriată
	happy_inst.queue_free()

	# 2) fuga
	var run_inst := run_scene.instantiate()
	add_child(run_inst)
	run_inst.position = Vector2.ZERO

	if run_inst.has_signal("finished"):
		await run_inst.finished
	else:
		await get_tree().create_timer(1.0).timeout
		
	# IMPORTANT: anunță că TOTUL s-a terminat
	finished.emit()
	#get_tree().change_scene_to_file("res://.../Harta.tscn")
