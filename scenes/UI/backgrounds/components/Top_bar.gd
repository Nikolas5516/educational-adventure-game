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

	# 1) Ia sau creează CanvasLayer-ul de overlay (o singură dată)
	var root := get_tree().root
	var layer := root.get_node_or_null("CustomizationLayer") as CanvasLayer
	if layer == null:
		layer = CanvasLayer.new()
		layer.name = "CustomizationLayer"
		layer.layer = 100  # mare = deasupra altor CanvasLayer-uri
		root.add_child(layer)

	# 2) Creează instanța scenei
	var customization_scene = preload("res://scenes/Customization.tscn")
	var instance = customization_scene.instantiate()
	instance.name = "Customization"  # util pt debug / găsire

	# 3) Adaugă în layer (NU direct în root)
	layer.add_child(instance)

	# 4) Fullscreen dacă root-ul e Control
	if instance is Control:
		instance.set_anchors_preset(Control.PRESET_FULL_RECT)
		instance.offset_left = 0
		instance.offset_top = 0
		instance.offset_right = 0
		instance.offset_bottom = 0

	# 5) Stabilizare (ca aveai)
	await get_tree().process_frame
	await get_tree().process_frame
