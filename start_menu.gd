extends Control

var tracks = [
	{"name": "Coast Track", "scene": "res://coastCircuit.tscn", "preview": "res://textures/CoastPreview.png"},	
	{"name": "Dune Track", "scene": "res://main.tscn", "preview": "res://textures/DunePreview.png"}	
]
var current_track = 0

@onready var track_label = $TrackLabel
@onready var play_button = $playButton
@onready var track_preview = $HBoxContainer/Preview

func _ready():
	var track_buttons = [$HBoxContainer/leftTrack, $HBoxContainer/rightTrack]
	track_buttons[0].pressed.connect(_on_prev_track)
	track_buttons[1].pressed.connect(_on_next_track)
	_update_labels()
	
	play_button.pressed.connect(_on_play_pressed)
	
func _update_labels():
	track_label.text = tracks[current_track].name
	track_preview.texture = load(tracks[current_track].preview)
	
	
func _on_prev_track():
	current_track = (current_track - 1 + tracks.size()) % tracks.size()
	_update_labels()

func _on_next_track():
	current_track = (current_track + 1 + tracks.size()) % tracks.size()
	_update_labels()
	
func _on_play_pressed():
	get_tree().change_scene_to_file(tracks[current_track].scene)
	print("calling", tracks[current_track].scene )
