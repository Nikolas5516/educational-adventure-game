extends Node2D

# Referințe UI
@onready var win_panel = $CanvasLayer/WinPanel # Asigură-te că ai creat acest Panel
@onready var correct_sound = $CorrectSound # Asigură-te că ai adăugat AudioStreamPlayer
@onready var incorrect_sound = $IncorrectSound

# Variabile
var total_pieces = 0
var placed_pieces_count = 0
var points_per_piece = 10

func _ready():
	# Ascundem panoul de victorie la început
	if win_panel:
		win_panel.visible = false
	
	# Numărare automată piese
	if has_node("PiecesContainer"):
		total_pieces = $PiecesContainer.get_child_count()
	else:
		# Fallback
		for child in get_children():
			if child.name.begins_with("Piece"):
				total_pieces += 1
	
	print("Total piese: ", total_pieces)
	
	# Conectare semnale
	if has_node("PiecesContainer"):
		for piece in $PiecesContainer.get_children():
			if piece.has_signal("dropped"):
				piece.dropped.connect(_on_piece_dropped)

func _on_piece_dropped(piece):
	var found_correct_slot = false
	var overlapping_areas = piece.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.name.begins_with("Slot") and area.get("is_occupied") == false:
			if area.correct_id == piece.piece_id:
				if piece.global_position.distance_to(area.global_position) < 50:
					snap_piece_to_slot(piece, area)
					found_correct_slot = true
					break
	if not found_correct_slot:
		piece.position = piece.original_position
		incorrect_sound.play()

func snap_piece_to_slot(piece, slot):
	# 1. Mutare și Blocare
	piece.global_position = slot.global_position
	piece.locked = true
	slot.is_occupied = true
	
	# 2. FEEDBACK AUDIO
	if correct_sound and correct_sound.stream:
		correct_sound.play()
	
	# 3. FEEDBACK VIZUAL (Text Plutitor)
	show_floating_text(piece.global_position, "+10")
	
	# 5. Adăugare scor
	DataManager.add_score(points_per_piece)
	placed_pieces_count += 1
	
	check_level_completion()

# --- FUNCȚIE NOUĂ PENTRU TEXT PLUTITOR ---
func show_floating_text(pos: Vector2, text: String):
	# Creăm un Label nou din cod
	var label = Label.new()
	label.text = text
	label.global_position = pos
	label.z_index = 20 # Să fie peste tot
	
	# Setări font (opțional, să fie mare și verde)
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", Color.GREEN)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	
	add_child(label)
	
	# Animăm textul: să urce în sus și să dispară (fade out)
	var tween = create_tween()
	tween.set_parallel(true) # Execută animațiile simultan
	tween.tween_property(label, "global_position:y", pos.y - 50, 0.8) # Urcă 50 pixeli
	tween.tween_property(label, "modulate:a", 0.0, 0.8) # Devine transparent
	
	# Când animația e gata, ștergem eticheta din memorie
	tween.chain().tween_callback(label.queue_free)


func check_level_completion():
	if placed_pieces_count >= total_pieces:
		finish_level()

func finish_level():
	
	# Afișăm panoul de victorie
	if win_panel:
		win_panel.visible = true
		# Fallback dacă nu ai făcut panoul: așteaptă și ieși
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")
