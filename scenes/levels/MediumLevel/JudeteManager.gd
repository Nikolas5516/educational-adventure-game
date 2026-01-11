extends Node2D

func _ready():
	print("JUDETE LEVEL STARTED")
	DataManager.start_level_tracking()

func on_piece_placed():
	DataManager.add_level_points(3) # 3 puncte per județ plasat corect
	print("Piesa plasata! Puncte adaugate.")
	check_win_condition()

func check_win_condition():
	var all_locked = true
	var count = 0
	for child in get_children():
		if child.has_method("verifica_pozitia"): # E o piesă de puzzle
			count += 1
			if not child.este_blocata:
				all_locked = false
				break
	
	if count > 0 and all_locked:
		game_completed()

func game_completed():
	print("TOATE JUDETELE PLASATE! COMMIT SCORE.")
	DataManager.commit_level_score()
	# Aici am putea afișa un panou de victorie dacă există, sau doar sunet
	var sunet = get_tree().get_first_node_in_group("sunet_corect")
	if sunet:
		sunet.play()
	
	
	# Afișăm panoul de victorie
	show_victory_panel()

func show_victory_panel():
	var panel = Panel.new()
	panel.name = "VictoryPanel"
	panel.layout_mode = 1
	# Setăm ancorele manual pentru un efect de centrare simplu, sau folosim ancorele Control
	# Pentru că Judete este un Node2D, UI-ul trebuie adăugat într-un CanvasLayer ca să fie deasupra
	
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	panel.size = Vector2(600, 400)
	# Centrare pe ecran (presupunând rezoluția 1280x720)
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
	label.text = "Felicitări!\nAi așezat toate județele corect!"
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
