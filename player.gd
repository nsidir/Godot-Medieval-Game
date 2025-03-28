extends CharacterBody3D

# Movement settings
@export var speed = 14
@export var fall_acceleration = 75
@export var jump_velocity = 30.0

var target_velocity = Vector3.ZERO
var mouse_sens = 0.3
var rotationPlayer = 0

func _ready():
	# Capture and hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		rotationPlayer = deg_to_rad(-event.relative.x * mouse_sens)
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

	# Jump and gravity and animations
	if is_on_floor():
		if is_moving:
			$Pivot/AnimationPlayer.play("Running/mixamo_com", -1, 10)
		else:
			$Pivot/AnimationPlayer.play("mixamo_com", -1, 1)
		if Input.is_action_just_pressed("jump"):
			target_velocity.y = jump_velocity
			$Pivot/AnimationPlayer.play("Backflip/mixamo_com", -1, 1)
		else:
			target_velocity.y = 0
	else:
		target_velocity.y -= fall_acceleration * delta

	# Apply movement
	velocity = target_velocity
	move_and_slide()
	
