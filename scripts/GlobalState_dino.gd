extends Node

# Intro-ul dino-ului: doar pe sesiunea curentă, NU se salvează pe disc
var has_seen_intro: bool = false

# Trofeul: ăsta rămâne salvat între sesiuni
var trophy_unlocked: bool = false

const SAVE_PATH := "user://savegame.cfg"

func _ready() -> void:
	load_data()


func load_data() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK:
		# Citim DOAR trofeul din fișier
		trophy_unlocked = cfg.get_value("progress", "trophy_unlocked", false)
	else:
		trophy_unlocked = false

	# Intro-ul îl resetăm la fiecare pornire de joc
	has_seen_intro = false


func save_data() -> void:
	var cfg := ConfigFile.new()
	# Scriem DOAR trofeul, nu și has_seen_intro
	cfg.set_value("progress", "trophy_unlocked", trophy_unlocked)
	cfg.save(SAVE_PATH)

	
func reset_trophy():
	trophy_unlocked = false
	save_data()
	print("🔄 Trofeul a fost resetat pentru debug.")
