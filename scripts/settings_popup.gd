extends PopupPanel

@onready var volume_slider: HSlider = $Panel/MarginContainer/VBoxContainer/VolumeContainer/VolumeSlider
@onready var music_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $Panel/MarginContainer/VBoxContainer/SFXContainer/SFXSlider
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/TitleContainer/CloseButton
@onready var reset_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/ResetButton
@onready var apply_button: Button = $Panel/MarginContainer/VBoxContainer/ButtonsContainer/ApplyButton

# Referință la DataManager (singleton)
var data_manager = null

func _ready():
	print("⚙️ SettingsPopup ready!")
	
	# Obține referința către DataManager
	data_manager = get_node("/root/DataManager")
	if not data_manager:
		print("❌ DataManager not found!")
		return
	
	# Stilizează fundalul bej și textul negru
	_setup_appearance()
	
	# Conectează butoanele (doar cele existente)
	_setup_buttons()
	
	# Încarcă setările salvate din DataManager
	_load_settings_from_datamanager()
	
	# Conectează semnalele pentru slider-e
	_connect_slider_signals()
	
	print("✅ SettingsPopup initialized successfully!")

func _setup_appearance():
	print("🎨 Setting up appearance...")
	
	# Metoda 1: Stil direct pe PopupPanel
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color("#F5F5DC")  # Bej
	popup_style.border_color = Color("#8B4513")  # Maro închis
	popup_style.border_width_left = 3
	popup_style.border_width_top = 3
	popup_style.border_width_right = 3
	popup_style.border_width_bottom = 3
	popup_style.corner_radius_top_left = 15
	popup_style.corner_radius_top_right = 15
	popup_style.corner_radius_bottom_right = 15
	popup_style.corner_radius_bottom_left = 15
	
	# Adaugă umbră pentru efect 3D
	popup_style.shadow_color = Color(0, 0, 0, 0.3)
	popup_style.shadow_size = 8
	popup_style.shadow_offset = Vector2(4, 4)
	
	# Aplică stilul DIRECT pe PopupPanel
	add_theme_stylebox_override("panel", popup_style)
	
	# Metoda 2: Stil și pe Panel copil (dacă există)
	var panel = get_node_or_null("Panel")
	if panel:
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color("#F5F5DC")  # Bej
		panel.add_theme_stylebox_override("panel", panel_style)
		print("✅ Applied style to Panel")
	
	# Text negru pentru toate label-urile
	_setup_black_text()
	
	print("🎨 Appearance setup complete!")

func _setup_black_text():
	print("⚡ FORCING BLACK font color with all methods...")
	
	# Parcurge toate nodurile și găsește label-uri
	_force_black_on_all_labels(self)
	
	print("✅ All font colors set to BLACK")

func _force_black_on_all_labels(node: Node):
	if node is Label:
		var label = node as Label
		print("🎯 Found label:", label.name, " | Current text:", label.text)
		
		# 1. Theme override (metoda principală)
		label.add_theme_color_override("font_color", Color.BLACK)
		
		# 2. LabelSettings (metoda secundară)
		var current_settings = label.label_settings
		if not current_settings:
			current_settings = LabelSettings.new()
		
		current_settings.font_color = Color.BLACK
		
		# Dimensiune font în funcție de tip
		if "Title" in label.name:
			current_settings.font_size = 24
		else:
			current_settings.font_size = 16
		
		label.label_settings = current_settings
		
		# 3. Update-ul vizual se face automat, dar dacă vrei, poți lăsa doar queue_redraw
		# label.notification(NOTIFICATION_THEME_CHANGED)  # SCOATE/COMENTEAZĂ LINIA ASTA
		label.queue_redraw()
		
		print("✅ Applied BLACK font to:", label.name)
	
	# Parcurge recursiv
	for child in node.get_children():
		_force_black_on_all_labels(child)

func _setup_buttons():
	# Butonul X (închidere) - cel original din structură
	if close_button:
		print("✅ Found close button")
		
		# Stil pentru butonul X (roșu)
		var close_style = StyleBoxFlat.new()
		close_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Roșu
		close_style.border_color = Color.BLACK
		close_style.border_width_left = 2
		close_style.border_width_top = 2
		close_style.border_width_right = 2
		close_style.border_width_bottom = 2
		close_style.corner_radius_top_left = 8
		close_style.corner_radius_top_right = 8
		close_style.corner_radius_bottom_right = 8
		close_style.corner_radius_bottom_left = 8
		
		close_button.add_theme_stylebox_override("normal", close_style)
		close_button.add_theme_font_size_override("font_size", 20)
		close_button.add_theme_color_override("font_color", Color.WHITE)
		
		# *** FIX: conectăm doar dacă nu e deja conectat ***
		if not close_button.pressed.is_connected(_on_close_button_pressed):
			close_button.pressed.connect(_on_close_button_pressed)
	else:
		print("❌ Close button not found!")
	
	# Butonul Reset
	if reset_button:
		reset_button.pressed.connect(_on_reset_button_pressed)
		_style_button(reset_button, Color(0.3, 0.3, 0.8, 1.0))  # Albastru
	
	# Butonul Apply
	if apply_button:
		apply_button.pressed.connect(_on_apply_button_pressed)
		_style_button(apply_button, Color(0.2, 0.7, 0.2, 1.0))  # Verde

