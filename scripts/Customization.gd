extends Control

@onready var hat_slot: TextureRect = $MarginContainer/MainHBox/DinoPanel/Hat_Slot
@onready var scarf_slot: TextureRect = $MarginContainer/MainHBox/DinoPanel/Scarf_Slot
@onready var score_label: Label = $MarginContainer/MainHBox/ShopPanel/TopBar/ScoreLabel
@onready var grid_container: GridContainer = $MarginContainer/MainHBox/ShopPanel/Scroller/GridContainer

#@onready var confirmation_popup: Control = $ConfirmationPopup
#@onready var confirmation_message: Label = $ConfirmationPopup/PanelContainer/VBoxContainer/MessageLabel
#@onready var confirm_button: Button = $ConfirmationPopup/PanelContainer/VBoxContainer/HBoxContainer/ConfirmButton
#@onready var cancel_button: Button = $ConfirmationPopup/PanelContainer/VBoxContainer/HBoxContainer/CancelButton
#@onready var item_preview: TextureRect = $ConfirmationPopup/PanelContainer/VBoxContainer/ItemPreview

var selected_item_id: String = ""
var selected_item_data: Dictionary = {}
var exit_button: Button

func _on_viewport_resized() -> void:
	_check_and_fix_background()



func _ready():
	print("=== CUSTOMIZATION START ===")
	_check_and_fix_background()
	
	if DataManager:
		DataManager.score_updated.connect(_update_score_display)
		DataManager.equip_changed.connect(_update_character_appearance)
		print("✅ DataManager conectat")
	else:
		print("❌ DataManager nu este încărcat!")
	
	_create_test_points_button()
	_create_test_points_button2()
	_create_simple_dino_title()
	
	
	_create_exit_button()
	
	get_viewport().size_changed.connect(_on_viewport_resized)

	await get_tree().process_frame
	
	_update_score_display(DataManager.get_score())
	_update_character_appearance()
	_populate_shop()
	
	print("=== CUSTOMIZATION READY ===")
	
func _check_and_fix_background():
	var background = get_node_or_null("Background")
	if background:
		background.visible = true
		background.size = get_viewport().size
		


func _create_emergency_background():
	# Creează un fundal de urgență
	var emergency_bg = ColorRect.new()
	emergency_bg.name = "EmergencyBackground"
	emergency_bg.color = Color(0.1, 0.2, 0.3, 1.0)  # Albastru închis
	emergency_bg.anchor_left = 0.0
	emergency_bg.anchor_right = 1.0
	emergency_bg.anchor_top = 0.0
	emergency_bg.anchor_bottom = 1.0
	
	# Pune-l în spatele tuturor
	add_child(emergency_bg)
	move_child(emergency_bg, 0)
	
	print("✅ Created emergency background")

func _create_simple_dino_title():
	var title_label = Label.new()
	title_label.text = "Dulapul lui Dino"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var label_settings = LabelSettings.new()
	label_settings.font_size = 36
	label_settings.font_color = Color("#006400")
	title_label.label_settings = label_settings
	var dino_panel = get_node_or_null("MarginContainer/MainHBox/DinoPanel")
	if dino_panel:
		title_label.position = Vector2(300, 50)
		dino_panel.add_child(title_label)
		


func lock_all_items():
	"""Blochează toate itemele (cu excepția celor default)"""
	var count = 0
	
	for item_id in DataManager.ITEMS_DATA:
		# Păstrează itemele default deblocate
		if item_id != "default_hat" and DataManager.unlocked_items.has(item_id):
			DataManager.unlocked_items.erase(item_id)
			
			# Dacă e echipat, scoate-l
			if DataManager.is_equipped(item_id):
				DataManager.unequip_item(item_id)
			
			count += 1
	
	print("🔒 Blocate ", count, " iteme")
	_show_bottom_message("🔒 Blocate " + str(count) + " iteme", Color(0.5, 0.2, 0.7, 1.0))
	_refresh_shop()


