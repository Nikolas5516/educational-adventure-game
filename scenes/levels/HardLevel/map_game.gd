extends Node2D

@onready var feedback_label = $TextureRect/Feedback_Label 

const WIN_SCORE_THRESHOLD: int = 100 
const MAIN_MENU_SCENE_PATH = "res://scenes/meniuprincipal.tscn"
var points_this_level: int = 0 

var current_selection = "" 
const CORRECT_ANSWERS = {
	"A": "Cluj-Napoca",
	"B": "Bucuresti",
	"C" : "Iasi",
	"D": "Timisoara",
	"E": "Podisul Dobrogei",
	"F": "Podisul Moldovei",
	"H": "Muntii Maramuresului"
}

func _on_map_area_clicked(viewport, event, shape_idx, area_id):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_selection = area_id
		print("Ai apasat pe: " + current_selection) 


func _on_answer_button_pressed(selected_answer_text: String):
	var cleaned_answer_text = selected_answer_text.strip_edges()
	
	if current_selection == "":
		display_feedback("Te rog sa apesi prima data pe harta!", Color.YELLOW)
		return

	var correct_answer = CORRECT_ANSWERS.get(current_selection)
	if cleaned_answer_text == correct_answer: 
		display_feedback(" Correct! " + correct_answer, Color.GREEN)	
		points_this_level += 10
		check_win_condition()

	else:
		display_feedback(" Raspuns gresit! Raspunsul corect este: " + correct_answer, Color.RED)
	
	current_selection = ""

func display_feedback(message, color):
	if is_inside_tree() and has_node("Feedback_Timer"):
		$Feedback_Timer.queue_free()

	feedback_label.text = message
	feedback_label.add_theme_color_override("font_color", color) 
	feedback_label.visible = true

	var timer = Timer.new()
	timer.name = "Feedback_Timer"
	timer.one_shot = true
	timer.wait_time = 3.0 
	timer.timeout.connect(func(): 
		feedback_label.visible = false
		timer.queue_free()
		)
	
	add_child(timer)
	timer.start()
	

func goto_scene(path: String):
	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Failed to load scene: " + path)
		
func check_win_condition():
	if points_this_level >= WIN_SCORE_THRESHOLD:
		DataManager.add_score(WIN_SCORE_THRESHOLD)
		goto_scene(MAIN_MENU_SCENE_PATH)
		
