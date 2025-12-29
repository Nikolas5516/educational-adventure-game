extends Node2D
signal answer_result(is_correct: bool)

@export var questions_path: String = "res://scenes/UI/Evil_Dino/intrebari_evil_dino.json"
@onready var counties_root: Node = $MapaCountry/Counties
@onready var lbl_question: Label=$TextureRect/lbl_question

var questions: Array[Dictionary] = []
var current_index: int = 0
var _locked: bool = false  # ca să nu poată da click în timpul animației din Main

func _ready() -> void:
	_connect_recursively(counties_root)
	_load_questions()
	questions.shuffle()
	_show_current_question()


func _load_questions() -> void:
	if not FileAccess.file_exists(questions_path):
		push_error("Nu găsesc questions.json: " + questions_path)
		return

	var f := FileAccess.open(questions_path, FileAccess.READ)
	var parsed: Dictionary = JSON.parse_string(f.get_as_text())
	if parsed == null:
		push_error("JSON invalid în: " + questions_path)
		return

	var arr = parsed.get("questions", [])
	if arr is Array:
		for item in arr:
			if item is Dictionary and item.has("text") and item.has("answer_county"):
				questions.append(item)

	if questions.is_empty():
		push_error("questions.json nu are întrebări valide.")
		return
		
		


func _show_current_question() -> void:
	_clear_marks()

	if questions.is_empty():
		lbl_question.text = "Nu sunt întrebări."
		return

	var q := questions[current_index]
	lbl_question.text = str(q.get("text", ""))

func _on_county_clicked(county_id: String) -> void:
	if _locked:
		return
	if questions.is_empty():
		return

	_locked = true  # blocăm până când Main termină animația

	var q := questions[current_index]
	var correct_id: String = str(q.get("answer_county", ""))

	var is_correct := (county_id == correct_id)

	# marchează pe hartă
	_clear_marks()
	var clicked_node := _find_county_recursively(counties_root, county_id)
	if clicked_node != null:
		if is_correct:
			clicked_node.mark_correct()
		else:
			clicked_node.mark_wrong()

	# anunță Main-ul (dino + scor)
	answer_result.emit(is_correct)

	# treci la următoarea întrebare (dar întrebarea o schimbăm după o mică pauză,
	# ca să apuce copilul să vadă verde/roșu)
	await get_tree().create_timer(0.35).timeout

	current_index += 1
	if current_index >= questions.size():
		questions.shuffle()
		current_index = 0

	_show_current_question()
	_locked = false

func _connect_recursively(node: Node) -> void:
	if node.has_signal("county_clicked"):
		node.connect("county_clicked", Callable(self, "_on_county_clicked"))
	for child in node.get_children():
		_connect_recursively(child)


func _find_county_recursively(node: Node, id: String) -> Node:
	if node.get("county_id") == id:
		return node
	for child in node.get_children():
		var found := _find_county_recursively(child, id)
		if found != null:
			return found
	return null

func _clear_marks() -> void:
	_clear_marks_recursively(counties_root)

func _clear_marks_recursively(node: Node) -> void:
	if node.has_method("clear_mark"):
		node.clear_mark()
	for child in node.get_children():
		_clear_marks_recursively(child)
