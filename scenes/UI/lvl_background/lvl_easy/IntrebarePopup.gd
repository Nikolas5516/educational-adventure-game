extends CanvasLayer
# La începutul scriptului IntrebarePopup.gd
signal raspuns_corect_dat
@onready var mesaj_eroare = $Panel2/MesajEroare # Asigură-te că numele coincide
# În funcția verifica_raspuns(ales), unde e corect:
func verifica_raspuns(ales):
	if ales == raspuns_corect:
		print("Corect!")
		raspuns_corect_dat.emit() 
		await get_tree().create_timer(0.5).timeout # Lansează semnalul către regiune
		queue_free()
	else:
		# Afișăm mesajul de eroare
		mesaj_eroare.visible = true
		# Îl ascundem automat după 1.5 secunde
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(mesaj_eroare):
			mesaj_eroare.visible = false

# Referințe către nodurile tale (verifică să ai aceste nume)
@onready var label_intrebare = $Panel2/IntrebareLabel
@onready var btn_a = $Panel2/Button
@onready var btn_b = $Panel2/Button2
@onready var btn_c = $Panel2/Button3

var raspuns_corect = ""
var regiune_sursa : String = ""

# Dicționar cu întrebări (poți adăuga oricâte aici)

var baza_date_intrebari = {
	"moldova": {
		"text": "Care este cel mai mare oraș și centrul cultural al Moldovei?",
		"a": "Bacău", "b": "Iași", "c": "Suceava",
		"corect": "Iași"
	},
	"bucovina": {
		"text": "Ce mănăstire celebră, numită 'Capela Sixtină a Estului', se află aici?",
		"a": "Voroneț", "b": "Putna", "c": "Sucevița",
		"corect": "Voroneț"
	},
	"transilvania": {
		"text": "Ce formă de relief ocupă cea mai mare parte a acestei regiuni?",
		"a": "Câmpia", "b": "Podișul", "c": "Delta",
		"corect": "Podișul"
	},
	"muntenia": {
		"text": "Care este capitala României, situată în inima Munteniei?",
		"a": "Ploiești", "b": "București", "c": "Târgoviște",
		"corect": "București"
	},
	"oltenia": {
		"text": "Ce râu important curge la marginea de vest a Olteniei?",
		"a": "Oltul", "b": "Dunărea", "c": "Jiul",
		"corect": "Jiul"
	},
	"dobrogea": {
		"text": "Ce mare se învecinează la est cu regiunea Dobrogea?",
		"a": "Marea Neagră", "b": "Marea Caspică", "c": "Marea Mediterană",
		"corect": "Marea Neagră"
	},
	"banat": {
		"text": "Care este principalul oraș al Banatului, aflat pe râul Bega?",
		"a": "Arad", "b": "Reșița", "c": "Timișoara",
		"corect": "Timișoara"
	},
	"crisana": {
		"text": "Ce munți se află în partea de est a regiunii Crișana?",
		"a": "Munții Apuseni", "b": "Munții Făgăraș", "c": "Munții Rodnei",
		"corect": "Munții Apuseni"
	},
	"maramures": {
		"text": "Pentru ce obiecte de artă populară din lemn este faimos Maramureșul?",
		"a": "Ceramică", "b": "Porțile sculptate", "c": "Țesături",
		"corect": "Porțile sculptate"
	},
	"munteMare": {
		"text": "Cum se numesc acești munți care se află în nordul și reprezintă cea mai întinsă grupă a Carpaților?",
		"a": "Carpații Orientali", "b": "Carpații Meridionali", "c": "Carpații Occidentali",
		"corect": "Carpații Orientali"
	},
	"munteMediu": {
		"text": "Această grupă are cei mai înalți munți din România (Vârful Moldoveanu). Cum se numește?",
		"a": "Munții Apuseni", "b": "Carpații Meridionali", "c": "Munții Banatului",
		"corect": "Carpații Meridionali"
	},
	"munteMic": {
		"text": "Cum se numește grupa din vest care are cele mai mici înălțimi dintre Carpați?",
		"a": "Carpații Orientali", "b": "Carpații Meridionali", "c": "Carpații Occidentali",
		"corect": "Carpații Occidentali"
		}
}

func init_intrebare(id_regiune: String):
	regiune_sursa = id_regiune
	if baza_date_intrebari.has(id_regiune):
		var date = baza_date_intrebari[id_regiune]
		label_intrebare.text = date.text
		btn_a.text = date.a
		btn_b.text = date.b
		btn_c.text = date.c
		raspuns_corect = date.corect
	else:
		label_intrebare.text = "Întrebarea pentru " + id_regiune + " lipsește!"

# Conectează semnalul 'pressed' al butoanelor din interfață la aceste funcții:
func _on_buton_a_pressed(): verifica_raspuns(btn_a.text)
func _on_buton_b_pressed(): verifica_raspuns(btn_b.text)
func _on_buton_c_pressed(): verifica_raspuns(btn_c.text)




func _on_button_pressed() -> void:
	verifica_raspuns(btn_a.text)


func _on_button_2_pressed() -> void:
	verifica_raspuns(btn_b.text)


func _on_button_3_pressed() -> void:
	verifica_raspuns(btn_c.text)
