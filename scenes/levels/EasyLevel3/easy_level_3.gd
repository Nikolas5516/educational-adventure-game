extends Node2D

# Referințe către nodurile din scenă
@onready var question_image = $QuizContainer/QuestionImage
@onready var question_label = $QuizContainer/QuestionLabel
@onready var options_container = $QuizContainer/OptionsContainer
@onready var feedback_label = $FeedbackLabel
@onready var next_button = $NextButton

# Variabile de stare
var current_questions = []
var current_question_index = 0
var score = 0

# --- CONFIGURARE ---
const QUESTIONS_PER_ROUND = 5 # Câte întrebări primește jucătorul per sesiune

func _ready():
	randomize() # IMPORTANT: Asigură că "zarurile" sunt diferite la fiecare pornire a jocului
	
	# 1. Încărcăm TOATE întrebările disponibile pentru nivelul 1
	var all_questions = DataManager.get_questions_for_level(3)
	
	if all_questions.size() == 0:
		print("Eroare: Nu s-au găsit întrebări pentru Level 3!")
		return
		
	# 2. RANDOMIZARE ÎNTREBĂRI
	# Amestecăm lista completă
	all_questions.shuffle()
	
	# Păstrăm doar primele 5 (sau mai puține, dacă nu avem destule)
	current_questions = all_questions.slice(0, QUESTIONS_PER_ROUND)
	
	score = 0
	current_question_index = 0
	
	# Configurăm butonul Next
	next_button.visible = false
	if next_button.text == "":
		next_button.text = "URMĂTOAREA"
	next_button.pressed.connect(_on_next_button_pressed)
	
	# Configurăm stilul pentru QuestionLabel
	var question_style = get_custom_style(Color("2c3e50"))
	question_label.add_theme_stylebox_override("normal", question_style)
	
	# Setăm spațierea
	options_container.add_theme_constant_override("separation", 25)
	
	display_question()

func get_custom_style(base_color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = base_color
	style.border_width_bottom = 6
	style.border_color = base_color.darkened(0.3)
	style.set_corner_radius_all(12)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 10
	style.content_margin_bottom = 14
	return style

func display_question():
	# Curățăm butoanele vechi
	for child in options_container.get_children():
		child.queue_free()
	
	feedback_label.text = ""
	feedback_label.remove_theme_stylebox_override("normal") 
	next_button.visible = false
	
	if current_question_index >= current_questions.size():
		finish_level()
		return
	
	var q_data = current_questions[current_question_index]
	
	# Setăm textul și imaginea
	question_label.text = q_data["question_text"]
	
	if q_data.has("image_path") and q_data["image_path"] != "":
		var texture = load(q_data["image_path"])
		if texture:
			question_image.texture = texture
	
	# --- RANDOMIZARE OPȚIUNI (RĂSPUNSURI) ---
	# Facem o copie a listei de opțiuni ca să nu stricăm ordinea originală în date
	var shuffled_options = q_data["options"].duplicate()
	shuffled_options.shuffle() # Le amestecăm
	
	for option_text in shuffled_options:
		var btn = Button.new()
		btn.text = option_text
		
		# Setări vizuale
		btn.custom_minimum_size = Vector2(300, 70)
		btn.add_theme_font_size_override("font_size", 24)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var style_normal = get_custom_style(Color("2c3e50"))
		var style_hover = get_custom_style(Color("34495e"))
		
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_normal)
		
		# Conectare
		btn.pressed.connect(func(): _on_option_selected(btn, option_text, q_data))
		options_container.add_child(btn)

func _on_option_selected(clicked_button, selected_text, q_data):
	# Dezactivăm toate butoanele
	for btn in options_container.get_children():
		btn.disabled = true
	
	var is_correct = (selected_text.to_upper() == q_data["correct_option"].to_upper())
	
	var green_style = get_custom_style(Color("27ae60"))
	var red_style = get_custom_style(Color("c0392b"))
	
	if is_correct:
		feedback_label.text = "CORECT!"
		feedback_label.add_theme_stylebox_override("normal", green_style)
		clicked_button.add_theme_stylebox_override("disabled", green_style)
		
		var points = q_data.get("points", 10)
		score += points
		DataManager.add_score(points)
	else:
		feedback_label.text = "GREȘIT! Corect era: " + q_data["correct_option"]
		feedback_label.add_theme_stylebox_override("normal", red_style)
		clicked_button.add_theme_stylebox_override("disabled", red_style)

	clicked_button.add_theme_color_override("font_disabled_color", Color.WHITE)
	next_button.visible = true

func _on_next_button_pressed():
	current_question_index += 1
	display_question()

func finish_level():
	question_image.visible = false
	options_container.visible = false
	next_button.visible = false
	
	# Calculăm procentajul
	var max_score = current_questions.size() * 10 # Presupunem 10 puncte per întrebare
	
	question_label.text = "Nivel Complet!"
	feedback_label.text = "Scor final: " + str(score) + " / " + str(max_score)
	feedback_label.add_theme_stylebox_override("normal", get_custom_style(Color("f39c12")))
	
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")
