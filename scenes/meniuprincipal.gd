extends Control


# --- CONSTANTE DE JOC ȘI DEBLOCARE ---

# Numarul de nivele de joc care deblocheaza urmatorul nivel (fara cufar)
const TOTAL_GAME_LEVELS: int = 5 
# Numarul total de noduri pe traseu (5 Nivele + 1 Cufar)
const TOTAL_PATH_NODES: int = 6 
# Nivelul corespunzator nodului 'Cufar' (ultimul nod)
const FINAL_CHEST_INDEX: int = 6 

# Variabila care stocheaza nivelul maxim deblocat de jucator (pentru test, incepem cu 1)
# ATENTIE: In jocul final, aceasta variabila trebuie incarcata dintr-un sistem de salvare!
var unlocked_level: int = 5 


# --- DIFICULTATE & SCENE NIVELURI ---

# Folosim aceiași indici ca OptionButton:
# 0 = easy, 1 = medium, 2 = hard
const DIFF_EASY := 0
const DIFF_MEDIUM := 1
const DIFF_HARD := 2

var current_difficulty: int = DIFF_EASY

# Harta: dificultate (index) -> (număr nivel -> scenă)
const LEVEL_SCENES := {
	DIFF_EASY: {
		1: "res://scenes/levels/EasyLevel/MainLevel.tscn",
		2: "res://scenes/UI/lvl_background/lvl_easy/2_easy.tscn",
		3: "res://scenes/UI/lvl_background/lvl_easy/3_easy.tscn",
		4: "res://scenes/UI/lvl_background/lvl_easy/4_easy.tscn",
		5: "res://scenes/UI/lvl_background/lvl_easy/5_easy.tscn",
	},
	DIFF_MEDIUM: {
		1: "res://scenes/UI/lvl_background/lvl_mediu/1_mediu.tscn",
		2: "res://scenes/levels/MediumLevel/MainLevel.tscn",
		3: "res://scenes/UI/lvl_background/lvl_mediu/3_mediu.tscn",
		4: "res://scenes/UI/lvl_background/lvl_mediu/4_mediu.tscn",
		5: "res://scenes/UI/lvl_background/lvl_mediu/5_mediu.tscn",
	},
	DIFF_HARD: {
		1: "res://scenes/UI/lvl_background/lvl_hard/1_hard.tscn",
		2: "res://scenes/UI/lvl_background/lvl_hard/2_hard.tscn",
		3: "res://scenes/UI/lvl_background/lvl_hard/3_hard.tscn",
		4: "res://scenes/UI/lvl_background/lvl_hard/3_hard.tscn",
		5: "res://scenes/UI/lvl_background/lvl_hard/5_hard.tscn",
	},
}



# --- REFERINȚE NODURI ȘI SCROLLING ---

# ATENTIE: Ajusteaza path-urile nodurilor de mai jos daca sunt diferite!
# Poti obtine calea (path) dand click dreapta pe nod in panoul Scena -> Copy Node Path.


@onready var settings_button = get_node("TopBar_HUD/SettingsButton")  # Presupunând că ai un buton SettingsButton
var settings_popup_scene = preload("res://scenes/SettingsPopup.tscn")

# Nodul care contine Path2D si butoanele (LevelMap)
@onready var level_map_node = get_node("LevelMap") 


# Nodul care contine fundalul rulabil (ParallaxBackground)
@onready var parallax_bg = get_node("ParallaxBackground") 

# Nodul Path2D (care contine toate nodurile PathFollow2D)
@onready var path_node = get_node("LevelMap/Path2D") 

@onready var customize_button = get_node("TopBar_HUD/CustomizeButton")

#buton lvl
@onready var mode_button: OptionButton = get_node("TopBar_HUD/ModeButton")

@onready var level_buttons: Array[TextureButton] = [
	get_node("LevelMap/Path2D/lvl1/Level 1") as TextureButton,
	get_node("LevelMap/Path2D/lvl2/Level 2") as TextureButton,
	get_node("LevelMap/Path2D/lvl3/Level 3") as TextureButton,
	get_node("LevelMap/Path2D/lvl4/Level 4") as TextureButton,
	get_node("LevelMap/Path2D/lvl5/Level 5") as TextureButton,
]

@onready var dino_text_box: Control = get_node("DinoTextBox")
@onready var ok_button: TextureButton = null


var customization_scene = preload("res://scenes/Customization.tscn")  # A
# --- FUNCȚII DE BAZĂ ---

