extends LevelHard

var questions: Array = []
var current_question: Dictionary = {} 
var current_text = ""
var is_true_statement = true

func _ready():
	load_questions_from_data_manager()
	show_new_card()
	
func load_questions_from_data_manager():
	
	var raw_questions = DataManager.get_all_questions() 

	if raw_questions.is_empty():
		push_error("DataManager returned no questions!")
		return
	questions = raw_questions.filter(
		func(q): return q.get("question_type", "") == "flashcard"
	)
		
func show_new_card():
	if questions.is_empty():
		$CenterCard/CardMargin/MarginContainer/VBoxContainer/CardLabel.text = "No questions loaded!"
		return
	
	var index = randi() % questions.size()
	current_question = questions[index] 
	var q = current_question

	is_true_statement = randf() < 0.5

	if is_true_statement:
		current_text = q["correct_statement"]
	else:
		current_text = q["false_statement"]
	
	$CenterCard/CardMargin/MarginContainer/VBoxContainer/CardLabel.text = current_text
	

const MAP_SCENE_PATH = "res://scenes/levels/HardLevel/MapGame.tscn"

func check_answer(choice: bool):
	if choice == is_true_statement:
		$CenterCard/CardMargin/MarginContainer/VBoxContainer/Feedback.text = "Corect!"
		$CorrectSound.play()
		
		var points_to_add = current_question.get("points", 10)
		DataManager.add_score(points_to_add)
		if DataManager.get_score() >= LevelHard.MAP_UNLOCK_THRESHOLD:
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
