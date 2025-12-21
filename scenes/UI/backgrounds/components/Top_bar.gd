extends Control
@onready var settings_popup_scene: PackedScene = preload("res://scenes/SettingsPopup.tscn")
var settings_popup: PopupPanel
var customization_scene = preload("res://scenes/Customization.tscn")  # A 

func _ready() -> void:
	# Instanțiem popup-ul
	settings_popup = settings_popup_scene.instantiate()


	get_tree().root.call_deferred("add_child", settings_popup)


	settings_popup.call_deferred("hide")



func _process(delta: float) -> void:
	pass

func _on_btn_settings_pressed() -> void:
	if not is_instance_valid(settings_popup):
		# dacă din greșeală a fost șters, îl refacem
		settings_popup = settings_popup_scene.instantiate()
		get_tree().root.add_child(settings_popup)
		settings_popup.hide()
	settings_popup.popup_centered()


func _on_btn_home_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/meniuprincipal.tscn")


func _on_btn_shop_pressed() -> void:
	print("🎨 Opening customization scene...")


	#get_tree().change_scene_to_file("res://scenes/CustomizationScene.tscn")


	var customization_scene = preload("res://scenes/Customization.tscn")
	var instance = customization_scene.instantiate()

	# # Asigură-te că instance-ul este adăugat corect
	get_tree().current_scene.add_child(instance)

	# # FORȚEAZĂ procesarea
	await get_tree().process_frame
	await get_tree().process_frame
