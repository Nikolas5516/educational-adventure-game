extends Node2D

var questions: Array = []
var current_question: Dictionary = {} 
var current_text = ""
var is_true_statement = true
var points_this_level: int = 0 
const GOAL_POINTS: int = 70

func _ready():
	load_questions_from_json()
	show_new_card()
	
func load_questions_from_json():
	var file = FileAccess.open("res://data/questions.json", FileAccess.READ)
	if file == null:
		push_error("Cannot open res://data/questions.json")
		return
	
	var content = file.get_as_text()
	var result = JSON.parse_string(content)

	if result == null:
		push_error("Invalid JSON inside flashcards_data.json")
		return
	
	if not result is Array:
		push_error("JSON is not an array!")
		return
		

func add_points_and_check_progress(amount: int):
	points_this_level += amount
	
	# Check if we should unlock the map
	if points_this_level >= GOAL_POINTS:
		print("Level Finished succesfully!")
		DataManager.add_score(amount)



func show_new_card():
	if questions.is_empty():
		$CenterCard/CardMargin/MarginContainer/VBoxContainer/CardLabel.text = "No questions loaded!"
		return
	
	var index = randi() % questions.size()
	current_question = questions[index] 
	var q = current_question

	is_true_statement = randf() < 0.5

		# Luăm textele cu fallback pe string gol (nu lăsăm niciodată null)
	var correct_text = q.get("correct", "")
	var false_text = q.get("false", "")
	
	if is_true_statement:
		current_text = q["correct"]
	else:
		current_text = q["false"]
		
	# Protecție finală – dacă tot e null sau gol, punem un mesaj default
	if current_text == null or current_text == "":
		current_text = "No text for this question."
	
	$CenterCard/CardMargin/MarginContainer/VBoxContainer/CardLabel.text = current_text
	

const BACK_TO_MAIN = "res://scenes/meniuprincipal.tscn"

func goto_scene(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Failed to load scene: " + path)

func check_answer(choice: bool):
	
	if choice == is_true_statement:
		$CenterCard/CardMargin/MarginContainer/VBoxContainer/Feedback.text = "Corect!"
		$CorrectSound.play()

		var points_to_add = current_question.get("points", 10)
		add_points_and_check_progress(points_to_add)
		
		if points_this_level >= GOAL_POINTS:
			goto_scene(BACK_TO_MAIN)

			return
		
	else:
		$CenterCard/CardMargin/MarginContainer/VBoxContainer/Feedback.text = "Greșit!"
		$IncorrectSound.play()
	
	await get_tree().create_timer(1.0).timeout
	$CenterCard/CardMargin/MarginContainer/VBoxContainer/Feedback.text = ""
	show_new_card()


func _on_true_button_pressed():
	check_answer(true)

func _on_false_button_pressed():
	check_answer(false)