func _on_ok_button_pressed() -> void:
	print("OK apăsat — ascund overlay-ul!")

	GlobalState_dino.has_seen_intro = true
	
	if dino_text_box:
		dino_text_box.visible = false
		dino_text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready():
	
	# 🦖 Dacă jucătorul a mai apăsat OK vreodată, nu mai afișăm deloc dino + text + buton
	if GlobalState_dino.has_seen_intro:
		if dino_text_box:
			dino_text_box.visible = false
			dino_text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		# ⚙️ Conectăm OK doar prima dată
		if dino_text_box:
			ok_button = dino_text_box.find_child("IntelesButton", true, false)
			if ok_button and not ok_button.pressed.is_connected(_on_ok_button_pressed):
				ok_button.pressed.connect(_on_ok_button_pressed)
				print("✅ IntelesButton găsit și conectat.")
			elif not ok_button:
				print("⚠️ Nu am găsit 'IntelesButton' în DinoTextBox.")

	# 🔒 Actualizăm starea butoanelor de nivel
	update_level_locks()
	
	
	#print("=== DEBUG level_buttons ===")
	#for i in range(level_buttons.size()):
	#	print(" index ", i, " -> ", level_buttons[i])
		# Conectăm ModeButton (easy/medium/hard)
	if mode_button:
		mode_button.item_selected.connect(_on_mode_selected)
	else:
		print("⚠️ ModeButton not found - check the path TopBar_HUD/ModeButton")

	if customize_button:
		print("✅ Customize button found, connecting...")
		if not customize_button.pressed.is_connected(_on_customize_button_pressed):
			customize_button.pressed.connect(_on_customize_button_pressed)
		#customize_button.pressed.connect(_on_customize_button_pressed)
	else:
		print("⚠️ Customize button not found at specified path")
	
	if settings_button:
		print("✅ Settings button found, connecting...")
		settings_button.pressed.connect(_on_settings_button_pressed)
	else:
		print("⚠️ Settings button not found - check the path!")


#Functia pentru schimbarea dificultatii:
func _on_mode_selected(index: int) -> void:
	# index: 0 = easy, 1 = medium, 2 = hard
	current_difficulty = index
	print("📌 Dificultatea setată la index: ", index)



#FUNCTII PENTRU BUTONUL DE SETTINGS

func _on_settings_button_pressed():
	print("⚙️ Settings button pressed!")
	_open_settings_popup()

func _open_settings_popup():
	print("📖 Opening settings popup...")
	
	# Creează instanța popup-ului
	var settings_popup = settings_popup_scene.instantiate()
	
	# Configurează popup-ul
	#settings_popup.popup_exclusive = true
	settings_popup.size = Vector2(400, 400)
	
	# Adaugă popup-ul la scenă
	add_child(settings_popup)
	
	# Afișează centrat pe ecran
	settings_popup.popup_centered()
	
	print("✅ Settings popup opened successfully!")
# --- FUNCTII DE INPUT ȘI PANNING (SCROLLING) ---

# Variabile pentru Panning
var dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO

func _on_customize_button_pressed():
	print("🎨 Customize button pressed!")
	
	# Varianta 1: Încarcă scena ca modal (popup peste)
	_open_customization_scene()
	
	
func _open_customization_scene():
	print("🎨 Opening customization scene...")
	
	# Varianta A: Încarcă ca scenă separată
	#get_tree().change_scene_to_file("res://scenes/CustomizationScene.tscn")
	
	# Varianta B: Încarcă ca child (dacă vrei suprapus)
	var customization_scene = preload("res://scenes/Customization.tscn")
	var instance = customization_scene.instantiate()
	
	# # Asigură-te că instance-ul este adăugat corect
	get_tree().current_scene.add_child(instance)
	
	# # FORȚEAZĂ procesarea
	await get_tree().process_frame
	await get_tree().process_frame
	
	# # Apelează manual setup-ul dacă e nevoie
	# if instance.has_method("force_setup"):
	#     instance.force_setup()


	
	



# --- LOGICA DEBLOCARE NIVELURI ---

func update_level_locks():
	for i in range(level_buttons.size()):
		var level_button: TextureButton = level_buttons[i]
		var current_index := i + 1  # 1..5
		
		print("Config level", current_index, "->", level_button.name)
		
		if current_index <= unlocked_level:
			level_button.disabled = false
			level_button.modulate = Color.WHITE
		else:
			level_button.disabled = true
			level_button.modulate = Color(0.6, 0.6, 0.6, 1.0)
		
		if not level_button.pressed.is_connected(_on_level_button_pressed):
			print("  conectez semnalul pressed pentru level ", current_index)
			level_button.pressed.connect(_on_level_button_pressed.bind(current_index))
		else:
			print("  semnalul pressed e DEJA conectat pentru level ", current_index)


