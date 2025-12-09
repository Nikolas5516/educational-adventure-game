extends Control

# --- REFERINȚE VIZUALE (Leagă codul de nodurile din poză) ---
@onready var setup_panel = $SetupPanel
@onready var btn_start_5 = $SetupPanel/Btn5
@onready var btn_start_10 = $SetupPanel/Btn10

@onready var speech_bubble = $SpeechBubble
@onready var lbl_minciuna = $SpeechBubble/LabelMinciuna

@onready var options_container = $OptionsContainer
# ATENȚIE: Aici am pus numele exacte din poza ta (Button, Button1, Button2)
@onready var btn_option1 = $OptionsContainer/Button
@onready var btn_option2 = $OptionsContainer/Button1
@onready var btn_option3 = $OptionsContainer/Button2

@onready var feedback_lbl = $FeedbackLabel
@onready var btn_back_to_menu = $BtnBackToMenu

# --- VARIABILE DE JOC ---
var current_challenge = {}
var questions_solved = 0
var questions_to_win = 5   # Se va schimba când apeși pe buton
var can_interact = true

func _ready():
	# === STAREA INIȚIALĂ (Când intri în nivel) ===
	
	# 1. Ascundem elementele de joc
	speech_bubble.visible = false
	options_container.visible = false
	feedback_lbl.visible = false
	btn_back_to_menu.visible = false
	
	# 2. Arătăm DOAR panoul de setări
	setup_panel.visible = true
	
	# --- CONECTĂM BUTOANELE ---
	
	# Butoanele de start (5 sau 10)
	if not btn_start_5.pressed.is_connected(start_game):
		btn_start_5.pressed.connect(start_game.bind(5))
	
	if not btn_start_10.pressed.is_connected(start_game):
		btn_start_10.pressed.connect(start_game.bind(10))
		
	# Butoanele de răspuns
	btn_option1.pressed.connect(func(): _on_answer_selected(btn_option1))
	btn_option2.pressed.connect(func(): _on_answer_selected(btn_option2))
	btn_option3.pressed.connect(func(): _on_answer_selected(btn_option3))
	
	# Butonul de ieșire
	btn_back_to_menu.pressed.connect(_on_back_to_menu_pressed)

# Funcția care pornește jocul după ce ai ales numărul
func start_game(count: int):
	print("Jocul începe cu ", count, " întrebări.")
	questions_to_win = count
	questions_solved = 0
	
	# Ascundem setările și arătăm jocul
	setup_panel.visible = false
	
	speech_bubble.visible = true
	options_container.visible = true
	
	# Începem prima întrebare
	load_new_challenge(7) # 7 este ID-ul nivelului Hard

func load_new_challenge(level_id: int):
	# Resetăm starea
	can_interact = true
	feedback_lbl.visible = false
	reset_button_styles()
	
	# Verificăm dacă am terminat
	if questions_solved >= questions_to_win:
		level_completed()
		return

	# Luăm o întrebare nouă din DataManager
	current_challenge = DataManager.get_dino_correction_challenge(level_id)
	
	if current_challenge.is_empty():
		print("Nu mai sunt întrebări!")
		level_completed() 
		return

	# Punem textele pe ecran
	lbl_minciuna.text = '"' + current_challenge["false_text"] + '"'
	
	btn_option1.text = current_challenge["options"][0]
	btn_option2.text = current_challenge["options"][1]
	btn_option3.text = current_challenge["options"][2]

func _on_answer_selected(clicked_button: Button):
	if not can_interact:
		return
		
	var selected_text = clicked_button.text
	
	if selected_text == current_challenge["correct_text"]:
		# --- RĂSPUNS CORECT ---
		can_interact = false
		clicked_button.modulate = Color.GREEN
		feedback_lbl.text = "Corect! Ai restabilit adevărul!"
		feedback_lbl.modulate = Color.GREEN
		feedback_lbl.visible = true
		
		# Dăm puncte și avansăm
		DataManager.add_score(current_challenge["points"])
		questions_solved += 1
		
		# Așteptăm 1.5 secunde
		await get_tree().create_timer(1.5).timeout
		load_new_challenge(7)
		
	else:
		# --- RĂSPUNS GREȘIT ---
		clicked_button.modulate = Color.RED
		feedback_lbl.text = "Nu e chiar așa... Mai încearcă!"
		feedback_lbl.modulate = Color.RED
		feedback_lbl.visible = true

func reset_button_styles():
	btn_option1.modulate = Color.WHITE
	btn_option2.modulate = Color.WHITE
	btn_option3.modulate = Color.WHITE

func level_completed():
	# Ascundem întrebările
	lbl_minciuna.text = "Felicitări! Ai terminat seria de " + str(questions_to_win) + " întrebări!"
	options_container.visible = false 
	
	feedback_lbl.text = "Scor total salvat."
	feedback_lbl.modulate = Color.WHITE
	feedback_lbl.visible = true
	
	# Arătăm butonul de ieșire
	btn_back_to_menu.visible = true

func _on_back_to_menu_pressed():
	DataManager.save_game()
	get_tree().change_scene_to_file("res://meniuprincipal.tscn")
	