func _create_exit_button():
	"""Creează butonul de exit folosind ancore pentru compatibilitate mobil"""
	exit_button = Button.new()
	exit_button.name = "ExitButtonMobile"
	exit_button.text = "🚪 ÎNAPOI" 
	exit_button.custom_minimum_size = Vector2(200, 80)
	
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)
	
	normal_style.set_corner_radius_all(15)
	
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0.6, 0.1, 0.1, 1.0)
	
	exit_button.add_theme_stylebox_override("normal", normal_style)
	exit_button.add_theme_stylebox_override("pressed", pressed_style)
	exit_button.add_theme_font_size_override("font_size", 24) 
	exit_button.focus_mode = Control.FOCUS_NONE
	
	var overlay = get_node_or_null("Overlay")
	if overlay:
		overlay.add_child(exit_button)
	else:
		add_child(exit_button)

	
	exit_button.anchor_left = 1.0
	exit_button.anchor_top = 1.0
	exit_button.anchor_right = 1.0
	exit_button.anchor_bottom = 1.0

	
	exit_button.offset_left = -250
	exit_button.offset_top = -110
	exit_button.offset_right = -30
	exit_button.offset_bottom = -30

	exit_button.pressed.connect(_on_exit_button_pressed)
	

	

func _create_test_points_button():
	var btn = Button.new()
	btn.text = "+100 Test"
	btn.position = Vector2(20, 90)
	btn.pressed.connect(func(): DataManager.add_score(100); _refresh_shop())
	add_child(btn)
	


func _on_test_points_button_pressed():
	"""Adaugă 100 de puncte pentru testare"""
	print("🎮 Adăugare 100 puncte test...")
	DataManager.add_score(100)
	_show_points_added_message()
	_refresh_shop()

func _show_points_added_message():
	"""Afișează mesajul că au fost adăugate puncte"""
	_show_bottom_message("✅ 100 puncte adăugate!", Color(0.2, 0.8, 0.2, 1.0))




func _create_test_points_button2():
	var btn = Button.new()
	btn.text = "-100 Test"
	btn.position = Vector2(20, 40)
	btn.pressed.connect(func(): DataManager.add_score(-100); _refresh_shop())
	add_child(btn)

func _on_test_points_button_pressed2():
	DataManager.add_score(-100)
	_show_points_scazute_message2()
	_refresh_shop()

func _show_points_scazute_message2():
	"""Afișează mesajul că au fost adăugate puncte"""
	_show_bottom_message("- 100 puncte scazute!", Color(0.8, 0.2, 0.2, 1.0))




func _populate_shop():
	if not grid_container: return
	for child in grid_container.get_children(): child.queue_free()
	
	await get_tree().process_frame
	grid_container.columns = 2
	grid_container.add_theme_constant_override("h_separation", 25)
	grid_container.add_theme_constant_override("v_separation", 25)
	
	var item_ids = []
	for item_id in DataManager.ITEMS_DATA:
		if item_id != "default_hat": item_ids.append(item_id)
	
	for item_id in item_ids:
		var item_data = DataManager.ITEMS_DATA[item_id]
		var item_container = _create_item_button(item_id, item_data)
		grid_container.add_child(item_container)
		await get_tree().process_frame
		


func _create_item_button(item_id: String, item_data: Dictionary) -> Control:
	var container = VBoxContainer.new()
	container.name = "Item_" + item_id
	container.custom_minimum_size = Vector2(200, 250)
	
	var item_button = Button.new()
	item_button.custom_minimum_size = Vector2(180, 180)
	item_button.expand_icon = true
	
	var texture_path = item_data.get("texture", "")
	if texture_path and ResourceLoader.exists(texture_path):
		item_button.icon = load(texture_path)
	
	var is_equipped = DataManager.is_equipped(item_id)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.8, 0.3) if is_equipped else Color(0.5, 0.3, 0.2)
	style.set_corner_radius_all(12) # Fix crash
	item_button.add_theme_stylebox_override("normal", style)
	
	item_button.pressed.connect(_on_item_button_pressed.bind(item_id))
	
	var name_label = Label.new()
	name_label.text = item_data.get("name", "Item")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	container.add_child(item_button)
	container.add_child(name_label)
	return container
	


