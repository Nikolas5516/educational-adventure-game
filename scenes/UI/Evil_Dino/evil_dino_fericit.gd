extends Node2D

@onready var explosion: GPUParticles2D = $GPUParticles2D
@onready var dino: AnimatedSprite2D = $AnimatedSprite2D

@export var delay_after_explosion: float = 0.15

signal finished
@export var happy_duration: float = 1.0

func _ready():
	# IMPORTANT: dacă vrei să nu fie vizibil înainte
	dino.visible = false

	# pornește explozia
	explosion.emitting = true

	# așteaptă puțin ca să se vadă BOOM
	await get_tree().create_timer(delay_after_explosion).timeout

	# apare dino
	dino.visible = true

	# mic "pop" cartoon la apariție
	var base := dino.scale
	dino.scale = base * 0.85
	var tween := create_tween()
	tween.tween_property(dino, "scale", base, 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(happy_duration).timeout
	finished.emit()
