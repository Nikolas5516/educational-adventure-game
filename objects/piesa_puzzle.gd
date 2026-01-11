extends Area2D

# Variabile statice
static var mana_este_ocupata = false
static var piesa_curenta_in_mana = null 

var dragging = false
var drag_offset = Vector2.ZERO
var pozitie_corecta_globala = Vector2.ZERO
var pozitie_start_globala = Vector2.ZERO
var este_blocata = false


# Setări dimensiuni
var scara_normala = Vector2.ONE
var scara_mica = Vector2.ONE 

# Setări joc
const DISTANTA_MAGNET = 50.0
# Le lăsăm să iasă puțin în afară (-15) ca să stea cât mai departe de hartă
const MARGINE_MINIMA = -140.0 

const CULORI = [
	Color("#FF6B6B"), Color("#FF9F43"), Color("#FFC312"), Color("#F79F1F"),
	Color("#C4E538"), Color("#A3CB38"), Color("#009432"), Color("#2ED573"),
	Color("#12CBC4"), Color("#1289A7"), Color("#4BCFFA"), Color("#48DBFB"),
	Color("#D980FA"), Color("#FDA7DF"), Color("#9980FA"), Color("#5758BB"),
	Color("#FFC048"), Color("#54a0ff"), Color("#5f27cd"), Color("#ff5252")
]

func _ready():
	randomize()
	pozitie_corecta_globala = global_position
	scara_normala = scale
	
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = CULORI.pick_random()
	else:
		modulate = CULORI.pick_random()
	
	call_deferred("aseaza_pe_lateral")

func aseaza_pe_lateral():
	var canvas_transform = get_viewport().get_canvas_transform()
	var view_rect = get_viewport_rect().size
	
	var top_left = -canvas_transform.origin / canvas_transform.get_scale()
	var view_size = view_rect / canvas_transform.get_scale()
	
	var latime_banda = view_size.x * 0.20
	
	# --- CALCUL MĂRIME ---
	var marime_reala = Vector2(100, 100)
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite.texture:
		marime_reala = sprite.texture.get_size() * sprite.scale * scara_normala

	# Am redus puțin factorul de la 3.5 la 2.5
	# Dacă sunt prea mari, oricât le-am lipi de perete, tot ajung la hartă.
	var spatiu_disponibil = latime_banda * 3
	var factor = 1.0
	
	if marime_reala.x > spatiu_disponibil:
		factor = spatiu_disponibil / marime_reala.x
	
	factor = max(factor, 0.5) 
	
	scara_mica = scara_normala * factor
	scale = scara_mica 
	
	var raza_curenta_x = (marime_reala.x * factor) / 2.0
	var raza_curenta_y = (marime_reala.y * factor) / 2.0
	
	# --- POZIȚIONARE EXTREMĂ (LIPITE DE PERETE) ---
	var latura = randi() % 2
	var x_target = 0.0
	
	if latura == 0: # Stânga
		# Calculăm poziția EXACTĂ lângă peretele stâng.
		# MARGINE_MINIMA e negativă (-15), deci o trage puțin în afara ecranului
		var langa_perete = top_left.x + raza_curenta_x + MARGINE_MINIMA
		
		# Eliminăm variația spre interior. O punem FIX acolo.
		x_target = langa_perete
		
	else: # Dreapta
		# Calculăm poziția EXACTĂ lângă peretele drept.
		# MARGINE_MINIMA e negativă, deci o împinge spre dreapta (în afară)
		var langa_perete = top_left.x + view_size.x - raza_curenta_x - MARGINE_MINIMA
		
		# O punem FIX acolo.
		x_target = langa_perete
	
	# --- POZIȚIE (Y) ---
	# Pe Y le lăsăm să varieze
	var min_y = top_left.y + raza_curenta_y + 20
	var max_y = top_left.y + view_size.y - raza_curenta_y - 20
	var y_target = 0.0
	
	if min_y > max_y:
		y_target = top_left.y + (view_size.y / 2)
	else:
		y_target = randf_range(min_y, max_y)
	
	

	global_position = Vector2(x_target, y_target)
	pozitie_start_globala = global_position
	rotation_degrees = randf_range(-15, 15)

# --- SISTEM INPUT ---

func _input_event(viewport, event, shape_idx):
	if este_blocata: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if mana_este_ocupata: return
			dragging = true
			mana_este_ocupata = true
			piesa_curenta_in_mana = self
			drag_offset = global_position - get_global_mouse_position()
			z_index = 100
			move_to_front()
			var tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(self, "scale", scara_normala, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "rotation_degrees", 0.0, 0.2)

func _input(event):
	if not dragging: return 
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			termina_drag()

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + drag_offset

func termina_drag():
	dragging = false
	mana_este_ocupata = false
	piesa_curenta_in_mana = null
	z_index = 0
	verifica_pozitia()

func verifica_pozitia():
	var distanta = global_position.distance_to(pozitie_corecta_globala)
	
	if distanta < DISTANTA_MAGNET:
		global_position = pozitie_corecta_globala
		este_blocata = true
		modulate = Color(1, 1, 1, 1) 
		scale = scara_normala
		rotation_degrees = 0
		var parts = get_node_or_null("CPUParticles2D")
		if parts: parts.emitting = true
		var sunet = get_tree().get_first_node_in_group("sunet_corect")
		if sunet:
			sunet.play()
		else:
			print("EROARE: Nu am găsit niciun nod în grupul 'sunet_corect'")
		
		# Notifică părintele (JudeteManager)
		if get_parent().has_method("on_piece_placed"):
			get_parent().on_piece_placed()
			
	else:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "global_position", pozitie_start_globala, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "scale", scara_mica, 0.5)
		tween.tween_property(self, "rotation_degrees", randf_range(-15, 15), 0.5)
		var sunet = get_tree().get_first_node_in_group("sunet_incorect")
		if sunet:
			sunet.play()
