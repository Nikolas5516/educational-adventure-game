extends Control

# --- REFERINȚE (Verifică numele din scenă!) ---
@onready var lbl_minciuna = $SpeechBubble/LabelMinciuna
@onready var options_container = $OptionsContainer
# Aici am pus calea din codul tău. Dacă în scenă se numesc altfel (ex: Button2, Button3), modifică aici!
@onready var btn_option1 = $OptionsContainer/Button
@onready var btn_option2 = $OptionsContainer/Button2  # Verifică dacă e Button1 sau Button2 în scenă
@onready var btn_option3 = $OptionsContainer/Button3  # Verifică dacă e Button2 sau Button3 în scenă
@onready var feedback_lbl = $FeedbackLabel

# --- VARIABILE DE STARE ---
var current_challenge = {}
var questions_solved = 0       # Câte întrebări a rezolvat utilizatorul
const QUESTIONS_TO_WIN = 5     # Câte întrebări trebuie să rezolve ca să termine nivelul
var can_interact = true        # Previne click-urile multiple

func _ready():
	feedback_lbl.hide()
	
	# Conectăm butoanele folosind o funcție care știe ȘI ce buton a fost apăsat
	btn_option1.pressed.connect(func(): _on_answer_selected(btn_option1))
	btn_option2.pressed.connect(func(): _on_answer_selected(btn_option2))
	btn_option3.pressed.connect(func(): _on_answer_selected(btn_option3))
	
	# Începem jocul
	load_new_challenge(7) # ID-ul nivelului Hard (Flashcards)

func load_new_challenge(level_id: int):
	# 1. Resetăm starea pentru runda nouă
	can_interact = true
	feedback_lbl.hide()
	reset_button_styles() # Facem butoanele albe din nou
	
	# 2. Verificăm dacă am terminat nivelul
	if questions_solved >= QUESTIONS_TO_WIN:
		level_completed()
		return

	# 3. Încărcăm datele
	current_challenge = DataManager.get_dino_correction_challenge(level_id)
	
	if current_challenge.is_empty():
		print("Eroare: Nu am putut încărca provocarea.")
		return

	# 4. Actualizăm UI-ul
	lbl_minciuna.text = '"' + current_challenge["false_text"] + '"'
	
	btn_option1.text = current_challenge["options"][0]
	btn_option2.text = current_challenge["options"][1]
	btn_option3.text = current_challenge["options"][2]

func _on_answer_selected(clicked_button: Button):
	# Dacă interacțiunea e blocată (deja a răspuns), nu facem nimic
	if not can_interact:
		return
		
	var selected_text = clicked_button.text
	
	if selected_text == current_challenge["correct_text"]:
		# --- RĂSPUNS CORECT ---
		can_interact = false # Blocăm alte click-uri
		
		# Feedback Vizual
		clicked_button.modulate = Color.GREEN # Butonul devine verde
		feedback_lbl.text = "Corect! Ai restabilit adevărul!"
		feedback_lbl.modulate = Color.GREEN
		feedback_lbl.show()
		
		# Feedback Audio (Dacă ai adăugat sunet)
		# $SFX_Correct.play() 
		
		# Logică de Joc
		DataManager.add_score(current_challenge["points"]) # Dăm puncte
		questions_solved += 1
		
		# Așteptăm 2 secunde și trecem mai departe
		await get_tree().create_timer(1.5).timeout
		load_new_challenge(7)
		
	else:
		# --- RĂSPUNS GREȘIT ---
		clicked_button.modulate = Color.RED # Butonul devine roșu
		feedback_lbl.text = "Nu e chiar așa... Mai încearcă!"
		feedback_lbl.modulate = Color.RED
		feedback_lbl.show()
		# Nu blocăm 'can_interact', lăsăm jucătorul să încerce alt buton

func reset_button_styles():
	# Resetăm culoarea tuturor butoanelor la alb
	btn_option1.modulate = Color.WHITE
	btn_option2.modulate = Color.WHITE
	btn_option3.modulate = Color.WHITE

func level_completed():
	# Ce se întâmplă la finalul nivelului
	lbl_minciuna.text = "Felicitări! Ai terminat toate corecțiile!"
	options_container.hide() # Ascundem butoanele
	feedback_lbl.text = "Scor salvat! Întoarcere la meniu..."
	feedback_lbl.show()
	
	# Așteptăm puțin și ieșim în meniu
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")
