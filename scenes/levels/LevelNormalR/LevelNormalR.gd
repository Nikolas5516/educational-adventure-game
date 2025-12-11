extends Node2D

# Dicționar pentru a salva pozițiile inițiale ale pieselor
var original_positions = {}

func _ready():
	print("Scena este gata!")
	$MessageLabel.visible = false

	# Salvăm pozițiile inițiale ale tuturor pieselor
	for piece in $PiecesContainer.get_children():
		original_positions[piece] = piece.global_position
		if piece.has_signal("dropped"):
			piece.connect("dropped", _on_piece_dropped)


func _on_piece_dropped(piece):
	var found_correct_slot = false
	var overlapping_areas = piece.get_overlapping_areas()

	# Verificăm dacă piesa este peste vreun slot valid
	for area in overlapping_areas:
		# Verificăm doar sloturile, nu și TopBar sau alte zone
		if area.name.begins_with("Slot") and area.get("is_occupied") == false:
			if area.correct_id == piece.piece_id:
				# Snap dacă e destul de aproape
				var distanta = piece.global_position.distance_to(area.global_position)
				if distanta < 35:
					snap_piece_to_slot(piece, area)
					found_correct_slot = true
					break

	# Dacă piesa nu a fost plasată într-un slot valid, o resetăm
	if not found_correct_slot:
		_reset_piece_to_original_position(piece)
		_show_message("Piesa nu a fost plasată corect și a fost resetată!")

	# Verificăm dacă toate piese sunt plasate corect
	if found_correct_slot:
		_check_all_pieces_placed()


func snap_piece_to_slot(piece, slot):
	piece.global_position = slot.global_position
	piece.locked = true
	slot.is_occupied = true
	_show_message("Piesa a fost plasată corect!")


func _reset_piece_to_original_position(piece):
	# Resetăm piesa la poziția inițială
	if piece in original_positions:
		piece.global_position = original_positions[piece]
	piece.locked = false

	# Dacă piesa a fost mutată în TopBar, o readucem în PiecesContainer
	if piece.get_parent() != $PiecesContainer:
		var current_parent = piece.get_parent()
		current_parent.remove_child(piece)
		$PiecesContainer.add_child(piece)

	# Re-conectăm semnalul dacă s-a pierdut
	if piece.has_signal("dropped") and not piece.is_connected("dropped", _on_piece_dropped):
		piece.connect("dropped", _on_piece_dropped)


func _check_all_pieces_placed():
	for piece in $PiecesContainer.get_children():
		if not piece.locked:
			return # încă există o piesă neplasată complet
	_show_completion_message()


func _show_completion_message():
	_show_message("Felicitări! Ai completat puzzle-ul!")


# Funcție comună pentru afișarea mesajelor în joc și în debugger
func _show_message(text):
	$MessageLabel.text = text
	$MessageLabel.visible = true
	print(text)  # Afișează și în debugger
	
