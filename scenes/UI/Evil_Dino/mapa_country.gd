extends Node2D

@onready var counties_root := $Counties

var correct_county := "HR"   # exemplu: Harghita

func _ready() -> void:
	for county in counties_root.get_children():
		if county is Area2D and county.has_signal("county_clicked"):
			county.connect("county_clicked", Callable(self, "_on_county_clicked"))

func _on_county_clicked(county_id: String) -> void:
	_clear_all_marks()

	if county_id == correct_county:
		_get_county(county_id).mark_correct()
	else:
		_get_county(county_id).mark_wrong()

func _get_county(id: String) -> Area2D:
	for county in counties_root.get_children():
		if county.county_id == id:
			return county
	return null

func _clear_all_marks() -> void:
	for county in counties_root.get_children():
		if county.has_method("clear_mark"):
			county.clear_mark()
