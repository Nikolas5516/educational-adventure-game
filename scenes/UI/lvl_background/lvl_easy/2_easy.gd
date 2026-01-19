extends Control

var baza_date = [
	{
		"titlu": "Care munte este mai înalt?",
		"nume1": "Vârful Moldoveanu", "val1": 2544, "img1": "res://assets/sprites/moldoveanu.jpeg",
		"nume2": "Vârful Omu", "val2": 2507, "img2": "res://assets/sprites/omu.jpeg",
		"cauta_maxim": true # Verificăm cine are valoarea MAI MARE
	},
	{
		"titlu": "Care animal trăiește doar pe cele mai înalte creste de munte?",
		"nume1": "Capra Neagră", "val1": 2500, "img1": "res://assets/sprites/capra.jpg",
		"nume2": "Mistrețul", "val2": 500, "img2": "res://assets/sprites/mistretul.jpg",
		"cauta_maxim": true
	},
	{
		"titlu": "Care întindere de apă este mai mare?",
		"nume1": "Marea Neagră", "val1": 436402, "img1": "res://assets/sprites/mareaneagra.jpg",
		"nume2": "Delta Dunării", "val2": 4152, "img2": "res://assets/sprites/deltadunarii.jpg",
		"cauta_maxim": true
	},
	{
		"titlu": "Care formă de relief este mai joasă și mai netedă?",
		"nume1": "Câmpia Română", "val1": 10, "img1": "res://assets/sprites/campiaromana1.jpeg",
		"nume2": "Dealul Feleacu", "val2": 500, "img2": "res://assets/sprites/feleacu.jpeg",
		"cauta_maxim": false # Verificăm cine are valoarea MAI MICĂ (altitudine joasă)
	},
	{
		"titlu": "Care oraș este mai mare ca populatie?",
		"nume1": "București", "val1": 2000000, "img1": "res://assets/sprites/bucuresti.jpg",
		"nume2": "Brașov", "val2": 250000, "img2": "res://assets/sprites/brasov1.jpg",
		"cauta_maxim": true
	}
]

var index_curent = 0
var scor = 0
var este_inversat = false

@onready var label_titlu = $intrebare
@onready var img_stanga = $Stanga
@onready var img_dreapta = $Dreapta
@onready var nume_1 = $Nume1
@onready var nume_2 = $Nume2
@onready var gata = $final

func _ready():
	randomize() # Asigură-te că numerele aleatorii sunt diferite la fiecare joc
	baza_date.shuffle()
	
	# Start level tracking
	DataManager.start_level_tracking()
	
	afiseaza_intrebare()

func afiseaza_intrebare():
	if index_curent < baza_date.size():
		var date = baza_date[index_curent]
		este_inversat = randf() > 0.5
		
		label_titlu.text = date["titlu"]
		
		if este_inversat:
			nume_1.text = date["nume2"]
			nume_2.text = date["nume1"]
			img_stanga.texture = load(date["img2"])
			img_dreapta.texture = load(date["img1"])
		else:
			nume_1.text = date["nume1"]
			nume_2.text = date["nume2"]
			img_stanga.texture = load(date["img1"])
			img_dreapta.texture = load(date["img2"])
	else:
		final_joc()

func _on_texture_button_1_pressed():
	valideaza_raspuns(true)

func _on_texture_button_2_pressed():
	valideaza_raspuns(false)

func valideaza_raspuns(a_apasat_stanga: bool):
	var date = baza_date[index_curent]
	var v_stanga = date["val1"]
	var v_dreapta = date["val2"]
	
	# Dacă am inversat vizual, inversăm și valorile pentru verificare
	if este_inversat:
		v_stanga = date["val2"]
		v_dreapta = date["val1"]
	
	var e_corect = false
	if date["cauta_maxim"]:
		# Logică pentru "cel mai mare/înalt"
		if a_apasat_stanga: e_corect = v_stanga > v_dreapta
		else: e_corect = v_dreapta > v_stanga
	else:
		# Logică pentru "cel mai jos/mic" (Câmpia)
		if a_apasat_stanga: e_corect = v_stanga < v_dreapta
		else: e_corect = v_dreapta < v_stanga
	
	if e_corect:
		scor += 1
		DataManager.add_level_points(5) # Puncte per răspuns corect
	
	index_curent += 1
	afiseaza_intrebare()

func final_joc():
	gata.text = "Gata! Scor: " + str(scor) + "/" + str(baza_date.size())
	gata.show()
	
	# Commit score to global
	DataManager.commit_level_score()
	
	# Ascundem elementele folosind numele corecte din ierarhia ta
	# Ascundem elementele folosind numele corecte din ierarhia ta
	$chenarIntrebari.hide()
	$intrebare.hide()
	$Stanga.hide()
	$Dreapta.hide()
	$TextureButton.hide()
	$TextureButton1.hide()
	$Nume1.hide()
	$Nume2.hide()
	# Dacă butoanele sunt în HBoxText, ascundem tot containerul:
	
