extends Node2D

# 1. Definirea pozelor (Referințe)
@onready var poza_instructiuni = $Instructiuni
@onready var buton_gata = $Gata
@onready var intrebare1 = $Intrebare1 # Asigură-te că numele e identic cu cel din listă
@onready var intrebare2 = $Intrebare2 
@onready var intrebare3 = $Intrebare3 
@onready var intrebare4 = $Intrebare4 
@onready var intrebare5 = $Intrebare5 
@onready var intrebare6 = $Intrebare6
@onready var intrebare7 = $Intrebare7
@onready var felicitari = $Felicitari
@onready var dino = $dino


@onready var corect = $Corect 
@onready var gresit = $Gresit

@onready var bifat1 = $Bifat1
@onready var bifat2 = $Bifat2
@onready var bifat3 = $Bifat3
@onready var bifat4 = $Bifat4
@onready var bifat5 = $Bifat5
@onready var bifat6 = $Bifat6
@onready var bifat7 = $Bifat7


@onready var timisoara = $Timisoara 
@onready var bucuresti = $Bucuresti
@onready var brasov = $Brasov 
@onready var cluj = $Cluj_Napoca
@onready var constanta = $Constanta 
@onready var iasi = $Iasi
@onready var tg_jiu = $Tg_Jiu 

@onready var s_corect = $SunetCorect
@onready var s_gresit = $SunetGresit
@onready var gata_sunet = $gata_sunet
@onready var succes = $succes

func _ready() -> void:
	# Când pornește jocul, pregătim scena
	poza_instructiuni.visible = true
	buton_gata.visible = true
	intrebare1.visible = false
	intrebare2.visible = false
	intrebare3.visible = false
	intrebare4.visible = false
	intrebare5.visible = false
	intrebare6.visible = false
	intrebare7.visible = false

	corect.visible = false
	gresit.visible = false
	
	bifat1.visible = false
	bifat2.visible = false
	bifat3.visible = false
	bifat4.visible = false
	bifat5.visible = false
	bifat6.visible = false
	bifat7.visible = false

	felicitari.visible = false
	dino.visible = false

	# Dacă ai și alte întrebări/pinuri, le ascunzi tot aici

# 2. Funcția pentru butonul Gata
func _on_gata_pressed() -> void:
	gata_sunet.play()
	poza_instructiuni.visible = false
	buton_gata.visible = false
	intrebare1.visible = true
	
	# Start score tracking
	DataManager.start_level_tracking()
	print("🎯 Detectiv: Level tracking started. Score: 0")


# Variabila care ține minte la ce întrebare ești (1, 2, 3, 4 sau 5)
var numar_intrebare_activa = 1

# --- FUNCȚIA PENTRU PINUL 1 ---
func _on_timisoara_pressed():
	# CAZUL 1: Suntem la întrebarea 1 și Pinul 1 este cel CORECT
	if numar_intrebare_activa == 1:
		_raspuns_corect_ales()
		bifat1.visible = true # Apare X-ul peste pinul 1
		
	# CAZUL 2: Suntem la orice altă întrebare unde Pinul 1 este GREȘIT
	else:
		_raspuns_gresit_ales()

# --- FUNCȚIA PENTRU PINUL 2 ---
func _on_bucuresti_pressed():
	# Să zicem că Pinul 2 este corect doar la Întrebarea 4
	if numar_intrebare_activa == 2:
		_raspuns_corect_ales()
		bifat2.visible = true
	else:
		_raspuns_gresit_ales()

func _on_brasov_pressed():
	# Să zicem că Pinul 2 este corect doar la Întrebarea 4
	if numar_intrebare_activa == 5:
		_raspuns_corect_ales()
		bifat5.visible = true
	else:
		_raspuns_gresit_ales()
# --- FUNCȚIA PENTRU PINUL 3 ---
func _on_iasi_pressed():
	# Să zicem că Pinul 3 este corect doar la Întrebarea 2
	if numar_intrebare_activa == 3:
		_raspuns_corect_ales()
		bifat3.visible = true
	else:
		_raspuns_gresit_ales()

func _on_constanta_pressed():
	# Să zicem că Pinul 3 este corect doar la Întrebarea 2
	if numar_intrebare_activa == 4:
		_raspuns_corect_ales()
		bifat4.visible = true
	else:
		_raspuns_gresit_ales()
		
func _on_tg_jiu_pressed():
	# Să zicem că Pinul 3 este corect doar la Întrebarea 2
	if numar_intrebare_activa == 6:
		_raspuns_corect_ales()
		bifat6.visible = true
	else:
		_raspuns_gresit_ales()


func _on_cluj_pressed():
	# Să zicem că Pinul 3 este corect doar la Întrebarea 2
	if numar_intrebare_activa == 7:
		_raspuns_corect_ales()
		bifat7.visible = true
	else:
		_raspuns_gresit_ales()

func _raspuns_corect_ales():
	s_corect.play()
	corect.visible = true
	gresit.visible = false
	
	# Adăugăm puncte pentru răspuns corect
	DataManager.add_level_points(5)
	print("✅ Detectiv: +5 puncte | Total nivel: ", DataManager.get_level_score())
	
	# Așteptăm 2 secunde
	await get_tree().create_timer(2.0).timeout
	corect.visible = false
	
	# Trecem manual la următoarea secvență
	_schimba_intrebarea_vizibila()

func _raspuns_gresit_ales():
	s_gresit.play()
	gresit.visible = true
	corect.visible = false
	# Ascundem mesajul de gresit după o secundă jumate
	await get_tree().create_timer(1.5).timeout
	gresit.visible = false

func _schimba_intrebarea_vizibila():
	# 1. Ascundem întrebarea la care eram
	if numar_intrebare_activa == 1:
		$Intrebare1.visible = false
	elif numar_intrebare_activa == 2:
		$Intrebare2.visible = false
	elif numar_intrebare_activa == 3:
		$Intrebare3.visible = false
	elif numar_intrebare_activa == 4:
		$Intrebare4.visible = false
	elif numar_intrebare_activa == 5:
		$Intrebare5.visible = false
	elif numar_intrebare_activa == 6:
		$Intrebare6.visible = false
	elif numar_intrebare_activa == 7:
		$Intrebare7.visible = false
	# 2. Creștem numărul ca să știm că am trecut mai departe
	numar_intrebare_activa = numar_intrebare_activa + 1
	
	# 3. Arătăm noua întrebare
	if numar_intrebare_activa == 2:
		$Intrebare2.visible = true
	elif numar_intrebare_activa == 3:
		$Intrebare3.visible = true
	elif numar_intrebare_activa == 4:
		$Intrebare4.visible = true
	elif numar_intrebare_activa == 5:
		$Intrebare5.visible = true
	elif numar_intrebare_activa == 6:
		$Intrebare6.visible = true
	elif numar_intrebare_activa == 7:
		$Intrebare7.visible = true
	else:
		print("🏆 Detectiv: Jocul s-a terminat!")
		
		# Commit score la finalul jocului
		DataManager.commit_level_score()
		print("💰 Detectiv: Scor comis la global. Total: ", DataManager.get_score())
		
		succes.play()
		dino.visible = true
		felicitari.visible = true
