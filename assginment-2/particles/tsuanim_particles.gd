extends GPUParticles3D

func _ready():
	if process_material is ShaderMaterial:
		process_material.set_shader_parameter("width", 15.0)
	