func update_level_locks_test():
	for i in range(path_node.get_child_count()):
		var level_follower = path_node.get_child(i)
		
		# Ne asiguram ca nodul PathFollow2D contine un copil (butonul/cufarul)
		if level_follower is PathFollow2D and level_follower.get_child_count() > 0:
			# Obtine referinta la butonul/cufarul real (primul copil)
			var level_button = level_follower.get_child(0) as TextureButton 
			var current_index = i + 1  # Indexul incepand cu 1
			
			if current_index <= unlocked_level:
				# Nivel/Cufar deblocat
				level_button.disabled = false
				level_button.modulate = Color.WHITE # Culoare normala
			else:
				# Nivel blocat
				level_button.disabled = true
				level_button.modulate = Color(0.6, 0.6, 0.6, 1.0) # Gri semitransparent
			
			
			# 🔗 Conectăm semnalul 'pressed' o singură dată
			if not level_button.pressed.is_connected(_on_level_button_pressed):
				level_button.pressed.connect(_on_level_button_pressed.bind(current_index))

# --- FUNCTII BUTOANE DE NIVEL ---

# Aceasta functie trebuie conectata la semnalul 'pressed()' al TUTUROR butoanelor de nivel
func _on_level_button_pressed(level_index: int) -> void:
	# 1) Dacă overlay-ul DinoTextBox este încă vizibil, ignorăm click-ul pe nivel
	if dino_text_box and dino_text_box.visible:
		print("ℹ️ Overlay-ul DinoTextBox e activ, ignor click pe level ", level_index)
		return
	# 2) De aici încolo este logica ta normală
	print(">>> _on_level_button_pressed CALLED | level_index =", level_index, " | diff =", current_difficulty)
	# restul codului...
	
	print("🔹 Nivel apăsat:", level_index, " | dificultate index:", current_difficulty)
	
	# Cufărul final
	if level_index == FINAL_CHEST_INDEX:
		handle_final_chest()
		return
	
	# Nu lăsăm să intre pe niveluri blocate
	if level_index > unlocked_level:
		print("⛔ Nivelul ", level_index, " este blocat.")
		return
	
	var diff_map = LEVEL_SCENES.get(current_difficulty, null)
	if diff_map == null:
		push_error("Nu există scene definite pentru dificultatea %s" % str(current_difficulty))
		return
	
	if not diff_map.has(level_index):
		push_error("Nu există scenă pentru nivelul %d (diff %s)" % [level_index, str(current_difficulty)])
		return
	
	var scene_path: String = diff_map[level_index]
	var err := get_tree().change_scene_to_file(scene_path)
	
	if err != OK:
		push_error("Eroare la încărcarea scenei: %s" % scene_path)
	
	
	
# Deoarece folosim o singura functie pentru toate butoanele, 
	# este necesar sa identificam ce buton a fost apasat.
	
	# Solutie temporara (pentru test):
	#print("Un buton de nivel a fost apasat!")
	
	# Solutie finala (trebuie implementata de tine, dupa ce definesti scenele):
	# 1. Obtine numele nodului apasat (exemplu: Level 3)
	# var button_name = get_tree().get_clicked_node_name() # Metoda variaza in Godot 4
	
	# 2. Determina daca este cufarul final
	# if button_name == "Final": # Presupunand ca ai numit cufarul 'Final'
	#     handle_final_chest()
	# else:
	#     # 3. Incarca scena de joc corespunzatoare
	#     var level_number = int(button_name.replace("Level ", "")) # Ex: Level 3 devine 3
	#     get_tree().change_scene_to_file("res://scenes/level_" + str(level_number) + "_game.tscn")



# Logica pentru cufarul final (Nivelul 6)
func handle_final_chest():
	# Cufarul se poate deschide doar daca toate cele 5 nivele au fost terminate
	if unlocked_level > TOTAL_GAME_LEVELS:
		# Aici adaugi logica:
		# 1. Schimba textura cufarului (Level 6) la cufar deschis (cu monede)
		# 2. Adauga puncte la variabila globala de scor
		print("🎉 Cufarul a fost deschis! Puncte bonus adaugate.")
	else:
		print("⚠️ Termina toate cele 5 nivele de joc inainte de a deschide cufarul!")
		

const SCENA_MENIU = "res://scenes/levels/HardLevel/LevelHard.tscn"

func _play_button_pressed(): 
	get_tree().change_scene_to_file(SCENA_MENIU)
	
