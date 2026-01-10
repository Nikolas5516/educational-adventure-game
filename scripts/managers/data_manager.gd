extends Node

# Calea către fișierul de salvare. Declarația necesară pentru a evita erorile.
const SAVE_FILE_PATH = "user://game_data.json"

# Variabilele principale
var levels: Array = []
var questions: Array = []
var current_level_id: int = -1
var current_score: int = 0

# Semnalele pentru a notifica UI-ul (HUD și CustomDino)
signal score_updated(new_score)
signal equip_changed() # Semnal NOU: Emis când echipamentul se schimbă

#SETARI
var audio_settings: Dictionary = {
	"volume": 50.0,
	"music": 50.0,
	"sfx": 50.0
}

# Semnal pentru schimbarea setărilor audio
signal audio_settings_changed()


# --- INVENTAR ȘI CUSTOMIZARE ---

# Dicționarul articolelor deblocate (true = deblocat/cumpărat)
var unlocked_items: Dictionary = {
	"default_hat": true # Accesoriul de bază este mereu deblocat
}

# Articolele echipate în prezent: mapare Slot -> Item ID
var equipped_items: Dictionary = {
	"hat": "default_hat", # Slotul 'hat'
	"scarf": "" # Slotul 'scarf'
}

# Dicționarul cu detaliile complete pentru fiecare articol (Baza de Date a Magazinului)
const ITEMS_DATA = {
	"default_hat": {"slot": "hat", "name": "Fără Accesoriu", "cost": 0, "texture": ""},
	"red_scarf": {"slot": "scarf", "name": "Fular Roșu", "cost": 200, "texture": "res://assets/clothes/scarf_red.png"},
	"cowboy_hat": {"slot": "hat", "name": "Pălărie Cowboy", "cost": 300, "texture": "res://assets/clothes/hat_cowboy.png"},
}





func _ready():
	load_levels()
	load_questions()
	load_game() # Încărcare date salvate la pornirea jocului
	# test_data_manager()



# ======================================================================
# 1. LOADING FUNCTIONS (Niveluri și Întrebări)
# ======================================================================

