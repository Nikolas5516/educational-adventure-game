extends CanvasLayer

# Referință la harta (Area2D-urile) deja instanțiată în editor
# Asigură-te că nodul se numește EXACT "LevelEasy"
@onready var harta_instantiata: Node = $LevelEasy 

# Referință la background/UI, care este de tip Control
# Asigură-te că nodul se numește EXACT "Bg_lvl_usor"
@onready var bg_ui: Control = $Bg_lvl_usor 


func _ready():
	# --------------------------------------------------------------------------
	# 1. Verificarea și Poziționarea Hărții
	# --------------------------------------------------------------------------
	if harta_instantiata:
		harta_instantiata.visible = true
		print("✅ Harta găsită în arbore: ", harta_instantiata.name)
	else:
		push_error("❌ Harta 'LevelEasy' nu a fost găsită în arbore. Verifică numele.")
		
	# --------------------------------------------------------------------------
	# 2. Ordinea de Desenare (Z-Order)
	# --------------------------------------------------------------------------
	
	# Ne asigurăm că nodul de background/UI (Bg_lvl_usor) este ultimul copil al
	# CanvasLayer-ului (rădăcină), forțându-l să se deseneze DEASUPRA hărții.
	if bg_ui and bg_ui.get_parent() == self:
		# Functia move_child mută nodul specificat la indexul dorit (ultimul index)
		move_child(bg_ui, get_child_count() - 1)
		print("✅ Bg_lvl_usor a fost mutat deasupra hărții.")
	
	# --------------------------------------------------------------------------
	# 3. Corectarea Input-ului pe UI
	# --------------------------------------------------------------------------
	# Acesta este pasul critic. Setăm Mouse Filter pe IGNORE pentru a permite click-urilor
	# să treacă la Area2D-urile de sub el.
	if bg_ui:
		bg_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
		print("✅ Mouse Filter setat pe IGNORE pentru Bg_lvl_usor.")

	# --------------------------------------------------------------------------
	# 4. Asigurarea Input-ului pe Regiuni
	# --------------------------------------------------------------------------
	# Dacă nodul Bg_lvl_usor are setat Z Index mai mare decât LevelEasy
	# (vezi imaginea 9309e1.jpg), setează Z Index-ul lui Bg_lvl_usor la 1, iar pe cel
	# al LevelEasy la 0.
	if bg_ui and harta_instantiata:
		bg_ui.z_index = 1 
		harta_instantiata.z_index = 0
