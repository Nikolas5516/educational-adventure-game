extends Node2D

func _ready():
	# Căutăm toate piesele din container și le conectăm semnalul
	# Asigură-te că piesele tale sunt puse într-un Node2D numit "PiecesContainer"
	# Sau modifică calea dacă sunt puse direct în rădăcină
	# Start level tracking
	DataManager.start_level_tracking()
	
	for piece in $PiecesContainer.get_children():
		if piece.has_signal("dropped"):
			piece.connect("dropped", _on_piece_dropped)

func _on_piece_dropped(piece):
	var found_correct_slot = false
	var overlapping_areas = piece.get_overlapping_areas()
	
	for area in overlapping_areas:
		if area.name.begins_with("Slot") and area.get("is_occupied") == false:
			
			if area.correct_id == piece.piece_id:
				
				# --- AICI ESTE MODIFICAREA MAGICĂ ---
				# Calculăm distanța dintre vârful piesei și centrul slotului
				var distanta = piece.global_position.distance_to(area.global_position)
				
				# Dacă distanța e mai mică de 50 pixeli (poți ajusta numărul), dă snap
				if distanta < 35:
					snap_piece_to_slot(piece, area)
					DataManager.add_level_points(5) # 5 puncte per piesa
					found_correct_slot = true
					check_win_condition()
					break
	
	if not found_correct_slot:
		piece.position = piece.original_position

func snap_piece_to_slot(piece, slot):
	# 1. Mutăm piesa vizual fix peste slot
	piece.global_position = slot.global_position
	
	# 2. Blocăm piesa ca să nu o mai putem muta
	piece.locked = true
	
	# 3. Marcăm slotul ca ocupat
	slot.is_occupied = true

func check_win_condition():
	var all_placed = true
	for piece in $PiecesContainer.get_children():
		if not piece.get("locked"):
			all_placed = false
			break
	
	if all_placed:
		print("Joc terminat!")
		DataManager.commit_level_score()
		show_victory_panel()

func show_victory_panel():
	var panel = Panel.new()
	panel.name = "VictoryPanel"
	panel.layout_mode = 1
	
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	panel.size = Vector2(600, 400)
	panel.position = Vector2(1280/2 - 300, 720/2 - 200)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.8)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_right = 20
	style.corner_radius_bottom_left = 20
	panel.add_theme_stylebox_override("panel", style)
	
	canvas.add_child(panel)
	
	var label = Label.new()
	label.text = "Felicitări!\nAi completat puzzle-ul!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.size = Vector2(580, 200)
	label.position = Vector2(10, 50)
	label.add_theme_font_size_override("font_size", 32)
	panel.add_child(label)
	
	var home_btn = Button.new()
	home_btn.text = "Meniu Principal"
	home_btn.size = Vector2(200, 60)
	home_btn.position = Vector2(200, 280)
	home_btn.pressed.connect(_on_home_pressed)
	panel.add_child(home_btn)

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")
	