func load_levels():
	var file := FileAccess.open("res://data/levels.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		levels = JSON.parse_string(json_text)
		if levels == null:
			levels = []
			push_error("Failed to parse levels.json")
	else:
		push_error("Failed to open levels.json")

func load_questions():
	var file := FileAccess.open("res://data/questions.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		questions = JSON.parse_string(json_text)
		if questions == null:
			questions = []
			push_error("Failed to parse questions.json")
	else:
		push_error("Failed to open questions.json")


# ======================================================================
# 2. LEVEL FUNCTIONS (Omitere pentru brevetate)
# ======================================================================

func get_all_levels() -> Array:
	return levels

func get_level_by_id(level_id: int) -> Dictionary:
	for level in levels:
		if level["id"] == level_id:
			return level
	return {}

func get_levels_by_difficulty(difficulty: String) -> Array:
	return levels.filter(func(level): return level["name"] == difficulty)

func get_level_count() -> int:
	return levels.size()

func set_current_level(level_id: int) -> void:
	current_level_id = level_id

func get_current_level() -> Dictionary:
	return get_level_by_id(current_level_id)


# ======================================================================
# 3. QUESTION FUNCTIONS (Omitere pentru brevetate)
# ======================================================================

func get_all_questions() -> Array:
	return questions

func get_questions_for_level(level_id: int) -> Array:
	return questions.filter(func(q): return q["level_id"] == level_id)

func get_question_by_id(question_id: int) -> Dictionary:
	for question in questions:
		if question["id"] == question_id:
			return question
	return {}

func get_questions_by_difficulty(difficulty: String) -> Array:
	var level_ids = []
	for level in get_levels_by_difficulty(difficulty):
		level_ids.append(level["id"])
	
	return questions.filter(func(q): return q["level_id"] in level_ids)

func get_questions_by_type(question_type: String) -> Array:
	return questions.filter(func(q): return q.get("question_type", "multiple_choice") == question_type)

func get_flashcards_for_level(level_id: int) -> Array:
	return questions.filter(func(q):
		return q["level_id"] == level_id and q.get("question_type", "") == "flashcard"
	)

func get_multiple_choice_for_level(level_id: int) -> Array:
	return questions.filter(func(q):
		return q["level_id"] == level_id and q.get("question_type", "multiple_choice") == "multiple_choice"
	)


# ======================================================================
# 4. ANSWER CHECKING & POINTS CALCULATION (Omitere pentru brevetate)
# ======================================================================

func check_answer(question_id: int, selected_option: String) -> bool:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		push_error("Question not found: " + str(question_id))
		return false
	
	if question.has("correct_option"):
		return question["correct_option"] == selected_option.to_upper()
	
	return false

func check_flashcard_answer(question_id: int, is_statement_correct: bool) -> bool:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		push_error("Question not found: " + str(question_id))
		return false
	
	# Presupune că logica flashcard este corectă
	return is_statement_correct

func get_correct_answer(question_id: int) -> String:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		return ""
	return question["correct_option"]

func get_answer_text(question_id: int, option: String) -> String:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		return ""
	
	var option_key = "option_" + option.to_lower()
	if question.has(option_key):
		return question[option_key]
	return ""

func calculate_points(question_id: int, attempts_used: int) -> int:
	var question = get_question_by_id(question_id)
	if question.is_empty():
		return 0
	
	var base_points = question["points"]
	var max_attempts = question.get("attempts_allowed", 3)
	
	if attempts_used <= max_attempts:
		return base_points
	
	return 0


# ======================================================================
# 5. SCORING FUNCTIONS
# ======================================================================

# Variabila pentru scorul nivelului curent (necomis încă la global)
var level_score: int = 0

# Inițializează urmărirea scorului pentru un nivel nou
func start_level_tracking():
	level_score = 0
	print("🎯 Level tracking started. Level Score: 0")

# Adaugă puncte la scorul nivelului curent
func add_level_points(amount: int):
	level_score += amount
	print("➕ Level points added: ", amount, " | Current Level Score: ", level_score)

# Comite scorul nivelului la scorul global și salvează
func commit_level_score():
	if level_score > 0:
		add_score(level_score)
		print("✅ Level score committed: ", level_score, " | New Global Score: ", current_score)
		level_score = 0
		save_game()
	else:
		print("ℹ️ No level score to commit.")

# Returnează scorul nivelului curent
func get_level_score() -> int:
	return level_score

func add_score(points: int) -> void:
	current_score += points
	score_updated.emit(current_score)
	save_game() # Salvare după schimbarea scorului

func get_score() -> int:
	return current_score

func reset_score() -> void:
	current_score = 0
	score_updated.emit(current_score)
	save_game()



# ======================================================================
# 6. INVENTAR ȘI ECHIPARE
# ======================================================================

# Funcția existentă:
func is_unlocked(item_id: String) -> bool:
	return unlocked_items.get(item_id, false)

# ADĂUGĂ această funcție nouă (alias pentru is_unlocked):
func is_item_unlocked(item_id: String) -> bool:
	return is_unlocked(item_id)

func unlock_item(item_id: String):
	unlocked_items[item_id] = true
	save_game()

func equip_item(item_id: String):
	var item_data = ITEMS_DATA.get(item_id)
	if not item_data:
		push_error("Articol necunoscut: " + item_id)
		return
		
	var slot = item_data["slot"]
	
	# Verifică dacă echipamentul chiar se schimbă
	if equipped_items.get(slot) != item_id:
		equipped_items[slot] = item_id
		save_game() # Salvare după schimbarea echipamentului
		equip_changed.emit() # Notifică CustomDino

# 🚨 NOU: Funcția de dez-echipare
func unequip_item(item_id: String):
	var item_data = ITEMS_DATA.get(item_id)
	if not item_data:
		push_error("Articol necunoscut: " + item_id)
		return
		
	var slot = item_data["slot"]
	
	# Doar dacă articolul respectiv este echipat
	if equipped_items.get(slot) == item_id:
		if slot == "hat":
			equipped_items[slot] = "default_hat"
		else:
			equipped_items[slot] = ""
			
		save_game()
		equip_changed.emit()


func is_equipped(item_id: String) -> bool:
	for slot_item_id in equipped_items.values():
		if slot_item_id == item_id:
			return true
	return false

# ======================================================================
# 7. PERSISTENȚA DATELOR (SALVARE ȘI ÎNCĂRCARE)
# ======================================================================

func save_game():
	var save_dict = {
		"current_score": current_score,
		"unlocked_items": unlocked_items,
		"equipped_items": equipped_items,
		"audio_settings": audio_settings,
	}
	
	# Folosim JSON.stringify pentru a converti dicționarul în text
	var json_string = JSON.stringify(save_dict, "\t")

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Joc salvat cu succes: ", SAVE_FILE_PATH)
	else:
		push_error("Eroare la salvarea fișierului: " + SAVE_FILE_PATH)

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("Fișier de salvare nu a fost găsit. Se încarcă starea inițială.")
		return

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var parsed_data = JSON.parse_string(json_text)
		
		if parsed_data is Dictionary:
			current_score = parsed_data.get("current_score", current_score)
			unlocked_items = parsed_data.get("unlocked_items", unlocked_items)
			equipped_items = parsed_data.get("equipped_items", equipped_items)
			audio_settings = parsed_data.get("audio_settings", audio_settings)
			
			# Notifică toate componentele (HUD, CustomDino) cu datele noi
			score_updated.emit(current_score)
			equip_changed.emit()
			audio_settings_changed.emit()
			
			print("Joc încărcat. Scor: ", current_score)
		else:
			push_error("Eroare la parsarea fișierului de salvare.")
	else:
		push_error("Eroare la încărcarea fișierului: " + SAVE_FILE_PATH)


# ======================================================================
# 8. UTILITY & DEBUG FUNCTIONS (Fără modificări majore)
# ======================================================================

func get_total_questions_for_difficulty(difficulty: String) -> int:
	return get_questions_by_difficulty(difficulty).size()

func get_max_score_for_level(level_id: int) -> int:
	var level_questions = get_questions_for_level(level_id)
	var max_score = 0
	for question in level_questions:
		max_score += question["points"]
	return max_score

func get_max_score_for_difficulty(difficulty: String) -> int:
	var difficulty_questions = get_questions_by_difficulty(difficulty)
	var max_score = 0
	for question in difficulty_questions:
		max_score += question["points"]
	return max_score

func print_all_levels() -> void:
	print("=== ALL LEVELS ===")
	for level in levels:
		print("ID: ", level["id"], " | Name: ", level["name"], " | Order: ", level["level_order"])

func print_all_questions() -> void:
	print("=== ALL QUESTIONS ===")
	for question in questions:
		var q_type = question.get("question_type", "multiple_choice")
		var q_text = ""
		
		if q_type == "flashcard":
			q_text = question.get("correct_statement", "N/A")
		else:
			q_text = question.get("question_text", "N/A")
		
		print("ID: ", question["id"], " | Level: ", question["level_id"], " | Type: ", q_type, " | Text: ", q_text)

func test_data_manager():
	print("\n=== TESTING DATA MANAGER ===\n")
	# ... (restul logicii de test)
	
	# [LOGICA DE TESTARE NU ESTE INCLUSA AICI PENTRU BREVITATE, DAR POATE FI ADAUGATA INAPOI]
	
	
#PENTRU SETARI:

func get_audio_settings() -> Dictionary:
	return audio_settings.duplicate()  # Returnăm o copie pentru siguranță

func set_audio_settings(settings: Dictionary) -> void:
	audio_settings = settings.duplicate()  # Salvăm o copie
	save_game()  # Salvăm imediat
	audio_settings_changed.emit()  # Notificăm că s-au schimbat
	print("Setări audio salvate: ", audio_settings)

func reset_audio_settings() -> void:
	audio_settings = {
		"volume": 50.0,
		"music": 50.0,
		"sfx": 50.0
	}
	save_game()  # Salvăm reset-ul
	audio_settings_changed.emit()  # Notificăm
	print("Setări audio resetate la 50%")
	
	# ===== LOGICA PENTRU CORECȚIA LUI DINO (HARD LEVEL V2) =====

# Această funcție returnează un dicționar cu:
# - 'false_text': Minciuna lui Dino
# - 'correct_text': Adevărul (Răspunsul corect)
# - 'options': O listă cu 3 variante (1 corectă + 2 distractori din alte întrebări)
# - 'points': Punctajul
func get_dino_correction_challenge(level_id: int) -> Dictionary:
	# 1. Luăm toate flashcard-urile pentru nivelul cerut (ex: 7 sau 8)
	var all_flashcards = get_flashcards_for_level(level_id)
	
	if all_flashcards.size() < 3:
		push_error("Nu sunt suficiente întrebări pentru a genera opțiuni!")
		return {}

	# 2. Alegem o întrebare random care va fi "Misiunea Curentă"
	var target_question = all_flashcards.pick_random()
	
	# 3. Pregătim lista de opțiuni (începem cu răspunsul corect)
	var options = []
	options.append(target_question["correct_statement"])
	
	# 4. Adăugăm 2 variante "distractoare"
	# Luăm 'correct_statement' de la ALTE întrebări ca să pară credibile
	var attempts = 0
	while options.size() < 3 and attempts < 100:
		var random_q = all_flashcards.pick_random()
		# Ne asigurăm că nu e aceeași întrebare și nu am pus deja opțiunea
		if random_q["id"] != target_question["id"] and not options.has(random_q["correct_statement"]):
			options.append(random_q["correct_statement"])
		attempts += 1
	
	# 5. Amestecăm opțiunile ca răspunsul corect să nu fie mereu primul
	options.shuffle()
	
	return {
		"id": target_question["id"],
		"false_text": target_question["false_statement"],
		"correct_text": target_question["correct_statement"],
		"options": options,
		"points": target_question["points"]
	}