func _on_item_button_pressed(item_id: String):
	selected_item_id = item_id
	selected_item_data = DataManager.ITEMS_DATA.get(item_id, {})
	var cost = selected_item_data.get("cost", 0)
	
	if not DataManager.is_item_unlocked(item_id) and DataManager.get_score() < cost:
		_show_bottom_message("❌ Puncte insuficiente!", Color.RED)
		return
	_ask_for_confirmation(selected_item_data.get("name", "Item"), cost)
	

func _show_bottom_message2(message: String, color: Color = Color(0.8, 0.2, 0.2, 1.0)):
	"""Afișează un mesaj în partea de jos a ecranului"""
	
	# Creează sau găsește containerul pentru mesaj
	var message_container = get_node_or_null("BottomMessageContainer")
	if not message_container:
		message_container = _create_bottom_message_container()
	
	# Actualizează mesajul
	var message_label = message_container.get_node("Panel/VBoxContainer/MessageLabel") as Label
	var close_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/CloseButton") as Button
	var confirm_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/ConfirmButton") as Button
	
	if message_label:
		message_label.text = message
		# Actualizează culoarea textului
		var label_settings = message_label.label_settings
		if not label_settings:
			label_settings = LabelSettings.new()
			message_label.label_settings = label_settings
		label_settings.font_color = color
	
	# Configurează butonul de închidere
	if close_button and not close_button.is_connected("pressed", _on_close_bottom_message):
		close_button.pressed.connect(_on_close_bottom_message)
	
	if confirm_button and not confirm_button.is_connected("pressed", _on_confirm_pressed):
		confirm_button.pressed.connect(_on_close_bottom_message)
	
	# Afișează mesajul cu animație
	message_container.visible = true
	message_container.modulate = Color(1, 1, 1, 0)
	
	# Animație fade in
	var tween = create_tween()
	tween.tween_property(message_container, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Ascunde automat după 5 secunde
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_on_close_bottom_message)

func _on_confirm_button_message():
	"""Închide mesajul din partea de jos"""
	var container = get_node_or_null("BottomMessageContainer")
	if container and container.visible:
		# Animație fade out
		var tween = create_tween()
		tween.tween_property(container, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): container.visible = false)
	_on_confirm_pressed()

func _show_insufficient_points_message(item_name: String, cost: int):
	"""Afișează mesaj în josul paginii pentru puncte insuficiente"""
	var current_score = DataManager.get_score()
	var message = "❌ Nu ai suficiente puncte!\n%s costă %d puncte\nTu ai doar %d puncte." % [
		item_name, 
		cost, 
		current_score
	]
	_show_bottom_message(message, Color(0.8, 0.2, 0.2, 1.0))

func _show_bottom_message(message: String, color: Color):
	print(message)

func _create_bottom_message_container() -> Control:
	"""Creează containerul pentru mesajul din partea de jos"""
	
	# 1. Container principal
	var container = Control.new()
	container.name = "BottomMessageContainer"
	container.anchor_left = 0.0
	container.anchor_right = 1.0
	container.anchor_top = 0.0
	container.anchor_bottom = 1.0
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.visible = false
	
	# 2. Panel pentru mesaj (centrat în partea de jos)
	var panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(500, 150)
	panel.size = Vector2(500, 150)
	
	# Stil pentru panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)  # Fundal semi-transparent
	panel_style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# 3. VBoxContainer pentru conținut
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size = Vector2(480, 130)
	vbox.position = Vector2(10, 10)
	vbox.add_theme_constant_override("separation", 10)
	
	# 4. Label pentru mesaj
	var message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = "Mesaj"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var label_style = LabelSettings.new()
	label_style.font_size = 18
	label_style.font_color = Color(1, 1, 1, 1)
	label_style.line_spacing = 8
	message_label.label_settings = label_style
	
	# 5. HBoxContainer pentru buton
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 6. Buton de închidere (X)
	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "✕ Închide"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Stil pentru butonul de închidere
	var close_normal = StyleBoxFlat.new()
	close_normal.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Roșu
	close_normal.border_color = Color(1, 1, 1, 1.0)
	close_normal.border_width_left = 2
	close_normal.border_width_top = 2
	close_normal.border_width_right = 2
	close_normal.border_width_bottom = 2
	close_normal.corner_radius_top_left = 8
	close_normal.corner_radius_top_right = 8
	close_normal.corner_radius_bottom_right = 8
	close_normal.corner_radius_bottom_left = 8
	
	var close_hover = close_normal.duplicate()
	close_hover.bg_color = Color(0.9, 0.3, 0.3, 1.0)  # Roșu deschis
	
	var close_pressed = close_normal.duplicate()
	close_pressed.bg_color = Color(0.7, 0.1, 0.1, 1.0)  # Roșu închis
	
	close_button.add_theme_stylebox_override("normal", close_normal)
	close_button.add_theme_stylebox_override("hover", close_hover)
	close_button.add_theme_stylebox_override("pressed", close_pressed)
	
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	close_button.focus_mode = Control.FOCUS_NONE
	
	# 7. Asamblează totul
	hbox.add_child(close_button)
	vbox.add_child(message_label)
	vbox.add_child(hbox)
	panel.add_child(vbox)
	container.add_child(panel)
	
	# 8. Adaugă la scenă
	add_child(container)
	
	# 9. Poziționează panel-ul în partea de jos, centrat
	_update_bottom_message_position(container)
	
	# 10. Conectează resize-ul viewport-ului
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	return container

