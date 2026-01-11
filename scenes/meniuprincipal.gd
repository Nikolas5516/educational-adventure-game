extends Control

# --- CONSTANTE DE JOC ȘI DEBLOCARE ---

# Jucătorul trebuie să termine 3 niveluri pentru a ajunge la cufăr
const TOTAL_GAME_LEVELS: int = 3

# Nivelul corespunzător cufărului (va fi al 4-lea element pe hartă)
const FINAL_CHEST_INDEX: int = 4 

# Nivelul maxim deblocat curent (pentru test: 1 = doar primul nivel e deschis)
var unlocked_level: int = 4 


# --- DIFICULTATE & SCENE NIVELURI ---

const DIFF_EASY := 0
const DIFF_MEDIUM := 1
const DIFF_HARD := 2

var current_difficulty: int = DIFF_EASY


# Harta actualizată la 3 niveluri per dificultate
const LEVEL_SCENES := {
	DIFF_EASY: {
		1: "res://scenes/levels/EasyLevel/MainLevel.tscn",
		2: "res://scenes/UI/lvl_background/lvl_easy/2_easy.tscn",
		3: "res://scenes/levels/EasyLevel3/EasyLevel3.tscn",
		4: "res://scenes/levels/EasyLevel/SortingImagesGame.tscn",
	},
	DIFF_MEDIUM: {
		1: "res://scenes/levels/LevelNormalR/LevelNormalR.tscn",
		2: "res://scenes/levels/MediumLevel/MainLevel.tscn",
		3: "res://scenes/UI/lvl_background/lvl_mediu/3_mediu.tscn",
		4: "res://scenes/UI/lvl_background/lvl_mediu/4_mediu.tscn",
	},
	DIFF_HARD: {
		1: "res://scenes/UI/lvl_background/lvl_hard/1_hard.tscn",
		2: "res://scenes/levels/HardLevelV2/hard_levelv_2.tscn",
		3: "res://scenes/UI/lvl_background/lvl_hard/3_hard.tscn",
		4: "res://scenes/UI/Evil_Dino/Start_menu.tscn",
	},
}

# --- REFERINȚE NODURI ---



# --- REFERINȚE NODURI ȘI SCROLLING ---

# ATENTIE: Ajusteaza path-urile nodurilor de mai jos daca sunt diferite!
# Poti obtine calea (path) dand click dreapta pe nod in panoul Scena -> Copy Node Path.


@onready var trophy_icon: TextureRect = $Dino_inchis  # ajustează path-ul dacă e altul

@onready var settings_button = get_node("TopBar_HUD/SettingsButton")  

var settings_popup_scene = preload("res://scenes/SettingsPopup.tscn")

@onready var level_map_node = get_node("LevelMap")
@onready var parallax_bg = get_node("ParallaxBackground")
@onready var path_node = get_node("LevelMap/Path2D")
@onready var customize_button = get_node("TopBar_HUD/CustomizeButton")
@onready var label_mod = $ModSelectat

# AICI: Am redus array-ul la 4 butoane (3 Lvl + 1 Cufăr)
# Asigură-te că numele nodurilor din Godot corespund (lvl1, lvl2, lvl3, lvl4)
@onready var level_buttons: Array[TextureButton] = [
	get_node("LevelMap/Path2D/lvl1/Level 1") as TextureButton,
	get_node("LevelMap/Path2D/lvl2/Level 2") as TextureButton,
	get_node("LevelMap/Path2D/lvl3/Level 3") as TextureButton,
	get_node("LevelMap/Path2D/final/Final") as TextureButton, # Al 4-lea este cufărul
]

@onready var dino_text_box: Control = get_node("DinoTextBox")
var ok_button: TextureButton = null

#Debug pentru trofeu evil_dino (apasa pe tasta Q)
func _input(event):
	if event.is_action_pressed("ui_debug_reset"):
		GlobalState_dino.reset_trophy()
		update_trophy_icon()
		print("🔄 Trofeu resetat prin debug!")



# --- FUNCȚII DE BAZĂ ---



