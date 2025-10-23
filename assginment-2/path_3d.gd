@tool
extends Path3D

# export + SetGet is a bootleg approach of creating a "button" in the inspector for tool scripts
@export_range(0, 100) var item_count := 1:
	set(value):
		item_count = value
		spawn_item()
	get:
		return item_count

func spawn_item():
	var offsets = []
	# Points holds the list of baked points that define our smooth curve
	# we can sample this, and the associated up vectors to spawn objects along it
	var points = curve.get_baked_points()
	var upvectors = curve.get_baked_up_vectors()

	# Wipe anything we previously created before continuing
	for child in $spawn.get_children():
		child.free()

	# A rough way of dividing up the road. Not perfect.
	for i in range(item_count):
		offsets.append(float(i)/float(item_count+1))

	for offset_idx in range(offsets.size()):
		# Take our rough divide points and calculate the index position
		var idx = clamp(int(points.size()*(offsets[offset_idx])), 0, points.size()-1)
		var point = points[idx]
		var upVector = upvectors[idx]

		# Create a new Node3D to hold our item and translate it to the point position identified
		var item_ = Node3D.new()
		item_.name = "item_" + str(offset_idx)
		$spawn.add_child(item_)
		item_.translate(point)

		# Here's something I made earlier. Load it and add it to our item holder
		var bollard = preload("res://bollard.tscn").instantiate()
		bollard.name = "bollard"
		item_.add_child(bollard)

		# Translate our item by a given offset relative to the path point.
		# In this case I know the road is exactly 0.1 units wide, so I translate 0.05 units on the
		# ‘x’ axis (relative to our item holder) which moves the item to the center of the road
		bollard.translate(Vector3(0.05,0.0,0.0))

		# Bootleg method of aligning objects to the roads upvector
		if idx+1 > points.size()-1:
			item_.look_at(points[0], upVector)
		else:
			item_.look_at(points[idx+1], upVector)

		# Make item holder and item show up in the editor scene tree
		item_.set_owner(get_tree().get_edited_scene_root())
		bollard.set_owner(get_tree().get_edited_scene_root())
