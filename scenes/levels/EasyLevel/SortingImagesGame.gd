extends Control


# Called when the node enters the scene tree for the first time.
@onready var central_image = $CentralImage
@onready var left_button = $Munte
@onready var right_button = $Campie
@onready var feedback_label = $FeedbackLabel
@onready var victory_panel = $VictoryPanel 

var score = 0
var current_index = 0

# Lista de date bazată pe imaginile tale din folderul comparingImages
var game_data = [
	{"path": "res://assets/comparingImages/acvila.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/capraDeMunte.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/culesCartofi.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/dropia.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/floareDeColt.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/FloriDeStanca.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/pexels-photo-14028084.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/pomi.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/soarece.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/transfagarasan.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/vulpe.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/urs.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/grau.jpeg", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/floareaSoarelui.png", "category": "CAMPIE"},
	{"path": "res://assets/comparingImages/tufaMunte.jpeg", "category": "MUNTE"},
	{"path": "res://assets/comparingImages/porumb(1).jpeg", "category": "CAMPIE"}
]

@onready var instructions_panel = $InstructionsPanel # Referință nouă

func _ready():
	# Oprim logica de început până la apăsarea butonului
	instructions_panel.visible = true
	central_image.visible = false # Nu arătăm prima imagine încă
	left_button.disabled = true  # Dezactivăm butoanele de joc
	right_button.disabled = true
	
	# Start level tracking
	DataManager.start_level_tracking()

# Funcția care va porni efectiv jocul
func _on_start_button_pressed():
	instructions_panel.visible = false
	left_button.visible = true
	right_button.visible = true
	central_image.visible = true
	left_button.disabled = false
	right_button.disabled = false
	game_data.shuffle() 
	show_next_image()
	game_data.shuffle()
	show_next_image()
	
func show_next_image():
	if current_index < game_data.size():
		var current_item = game_data[current_index]
		central_image.texture = load(current_item["path"])
		central_image.visible = true
		central_image.modulate = Color(1, 1, 1, 1)
	else:
		# Cod pentru finalul jocului
		central_image.visible = false
		print("Felicitări! Ai sortat toate imaginile. Scor final: ", score)
		
func check_answer(player_choice):
	var correct_answer = game_data[current_index]["category"]
	
	if player_choice == correct_answer:
		score += 10
		DataManager.add_level_points(10) # 10 puncte per raspuns corect
		feedback_label.text = "Corect!"
		feedback_label.modulate = Color.GREEN
	else:
		feedback_label.text = "Greșit!"
		feedback_label.modulate = Color.RED
	
	feedback_label.visible = true
	
	# Verificăm dacă a ajuns la 5 ghiciri corecte (50 puncte)
	if score >= 50:
		show_victory_screen()
		return # Oprim jocul aici, nu mai trecem la următoarea imagine

	await get_tree().create_timer(0.5).timeout
	feedback_label.visible = false
	
	current_index += 1
	show_next_image()
	

func show_victory_screen():
	central_image.visible = false
	left_button.disabled = true # Dezactivăm butoanele de joc
	right_button.disabled = true
	victory_panel.visible = true # Afișăm panoul de victorie
	
	# Commit points to Global Score
	DataManager.commit_level_score()

# Funcția pentru butonul de Home
func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")
	
func _on_munte_pressed():
	check_answer("MUNTE")

func _on_campie_pressed():
	check_answer("CAMPIE")