func _style_button(button: Button, color: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color.BLACK
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color.WHITE)

func _connect_slider_signals():
	# Conectează semnalele pentru slider-e
	if volume_slider:
		volume_slider.value_changed.connect(_on_slider_value_changed.bind("volume"))
	
	if music_slider:
		music_slider.value_changed.connect(_on_slider_value_changed.bind("music"))
	
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_slider_value_changed.bind("sfx"))

func _load_settings_from_datamanager():
	if not data_manager:
		print("❌ Cannot load settings: DataManager not available")
		return
	
	# Obține setările salvate din DataManager
	var saved_settings = data_manager.get_audio_settings()
	print("📂 Loaded audio settings from DataManager: ", saved_settings)
	
	# Aplică setările la slider-e
	if volume_slider: volume_slider.value = saved_settings.get("volume", 50.0)
	if music_slider: music_slider.value = saved_settings.get("music", 50.0)
	if sfx_slider: sfx_slider.value = saved_settings.get("sfx", 50.0)
	
	# Aplică imediat volumele încărcate
	_apply_audio_settings()

func _save_settings_to_datamanager():
	if not data_manager:
		print("❌ Cannot save settings: DataManager not available")
		return
	
	# Creează dicționarul cu setările curente
	var current_settings = {
		"volume": volume_slider.value if volume_slider else 50.0,
		"music": music_slider.value if music_slider else 50.0,
		"sfx": sfx_slider.value if sfx_slider else 50.0
	}
	
	# Salvează în DataManager (care va salva automat în fișier)
	data_manager.set_audio_settings(current_settings)
	print("💾 Settings saved to DataManager")

func _apply_audio_settings():
	# Aplică setările audio curente la sistem
	_ensure_audio_buses()
	
	# Master volume
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus != -1 and volume_slider:
		AudioServer.set_bus_volume_db(master_bus, _percent_to_db(volume_slider.value))
	
	# Music volume
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus != -1 and music_slider:
		AudioServer.set_bus_volume_db(music_bus, _percent_to_db(music_slider.value))
	
	# SFX volume
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus != -1 and sfx_slider:
		AudioServer.set_bus_volume_db(sfx_bus, _percent_to_db(sfx_slider.value))

func _ensure_audio_buses():
	# Verifică dacă bus-urile Music și SFX există
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "Music")
		
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")

func _percent_to_db(percent: float) -> float:
	# Convert 0-100% to -80dB to 0dB
	var db_value = (percent / 100) * 80 - 80
	return clamp(db_value, -80, 0)

func _on_slider_value_changed(value: float, slider_name: String):
	print(slider_name.capitalize(), " slider changed to:", value, "%")
	
	# Aplică imediat schimbarea la audio (fără a salva)
	_apply_audio_settings()

func _on_reset_button_pressed():
	print("🔄 Reset button pressed")
	
	# Resetează toate slider-ele la 50%
	if volume_slider: volume_slider.value = 50.0
	if music_slider: music_slider.value = 50.0
	if sfx_slider: sfx_slider.value = 50.0
	
	# Aplică reset-ul la audio
	_apply_audio_settings()
	
	# Salvează setările resetate în DataManager
	if data_manager:
		data_manager.reset_audio_settings()
	
	# Afișează mesaj de confirmare
	_show_message("✅ Toate setările au fost resetate la 50%")

func _on_apply_button_pressed():
	print("✅ Apply button pressed")
	
	# Salvează setările curente în DataManager
	_save_settings_to_datamanager()
	
	# Afișează mesaj de confirmare
	_show_message("✅ Setările au fost salvate!")

func _on_close_button_pressed():
	print("✕ Close button pressed!")
	
	# Animare fade-out
	#var tween = create_tween()
	#tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	#
	## După animație, ascunde și distruge
	#await tween.finished
	hide()
	queue_free()

func _show_message(text: String):
	# Afișează un mesaj temporar
	var message_label = get_node_or_null("Panel/MarginContainer/VBoxContainer/MessageLabel")
	if message_label:
		message_label.text = text
		message_label.visible = true
		
		# Ascunde mesajul după 2 secunde
		await get_tree().create_timer(2.0).timeout
		message_label.visible = false

# Închide popup-ul cu ESC
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("ESC pressed - closing popup")
			_on_close_button_pressed()
