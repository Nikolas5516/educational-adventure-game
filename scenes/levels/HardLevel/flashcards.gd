extends LevelHard

var questions: Array = []
var current_question: Dictionary = {} 
var current_text = ""
var is_true_statement = true

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
		
	var transformed_questions = []
	
	for question_data in result:
		var new_format = {}
	   
		new_format["correct"] = question_data.get("correct_statement")
		new_format["false"] = question_data.get("false_statement")
		new_format["score"] = question_data.get("points")
		transformed_questions.append(new_format)
	questions = transformed_questions
	
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
	

const MAP_SCENE_PATH = "res://scenes/levels/HardLevel/MapGame.tscn"

func check_answer(choice: bool):
	if choice == is_true_statement:
		$CenterCard/CardMargin/MarginContainer/VBoxContainer/Feedback.text = "Corect!"
		$CorrectSound.play()
		
		var points_to_add = current_question.get("score", 10) 
		LevelHard.add_points(points_to_add) 
		
		if LevelHard.current_score >= LevelHard.MAP_UNLOCK_THRESHOLD:
			LevelHard.goto_scene(MAP_SCENE_PATH)
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
