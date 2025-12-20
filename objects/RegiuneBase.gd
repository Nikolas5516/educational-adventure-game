extends Area2D

# --------------------
# EXPORTURI ȘI SEMNALE
# --------------------

# ID-ul unic al regiunii (ex: "moldova", "banat") - îl scrii în Inspector
@export var id_regiune: String = "regiune_necunoscuta" 

# Referință la Sprite-ul pe care îl colorăm la hover
@onready var sprite_regiune: Sprite2D = $SpriteRegiune 

# Semnalul care anunță Harta că s-a dat click aici
signal regiune_activata(regiune_id: String) 

var este_rezolvata: bool = false

# Culori pentru feedback vizual
const COLOR_ALB_NEGRU = Color(0.3, 0.3, 0.3, 1.0) 
const COLOR_HOVER = Color(0.9, 0.9, 0.9, 1.0)
const COLOR_FINAL = Color.WHITE 

# --------------------
# SETUP ȘI HOVER
# --------------------

func _ready():
	input_pickable = true # Permite detectarea mouse-ului
	if sprite_regiune:
		sprite_regiune.modulate = COLOR_ALB_NEGRU

func _on_mouse_entered():
	if not este_rezolvata and sprite_regiune:
		sprite_regiune.modulate = COLOR_HOVER
		sprite_regiune.z_index = 100 # Aduce regiunea în față la hover

func _on_mouse_exited():
	if not este_rezolvata and sprite_regiune:
		sprite_regiune.modulate = COLOR_ALB_NEGRU
		sprite_regiune.z_index = 0

# --------------------
# INTERACȚIUNE CLICK
# --------------------

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	# Verifică dacă este Click Stânga
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not este_rezolvata:
			print("Regiunea " + id_regiune + " a fost apăsată!")
			# Trimitem ID-ul către LevelEasy.gd
			regiune_activata.emit(id_regiune) 

# Funcție apelată din pop-up când răspunzi corect
func marcheaza_rezolvata():
	este_rezolvata = true
	if sprite_regiune:
		sprite_regiune.modulate = COLOR_FINAL
	input_pickable = false # Nu mai poți da click pe ea
