extends Control
@onready var settings_popup_scene: PackedScene = preload("res://scenes/SettingsPopup.tscn")
var settings_popup: PopupPanel
var customization_scene = preload("res://scenes/Customization.tscn")  # A 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instanțiem popup-ul
	settings_popup = settings_popup_scene.instantiate()
	
	# IMPORTANT: îl adăugăm DEFERRED ca să nu crape
	get_tree().root.call_deferred("add_child", settings_popup)
	
	# Ascundem popup-ul după ce e în tree (tot deferred)
	settings_popup.call_deferred("hide")


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	
	# Varianta A: Încarcă ca scenă separată
	#get_tree().change_scene_to_file("res://scenes/CustomizationScene.tscn")
	
	# Varianta B: Încarcă ca child (dacă vrei suprapus)
	var customization_scene = preload("res://scenes/Customization.tscn")
	var instance = customization_scene.instantiate()
	
	# # Asigură-te că instance-ul este adăugat corect
	get_tree().current_scene.add_child(instance)
	
	# # FORȚEAZĂ procesarea
	await get_tree().process_frame
	await get_tree().process_frame
	
	# # Apelează manual setup-ul dacă e nevoie
	# if instance.has_method("force_setup"):
	#     instance.force_setup()
