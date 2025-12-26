extends Node2D

@onready var dino: AnimatedSprite2D = $AnimatedSprite2D
var base_scale: Vector2

@export var speed := 1100.0        # pixeli/sec
signal finished


# pentru 1280x720:
@export var spawn_right_x := 200.0   # reapare în dreapta (în afara ecranului)
@export var despawn_left_x := -1400.0  # dispare în stânga (în afara ecranului)

@onready var dust: GPUParticles2D = $GPUParticles2D

@onready var sfx_run: AudioStreamPlayer = $SFX_Run


func _ready():
	if sfx_run.stream:
		$SFX_Run.play()
	else:
		push_warning("NU are stream setat!")
		
	base_scale = dino.scale  # (0.275, 0.25) din Inspector
	dust.emitting = true


	if dino.sprite_frames and dino.sprite_frames.has_animation("run"):
		dino.play("run")
	else:
		dino.play("default")

func _process(delta:float)->void:
	# dreapta -> stânga
	position.x -= speed * delta
	# dreapta -> stânga
	
	position.x -= speed * delta

	# progres 0..1 (dreapta -> stânga)
	var total := spawn_right_x - despawn_left_x
	var progress := (spawn_right_x - position.x) / total
	progress = clamp(progress, 0.0, 1.0)

	# easing (mai cartoon)
	var e: float = pow(progress, 0.35)  # < 1.0 = efectul apare rapid

	# scale logic
	var stretch_x: float = lerp(1.0, 5.0, e)  # crește pe X
	var squash_y: float  = lerp(1.0, 0.3, e)  # scade mult pe Y

	dino.scale = Vector2(
	base_scale.x * stretch_x,
	base_scale.y * squash_y
	)

	# când iese din stânga, reapare în dreapta
	if position.x < despawn_left_x:
		finished.emit()
		queue_free()  # sau set_process(false) dacă preferi
