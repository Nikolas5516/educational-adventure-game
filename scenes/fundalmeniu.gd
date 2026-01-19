extends Sprite2D

func scale_to_screen():
	var screen_size = get_viewport_rect().size
	var tex_size = texture.get_size()

	var scale_x = screen_size.x / tex_size.x
	var scale_y = screen_size.y / tex_size.y

	# ca "Keep Aspect Covered"
	var scale_factor = max(scale_x, scale_y)

	scale = Vector2(scale_factor, scale_factor)
	position = screen_size / 2

func _ready():
	
	scale_to_screen()
	get_viewport().size_changed.connect(scale_to_screen)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
