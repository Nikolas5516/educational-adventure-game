extends Control
@onready var sfx_run: AudioStreamPlayer = $SFX_police


func _stop_all_audio() -> void:
	var root := get_tree().get_root()
	_stop_audio_recursive(root)
	

func _stop_audio_recursive(node: Node) -> void:
	# dacă e orice fel de player audio, îl oprim
	if node is AudioStreamPlayer:
		(node as AudioStreamPlayer).stop()
	elif node is AudioStreamPlayer2D:
		(node as AudioStreamPlayer2D).stop()
	elif node is AudioStreamPlayer3D:
		(node as AudioStreamPlayer3D).stop()

	for child in node.get_children():
		_stop_audio_recursive(child)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# 1) oprește tot sunetul din joc
	_stop_all_audio()
	if sfx_run.stream:
		$SFX_police.play()
	else:
		push_warning("nu are stream setat!")

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_btn_home_pressed() -> void:
	$SFX_police.stop()
	get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")