func _update_bottom_message_position(container: Control):
	"""Actualizează poziția mesajului din partea de jos"""
	var panel = container.get_node("Panel") as Panel
	if panel:
		var screen_size = get_viewport().size
		panel.position = Vector2(
			(screen_size.x - panel.size.x) / 2,  # Centrat orizontal
			screen_size.y - panel.size.y - 20     # 20px de la marginea de jos
		)

func _on_viewport_size_changed():
	"""Reactualizează poziția când se schimbă dimensiunea viewport-ului"""
	var container = get_node_or_null("BottomMessageContainer")
	if container:
		_update_bottom_message_position(container)

func _on_close_bottom_message():
	"""Închide mesajul din partea de jos"""
	var container = get_node_or_null("BottomMessageContainer")
	if container and container.visible:
		# Animație fade out
		var tween = create_tween()
		tween.tween_property(container, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): container.visible = false)

func _on_confirm_pressed():
	var cost = selected_item_data.get("cost", 0)
	if not DataManager.is_item_unlocked(selected_item_id):
		DataManager.unlock_item(selected_item_id)
		DataManager.add_score(-cost)
	DataManager.equip_item(selected_item_id)
	_refresh_shop()
	


func _on_cancel_pressed():
	print("❌ Anulat")
	#if confirmation_popup:
		#confirmation_popup.visible = false

func _refresh_shop():
	for child in grid_container.get_children():
		var item_id = child.name.replace("Item_", "")
		if DataManager.ITEMS_DATA.has(item_id):
			_update_item_button(child, item_id)
	_update_character_appearance()
	_update_score_display(DataManager.get_score())
	

func _update_item_button(container: VBoxContainer, item_id: String):
	if not container.get_child_count() > 0: return
	var item_button = container.get_child(0) as Button
	var is_equipped = DataManager.is_equipped(item_id)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.4, 0.4, 0) if is_equipped else Color(0.5, 0.3, 0.2)
	style.set_corner_radius_all(12) # Fix crash
	item_button.add_theme_stylebox_override("normal", style)
	


func _update_score_display(new_score: int):
	if score_label: score_label.text = "Puncte: %d" % new_score
	
	if score_label:
		score_label.text = "Puncte: %d" % new_score
	else:
		print("ScoreLabel nu este găsit!")

func _update_character_appearance():
	if hat_slot:
		var id = DataManager.equipped_items.get("hat", "")
		if id != "" and DataManager.ITEMS_DATA.has(id):
			hat_slot.texture = load(DataManager.ITEMS_DATA[id].texture)
		else:
			hat_slot.texture = null
	if scarf_slot:
		var id = DataManager.equipped_items.get("scarf", "")
		if id != "" and DataManager.ITEMS_DATA.has(id):
			scarf_slot.texture = load(DataManager.ITEMS_DATA[id].texture)
		else:
			scarf_slot.texture = null
			


