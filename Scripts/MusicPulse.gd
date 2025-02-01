extends CanvasModulate
# I did NOT need to make this
@export var intensity : float = 1.0
@export var thresh : float = 0.3 
@export var thresh2 : float = 0.3 

var spectrum
func _ready():
	spectrum = AudioServer.get_bus_effect_instance(1, 0)

var prev_ammount = 1.0
func _process(delta: float) -> void:
	var ammount = spectrum.get_magnitude_for_frequency_range(5000, 5500).length() * 7.0
	if not (ammount-prev_ammount) > thresh:
		ammount = prev_ammount + 0.1 * (ammount-prev_ammount) 
	if ammount < thresh2:
		ammount = 0.0
	color = Color(1.0, 1.0, 1.0) * (1.0 - intensity + ammount*intensity)
	prev_ammount = ammount
	

