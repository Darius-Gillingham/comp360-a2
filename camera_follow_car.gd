extends Camera3D

@export var min_distance := 2.0
@export var max_distance := 6.0
@export var cam_height := 2.0
@export var first_person_offset := Vector3(0, 0.7, 0) 
@export var wheel_rotation_speed := 5.0

@onready var target: Node3D = get_parent()

@onready var body: MeshInstance3D = target.get_node('race-future/body')
@onready var wheel1: RaycastWheel = target.get_node('WheelFL')
@onready var wheel2: RaycastWheel = target.get_node('WheelFR')

@onready var windshield: CanvasLayer = $Windshield
@onready var console: CanvasLayer = $Console
@onready var wheel: Sprite2D = $Wheel/WheelTest

var first_person := false
var cam_distance := 5.0



func _ready() -> void:
	windshield.visible = false
	console.visible = false
	wheel.visible = false 

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("change_pov"):
		first_person = !first_person
		body.visible = not first_person
		wheel1.visible = not first_person
		wheel2.visible = not first_person
		windshield.visible = first_person
		console.visible = first_person
		wheel.visible = first_person
		
	if first_person:
		if Input.is_action_pressed("turn_left"):
			wheel.rotation -= wheel_rotation_speed * delta
		elif Input.is_action_pressed("turn_right"):
			wheel.rotation += wheel_rotation_speed * delta

	if first_person:
		global_position = target.global_transform.origin + first_person_offset
		global_transform.basis = target.global_transform.basis
	else:
		var direction := target.transform.basis.z.normalized()
		var cam_pos := target.global_transform.origin + direction * cam_distance
		cam_pos.y += cam_height

		var to_target := cam_pos - target.global_transform.origin
		var dist := to_target.length()

		if dist > max_distance:
			to_target = to_target.normalized() * max_distance
		elif dist < min_distance:
			to_target = to_target.normalized() * min_distance

		global_position = target.global_transform.origin + to_target
		look_at(target.global_transform.origin + Vector3.UP * cam_height, Vector3.UP)
