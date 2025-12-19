extends Node2D

# Încarcă scena pop-up-ului (chenarul)
# VERIFICĂ: Calea trebuie să fie cea unde ai salvat IntrebarePopup.tscn
const INTREBARE_POPUP = preload("res://scenes/UI/lvl_background/lvl_easy/intrebare_pop.tscn")

func _ready():
	# Căutăm nodul care conține toate regiunile (ex: Bucovina, Moldova)
	print("--- SCRIPTUL LEVEL EASY A PORNIT ---")
	if has_node("Regiuni"):
		for regiune in $Regiuni.get_children():
			# Verificăm dacă nodul are semnalul definit în RegiuneBase.gd
			if regiune.has_signal("regiune_activata"):
				# Conectăm semnalul la funcția de mai jos
				regiune.regiune_activata.connect(_deschide_chenar_intrebare)
				print("Conectat: ", regiune.name)
	else:
		push_error("EROARE: Nu am găsit nodul numit 'Regiuni' în LevelEasy!")

# --- ACEASTA ESTE FUNCȚIA CARE ÎȚI LIPSEA ---
func _deschide_chenar_intrebare(id_regiune: String):
	var popup = INTREBARE_POPUP.instantiate()
	add_child(popup)
	popup.init_intrebare(id_regiune)
	var regiune_nod = $Regiuni.get_node_or_null(id_regiune)
	if regiune_nod:
		popup.raspuns_corect_dat.connect(regiune_nod.marcheaza_rezolvata)
		popup.tree_exited.connect(verifica_final_joc)

@onready var ecran_final = $EcranFinal

func verifica_final_joc():
	var toate_gata = true
	
	for regiune in $Regiuni.get_children():
		# Verificăm variabila 'este_rezolvata' din scriptul fiecărei regiuni
		if regiune.has_method("marcheaza_rezolvata") and not regiune.este_rezolvata:
			toate_gata = false
			break
	
	if toate_gata:
		print("Joc Finalizat!")
		ecran_final.visible = true
