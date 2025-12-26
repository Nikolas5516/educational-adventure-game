extends Area2D

@export var county_id: String = ""
@onready var fill := $fill

signal county_clicked(county_id: String)

func _ready() -> void:
	input_pickable = true
	fill.visible = false

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("CLICK pe judet: ", county_id)
		emit_signal("county_clicked", county_id)
		#fill.visible = !fill.visible
		
func mark_correct() -> void:
	fill.visible = true
	fill.color = Color.html("#00d379a6")  # verde 

func mark_wrong() -> void:
	fill.visible = true
	fill.color = Color.html("#ff112ea6")  # roșu

func clear_mark() -> void:
	fill.visible = false
