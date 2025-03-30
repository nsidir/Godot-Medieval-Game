extends CharacterBody3D

# Movement settings
@export var speed = 12
@export var sprint_speed = 20
@export var fall_acceleration = 75
@export var jump_velocity = 30.0
@export var double_jump_velocity = 20.0

var target_velocity = Vector3.ZERO
var mouse_sensX = 0.3
var rotationPlayer = 0
var jumpedOnce = false

func _ready():
	# Capture and hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		rotationPlayer = deg_to_rad(-event.relative.x * mouse_sensX)
		rotate_y(rotationPlayer)

func _physics_process(delta):
	var direction = Vector3.ZERO
	var is_moving = false

	# Input handling
	if Input.is_action_pressed("move_right"): direction.x += 1
	if Input.is_action_pressed("move_left"):  direction.x -= 1
	if Input.is_action_pressed("move_back"):  direction.z += 1
	if Input.is_action_pressed("move_forward"): direction.z -= 1
	

	# Movement processing
	if direction != Vector3.ZERO:
		is_moving = true
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	
	# Rotation processing
	direction = direction.rotated(Vector3.UP, $".".rotation.y)
	
	# Velocity calculations
	target_velocity.x = -direction.x * speed
	target_velocity.z = -direction.z * speed
	if Input.is_action_pressed("Sprint"): 
		target_velocity.x = -direction.x * sprint_speed
		target_velocity.z = -direction.z * sprint_speed

	# Jump and gravity and animations
	if is_on_floor():
		jumpedOnce = false
		if is_moving:
			if Input.is_action_pressed("Sprint"): 
				$Pivot/AnimationPlayer.play("Fast Run/mixamo_com", -1, 1)
			else:
				$Pivot/AnimationPlayer.play("Running/mixamo_com", -1, 10)
		else:
			$Pivot/AnimationPlayer.play("Capoeira/mixamo_com", -1, 1)
		if Input.is_action_just_pressed("jump"):
			target_velocity.y = jump_velocity
			$Pivot/AnimationPlayer.play("Backflip2/mixamo_com", -1, 1.5)
		else:
			target_velocity.y = 0
	else:
		if Input.is_action_just_pressed("jump") && jumpedOnce == false: 
			target_velocity.y = double_jump_velocity
			$Pivot/AnimationPlayer.play("Front Twist Flip/mixamo_com", -1, 1)
			jumpedOnce = true
		else:
			target_velocity.y -= fall_acceleration * delta
	
	if is_on_floor():
		for i in get_slide_collision_count():
			checkForCollision(get_slide_collision(i))
	
		# Apply movement
	velocity = target_velocity
	move_and_slide()

func checkForCollision(kinematicCollision):
	var colObj = kinematicCollision.get_collider()
	var collisionLayerEnabled = colObj.get_collision_layer_value(3);
	if collisionLayerEnabled == true:
		var push_direction = (colObj.global_transform.origin - global_transform.origin).normalized()
		colObj.apply_impulse(push_direction * 1, Vector3.ZERO )
