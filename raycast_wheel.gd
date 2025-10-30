extends RayCast3D
class_name RaycastWheel


#Wheel Properties allowing to change front and back wheels seperatly in inspector
@export_group("Wheel properties")
@export var spring_strength := 1000.0
@export var spring_damping := 30.0
@export var rest_dist := 0.5
@export var over_extend = 0.0
@export var wheel_radius := 0.4
@export var is_motor := false
@export var is_steer := false
@export var grip_curve : Curve
@export var show_debug := false

@onready var wheel: Node3D = get_child(0)
