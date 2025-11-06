extends MeshInstance3D

func _ready():
	# Load your image file as a texture
	var image_texture = load("res://path/to/your/image.png") 
	
	# Create a new StandardMaterial3D
	var material = StandardMaterial3D.new()
	
	# Assign the loaded texture to the albedo property
	material.albedo_texture = image_texture
	
	# Apply the material to the mesh instance
	# You can use material_override or set_surface_material(0, material)
	self.material_override = material #
	# or self.set_surface_material(0, material) #
