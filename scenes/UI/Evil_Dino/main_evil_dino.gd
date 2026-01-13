extends Control


@export var target_correct: int = 5
@export var target_wrong: int = 3

var correct_count: int = 0
var wrong_count: int = 0

var win_scene := preload("res://scenes/UI/Evil_Dino/Dino_police_end.tscn")
var lose_scene := preload("res://scenes/UI/Evil_Dino/Evil_dino_escape_end.tscn")


# viewport-ul hărții (ăla existent)
@onready var game_svc: SubViewportContainer = $SubViewportContainer
@onready var game_sv: SubViewport = $SubViewportContainer/SubViewport
@onready var intrebari = $SubViewportContainer/SubViewport/Intrebari

# viewport dino corect (speriat)
@onready var fail_svc: SubViewportContainer = $DinoFailViewportContainer2
@onready var fail_sv: SubViewport = $DinoFailViewportContainer2/DinoViewport

# viewport dino greșit (fericit)
@onready var success_svc: SubViewportContainer = $DinoSuccessViewportContainer2
@onready var success_sv: SubViewport = $DinoSuccessViewportContainer2/DinoSuccessViewport  # ajustează numele dacă e altul

var dino_fail_scene := preload("res://scenes/UI/Evil_Dino/Evil_dino_fail.tscn")
var dino_success_scene := preload("res://scenes/UI/Evil_Dino/Evil_dino_success.tscn")

var _playing := false

func _enter_tree() -> void:
	# ascunde cât mai devreme (înainte de _ready)
	if fail_svc: fail_svc.visible = false
	if success_svc: success_svc.visible = false


func _ready():

	# layout/UI
	game_svc.set_anchors_preset(Control.PRESET_FULL_RECT)

	# IMPORTANT: dino viewport-urile trebuie să fie overlay, fără input
	fail_svc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	success_svc.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# Harta: primește input normal când nu rulează animația
	game_svc.mouse_filter = Control.MOUSE_FILTER_STOP
	
	_resize_all_viewports()
	get_viewport().size_changed.connect(_resize_all_viewports)

	intrebari.answer_result.connect(_on_answer_result)
	# ascunde dino la start (varianta 2)
	fail_svc.visible = false
	success_svc.visible = false
	
	# ascunde + curăță imediat (dacă în editor au rămas copii)
	fail_svc.visible = false
	success_svc.visible = false
	_clear_viewport(fail_sv)
	_clear_viewport(success_sv)

	# (opțional) fă subviewport-urile să nu mai “updateze” când nu-s vizibile
	fail_sv.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	success_sv.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE

	# IMPORTANT: conectează semnalul după 1 frame, ca să nu prinzi emisii din init
	await get_tree().process_frame
	if not intrebari.answer_result.is_connected(_on_answer_result):
		intrebari.answer_result.connect(_on_answer_result)
	
	# Start score tracking pentru acest nivel
	DataManager.start_level_tracking()
	print("🎯 Evil Dino: Level tracking started. Score: 0")

	
	
	

func _resize_all_viewports():
	var s := get_viewport().get_visible_rect().size
	game_sv.size = s
	fail_sv.size = s
	success_sv.size = s
	



func _on_answer_result(is_correct: bool) -> void:
	if _playing:
		return
	_playing = true
	
	# BLOCARE INPUT PE HARTĂ (varianta 2)
	game_svc.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ascunde ambele (siguranță)
	fail_svc.visible = false
	success_svc.visible = false

	_clear_viewport(fail_sv)
	_clear_viewport(success_sv)

	# lasă un frame să se stabilizeze transformurile
	await get_tree().process_frame
	
		# 1) actualizează scorul
	if is_correct:
		correct_count += 1
		DataManager.add_level_points(10)
		print("✅ Evil Dino: +10 puncte | Total nivel: ", DataManager.get_level_score())
	else:
		wrong_count += 1
	print("CORECTE:", correct_count, "  GRESITE:", wrong_count)


	var inst: Node2D
	var vp: SubViewport

	if is_correct:
		fail_svc.visible = true
		inst = dino_fail_scene.instantiate()
		vp = fail_sv
	else:
		success_svc.visible = true
		inst = dino_success_scene.instantiate()
		vp = success_sv

	vp.add_child(inst)
	inst.add_to_group("temp_dino")
	inst.position = Vector2.ZERO

	# așteaptă finalul animației
	await _wait_finish_or_timeout(inst, 1.5)

	_clear_viewport(vp)
	
		# ascunde după ce s-a terminat
	fail_svc.visible = false
	success_svc.visible = false
	
		# 3) verifică final de joc
	if correct_count >= target_correct:
		GlobalState_dino.trophy_unlocked = true
		GlobalState_dino.save_data()
		print("🏆 Evil Dino: Nivel câștigat!")
		DataManager.commit_level_score()
		print("💰 Evil Dino: Scor comis la global. Total: ", DataManager.get_score())
		get_tree().change_scene_to_packed(win_scene)
		return

	if wrong_count >= target_wrong:
		get_tree().change_scene_to_packed(lose_scene)
		return
	
		# DEBLOCARE INPUT PE HARTĂ
	game_svc.mouse_filter = Control.MOUSE_FILTER_STOP

	_playing = false


func _clear_viewport(vp: SubViewport) -> void:
	for c in vp.get_children():
		if c.is_in_group("temp_dino"):
			c.queue_free()


func _wait_finish_or_timeout(node: Node, seconds: float) -> void:
	if node.has_signal("finished"):
		await node.finished
	else:
		await get_tree().create_timer(seconds).timeout