func _ready():
	

	
	# 🦖 Dacă jucătorul a mai apăsat OK vreodată, nu mai afișăm deloc dino + text + buton
	if GlobalState_dino.has_seen_intro:
		if dino_text_box:
			dino_text_box.visible = false
			dino_text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		# ⚙ Conectăm OK doar prima dată
		if dino_text_box:
			ok_button = dino_text_box.find_child("okButton", true, false)
			if ok_button and not ok_button.pressed.is_connected(_on_ok_button_pressed):
				ok_button.pressed.connect(_on_ok_button_pressed)
				print("✅ IntelesButton găsit și conectat.")
			elif not ok_button:
				print("⚠ Nu am găsit 'IntelesButton' în DinoTextBox.")
	
	
		
	
	
	# 🔒 Actualizăm starea butoanelor de nivel
	update_level_locks()
	update_trophy_icon() 
	
func update_trophy_icon() -> void:
	if GlobalState_dino.trophy_unlocked:
		trophy_icon.visible = true
		print("🏆 Trofeul este deblocat, afisez iconul.")
	else:
		trophy_icon.visible = false
		print("❌ Trofeul NU e deblocat, ascund iconul.")


func _on_ok_button_pressed() -> void:
	GlobalState_dino.has_seen_intro = true
	if dino_text_box:
		dino_text_box.visible = false
		dino_text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		

func _on_mode_selected(index: int) -> void:
	current_difficulty = index
	print("📌 Dificultate: ", index)

# --- LOGICA DEBLOCARE NIVELURI ---

func update_level_locks():
	for i in range(level_buttons.size()):
		var level_button = level_buttons[i]
		if not level_button: continue
		
		var current_index := i + 1  # 1, 2, 3 (Nivele), 4 (Cufăr)
		
		# Verificăm dacă nivelul este deblocat
		if current_index <= unlocked_level:
			level_button.disabled = false
			level_button.modulate = Color.WHITE
		else:
			level_button.disabled = true
			level_button.modulate = Color(0.5, 0.5, 0.5, 0.8) # Mai închis dacă e blocat
		
		# Conectăm semnalul o singură dată
		if not level_button.pressed.is_connected(_on_level_button_pressed):
			level_button.pressed.connect(_on_level_button_pressed.bind(current_index))

func _on_level_button_pressed(level_index: int) -> void:
	# Blocăm click-ul dacă Dino vorbește
	if dino_text_box and dino_text_box.visible:
		return

	# Verificăm dacă e Cufărul (Index 4)
	if level_index == FINAL_CHEST_INDEX:
		handle_final_chest()
		return
	
	# Încărcare scenă nivel normal
	var diff_map = LEVEL_SCENES.get(current_difficulty, null)
	if diff_map and diff_map.has(level_index):
		var scene_path: String = diff_map[level_index]
		get_tree().change_scene_to_file(scene_path)

func handle_final_chest():
	# Cufărul se deschide doar dacă ai terminat nivelul 3 (adică unlocked_level >= 4)
	if unlocked_level >= FINAL_CHEST_INDEX:
		print("🎉 Felicitări! Ai deschis Cufărul Final!")
		# Aici poți adăuga animația de deschidere sau un popup de victorie
		
		# Luăm dicționarul de scene pentru dificultatea curentă
		#Am adaugat pentru a putea sa imi leg jocul de cufar la level Easy (Diana)
		var diff_map = LEVEL_SCENES.get(current_difficulty, null)
		if diff_map and diff_map.has(FINAL_CHEST_INDEX):
			var chest_scene_path: String = diff_map[FINAL_CHEST_INDEX]
			print("🔁 Incarc scena de cufar pentru dificultatea curenta:", chest_scene_path)
			get_tree().change_scene_to_file(chest_scene_path)
		else:
			print("⚠️ Nu am găsit scena pentru cufăr în LEVEL_SCENES pentru dificultatea curentă!")
	else:
		print("⚠️ Trebuie să termini cele 3 nivele pentru cufăr!")

# --- SETTINGS & CUSTOMIZE ---

func _on_settings_button_pressed():
	var settings_popup = settings_popup_scene.instantiate()
	add_child(settings_popup)
	if settings_popup.has_method("popup_centered"):
		settings_popup.popup_centered()

func _on_customize_button_pressed():
	var customization_scene = preload("res://scenes/Customization.tscn")
	var instance = customization_scene.instantiate()
	get_tree().current_scene.add_child(instance)


func _on_easy_mode_button_pressed() -> void:
	current_difficulty=0
	label_mod.text="MOD SELECTAT: EASY"

func _on_medium_mode_button_pressed() -> void:
	current_difficulty=1
	label_mod.text="MOD SELECTAT: MEDIUM"


func _on_hard_mode_button_pressed() -> void:
	current_difficulty=2
	label_mod.text="MOD SELECTAT: HARD"
	


func _on_exit_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")