func _on_exit_button_pressed():
	queue_free()
	
	
func _create_confirmation_message_container() -> Control:
	"""Creează containerul pentru mesajul de confirmare cu două butoane"""
	
	# 1. Container principal
	var container = Control.new()
	container.name = "ConfirmationMessageContainer"
	container.anchor_left = 0.0
	container.anchor_right = 1.0
	container.anchor_top = 0.0
	container.anchor_bottom = 1.0
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.visible = false
	
	# 2. Panel pentru mesaj (centrat în partea de jos)
	var panel = Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(500, 150)
	panel.size = Vector2(500, 150)
	
	# Stil pentru panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)  # Fundal semi-transparent
	panel_style.border_color = Color(0.3, 0.3, 0.4, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 15
	panel_style.corner_radius_top_right = 15
	panel_style.corner_radius_bottom_right = 15
	panel_style.corner_radius_bottom_left = 15
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# 3. VBoxContainer pentru conținut
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.size = Vector2(480, 130)
	vbox.position = Vector2(10, 10)
	vbox.add_theme_constant_override("separation", 10)
	
	# 4. Label pentru mesaj
	var message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = "Mesaj de confirmare"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var label_style = LabelSettings.new()
	label_style.font_size = 18
	label_style.font_color = Color(1, 1, 1, 1)
	label_style.line_spacing = 8
	message_label.label_settings = label_style
	
	# 5. HBoxContainer pentru butoane
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 20)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 6. Buton de confirmare (VERDE)
	var confirm_button = Button.new()
	confirm_button.name = "ConfirmButton"
	confirm_button.text = "✓ Confirmă"
	confirm_button.custom_minimum_size = Vector2(120, 40)
	confirm_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Stil pentru butonul de confirmare (VERDE)
	var confirm_normal = StyleBoxFlat.new()
	confirm_normal.bg_color = Color(0.2, 0.7, 0.2, 1.0)  # Verde
	confirm_normal.border_color = Color(1, 1, 1, 1.0)
	confirm_normal.border_width_left = 2
	confirm_normal.border_width_top = 2
	confirm_normal.border_width_right = 2
	confirm_normal.border_width_bottom = 2
	confirm_normal.corner_radius_top_left = 8
	confirm_normal.corner_radius_top_right = 8
	confirm_normal.corner_radius_bottom_right = 8
	confirm_normal.corner_radius_bottom_left = 8
	
	var confirm_hover = confirm_normal.duplicate()
	confirm_hover.bg_color = Color(0.3, 0.8, 0.3, 1.0)  # Verde deschis
	
	var confirm_pressed = confirm_normal.duplicate()
	confirm_pressed.bg_color = Color(0.1, 0.6, 0.1, 1.0)  # Verde închis
	
	confirm_button.add_theme_stylebox_override("normal", confirm_normal)
	confirm_button.add_theme_stylebox_override("hover", confirm_hover)
	confirm_button.add_theme_stylebox_override("pressed", confirm_pressed)
	
	confirm_button.add_theme_font_size_override("font_size", 16)
	confirm_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	confirm_button.focus_mode = Control.FOCUS_NONE
	
	# 7. Buton de închidere (ROȘU)
	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "✕ Anulează"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Stil pentru butonul de închidere (ROȘU)
	var close_normal = StyleBoxFlat.new()
	close_normal.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Roșu
	close_normal.border_color = Color(1, 1, 1, 1.0)
	close_normal.border_width_left = 2
	close_normal.border_width_top = 2
	close_normal.border_width_right = 2
	close_normal.border_width_bottom = 2
	close_normal.corner_radius_top_left = 8
	close_normal.corner_radius_top_right = 8
	close_normal.corner_radius_bottom_right = 8
	close_normal.corner_radius_bottom_left = 8
	
	var close_hover = close_normal.duplicate()
	close_hover.bg_color = Color(0.9, 0.3, 0.3, 1.0)  # Roșu deschis
	
	var close_pressed = close_normal.duplicate()
	close_pressed.bg_color = Color(0.7, 0.1, 0.1, 1.0)  # Roșu închis
	
	close_button.add_theme_stylebox_override("normal", close_normal)
	close_button.add_theme_stylebox_override("hover", close_hover)
	close_button.add_theme_stylebox_override("pressed", close_pressed)
	
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	close_button.focus_mode = Control.FOCUS_NONE
	
	# 8. Asamblează totul
	hbox.add_child(confirm_button)
	hbox.add_child(close_button)
	vbox.add_child(message_label)
	vbox.add_child(hbox)
	panel.add_child(vbox)
	container.add_child(panel)
	
	# 9. Adaugă la scenă
	add_child(container)
	
	# 10. Poziționează panel-ul în partea de jos, centrat
	_update_confirmation_message_position(container)
	
	# 11. Conectează resize-ul viewport-ului
	get_viewport().size_changed.connect(_on_viewport_size_changed_confirmation)
	
	return container


