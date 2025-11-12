extends Control

var tracks = [
	#{"name": "Coast Track", "scene": "res://coastCircuit.tscn", "preview": "res://textures/CoastPreview.png"},	
	{"name": "Dune Track", "scene": "res://main.tscn", "preview": "res://textures/DunePreview.png"},
	{"name": "Alpine Track", "scene": "res://alpine.tscn", "preview": "res://textures/alpinePreview.png"},
	{"name": "City Freeroam", "scene": "res://cityRace.tscn", "preview": "res://textures/cityPreview.png"},
	{"name": "Coastal Hilbert (Slow)", "scene": "res://coastCircuit.tscn", "preview": "res://textures/CoastPreview.png"}
]

var cars = [
	{"name": "toyota", "scene": "res://Toyota/Toyota.tscn", "preview": "res://Toyota/ToyotaSnapshot.png"},
	{"name": "sporty", "scene": "res://SportsCar/SportCar.tscn", "preview": "res://SportsCar/SportsCarSnapshot.png"},
	{"name": "buggy", "scene": "res://Buggy/Buggy.tscn", "preview": "res://Buggy/BuggySnapshot.png"},
	{"name": "golf cart", "scene": "res://GolfCart/GolfCart.tscn", "preview": "res://GolfCart/GolfCartSnapshot.png"},
	{"name": "police", "scene": "res://Police/Police.tscn", "preview": "res://Police/PoliceSnapshot.png"},
	{"name": "wagon", "scene": "res://Wagon/Wagon.tscn", "preview": "res://Wagon/WagonSnapshot.png"}
	
]
var current_track = 0
var current_car = 0

@onready var track_label = $TrackLabel
@onready var play_button = $playButton
@onready var track_preview = $TrackSelector/Preview
@onready var car_label = $CarLabel
@onready var car_preview = $CarSelector/CarPreview

func _ready():
	var track_buttons = [$TrackSelector/leftTrack, $TrackSelector/rightTrack]
	track_buttons[0].pressed.connect(_prev_track)
	track_buttons[1].pressed.connect(_next_track)
	update_labels()
	
	var car_buttons = [$CarSelector/leftCar, $CarSelector/rightCar]
	car_buttons[0].pressed.connect(_prev_car)
	car_buttons[1].pressed.connect(_next_car)
	
	play_button.pressed.connect(_on_play_pressed)
	
func update_labels():
	track_label.text = tracks[current_track].name
	track_preview.texture = load(tracks[current_track].preview)
	car_label.text = cars[current_car].name
	car_preview.texture = load(cars[current_car].preview)
	
	
func _prev_track():
	current_track = (current_track - 1 + tracks.size()) % tracks.size()
	update_labels()

func _next_track():
	current_track = (current_track + 1 + tracks.size()) % tracks.size()
	update_labels()
	
func _prev_car():
	current_car = (current_car - 1 + cars.size()) % cars.size()
	update_labels()

func _next_car():
	current_car = (current_car + 1 + cars.size()) % cars.size()
	print("moving right!")
	update_labels()
	
func _on_play_pressed():
	GlobalData.selected_car_scene = cars[current_car].scene
	
	get_tree().change_scene_to_file(tracks[current_track].scene)
	print("calling", tracks[current_track].scene, "with ", cars[current_car].name)
