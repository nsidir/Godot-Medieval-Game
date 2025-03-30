extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var root = Node3D.new()
	root.name = "Generator"
	
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.5
	
	for i in range(30):
		
		var materialTest = StandardMaterial3D.new()
		materialTest.albedo_color = Color(randf(), randf(), randf())

		var mesh_instance = MeshInstance3D.new()
		mesh_instance.mesh = SphereMesh.new()
		mesh_instance.name = "MeshInstance3D"
		mesh_instance.set_surface_override_material(0, materialTest)
		
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = sphere_shape
		collision_shape.name = "CollisionShape3D"
		
		var rigid_body = RigidBody3D.new()
		rigid_body.can_sleep = false
		rigid_body.position.x = randf_range(-20,20)
		rigid_body.position.z = randf_range(-20,20)
		rigid_body.position.y = 10
		rigid_body.name = "ball" + str(i)
		rigid_body.add_child(mesh_instance)
		rigid_body.add_child(collision_shape)
		
		root.add_child(rigid_body)
		
		rigid_body.owner = root
		mesh_instance.owner = root
		collision_shape.owner = root
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	
	add_child(root)
	
	#var scene_path = "res://scenes/bridge_glass_pieces.tscn"
	#var error = ResourceSaver.save(packed_scene, scene_path)
	
#	if not error:
#		print("Saving scene: " + scene_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