func _update_confirmation_message_position(container: Control):
	"""Actualizează poziția mesajului de confirmare"""
	var panel = container.get_node("Panel") as Panel
	if panel:
		var screen_size = get_viewport().size
		panel.position = Vector2(
			(screen_size.x - panel.size.x) / 2,  # Centrat orizontal
			screen_size.y - panel.size.y - 20     # 20px de la marginea de jos
		)

func _on_viewport_size_changed_confirmation():
	"""Reactualizează poziția mesajului de confirmare la resize"""
	var container = get_node_or_null("ConfirmationMessageContainer")
	if container:
		_update_confirmation_message_position(container)
		
func _show_confirmation_message(message: String, cost: int):
	"""Afișează un mesaj de confirmare cu două butoane"""
	
	# Creează sau găsește containerul pentru mesajul de confirmare
	var message_container = get_node_or_null("ConfirmationMessageContainer")
	if not message_container:
		message_container = _create_confirmation_message_container()
	
	# Actualizează mesajul
	var message_label = message_container.get_node("Panel/VBoxContainer/MessageLabel") as Label
	var confirm_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/ConfirmButton") as Button
	var close_button = message_container.get_node("Panel/VBoxContainer/HBoxContainer/CloseButton") as Button
	
	if message_label:
		message_label.text = message
	
	# Configurează butonul de confirmare
	if confirm_button:
		# Dezactivează conexiunile anterioare pentru a evita duplicate
		if confirm_button.is_connected("pressed", _on_confirm_confirmation_message):
			confirm_button.disconnect("pressed", _on_confirm_confirmation_message)
		
		# Conectează funcția de confirmare cu cost-ul specific
		confirm_button.pressed.connect(_on_confirm_confirmation_message.bind(cost))
	
	# Configurează butonul de închidere
	if close_button:
		if close_button.is_connected("pressed", _on_close_confirmation_message):
			close_button.disconnect("pressed", _on_close_confirmation_message)
		
		close_button.pressed.connect(_on_close_confirmation_message)
	
	# Afișează mesajul cu animație
	message_container.visible = true
	message_container.modulate = Color(1, 1, 1, 0)
	
	# Animație fade in
	var tween = create_tween()
	tween.tween_property(message_container, "modulate", Color(1, 1, 1, 1), 0.3)
	
	# Ascunde automat după 10 secunde (mai mult decât mesajul normal)
	var timer = get_tree().create_timer(10.0)
	timer.timeout.connect(_on_close_confirmation_message)
	
func _ask_for_confirmation(item_name, cost):
	
	_on_confirm_pressed()
	

func _on_confirm_confirmation_message(cost: int):
	"""Funcția apelată când se apasă butonul de confirmare"""
	print("✅ Confirm pressed from popup, cost:", cost)
	
	# Închide mesajul de confirmare
	_on_close_confirmation_message()
	
	# Apelează funcția originală de confirmare
	_on_confirm_pressed()

func _on_close_confirmation_message():
	"""Închide mesajul de confirmare"""
	var container = get_node_or_null("ConfirmationMessageContainer")
	if container and container.visible:
		# Animație fade out
		var tween = create_tween()
		tween.tween_property(container, "modulate", Color(1, 1, 1, 0), 0.3)
		tween.tween_callback(func(): container.visible = false)
