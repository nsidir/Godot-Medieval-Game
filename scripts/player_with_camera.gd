extends CharacterBody3D

# Movement settings
@export var speed = 6
@export var sprint_speed = 11
@export var fall_acceleration = 75
@export var jump_velocity = 30.0
@export var double_jump_velocity = 20.0
@export var roll_speed = 13

var target_velocity = Vector3.ZERO
var mouse_sensX = 0.3
var rotationPlayer = 0
var jumpedOnce = false
var eating = false
var rolling = false


var bodyVisible = true

#Camera settings and variables
var rotationCamera = 0
var mouse_sensY = 0.2
var cameraOriginOffsetX = -1.2
var cameraOriginOffsetY =  1
var cameraOriginOffsetZ = -0.5
var zoomPosition
var zoomDirection = Vector3.ZERO
var target_direction = Vector3.ZERO
@export var zoomSpeed = 15
@export var zoom_out_max = -10

var direction = Vector3.ZERO
var lookingDirection = Vector3.FORWARD
var is_moving = false

func _ready():
	pass
	
func _input(event):
		
	if event is InputEventMouseMotion:
		rotationPlayer = deg_to_rad(-event.relative.x * mouse_sensX)
		rotate_y(rotationPlayer)
		rotationCamera = deg_to_rad(event.relative.y * mouse_sensY)
		$CameraPivot.rotate_x(rotationCamera)

func _physics_process(delta):
	
	direction = Vector3.ZERO
	
	# Input handling
	if Input.is_action_pressed("move_right"): direction.x = 1
	if Input.is_action_pressed("move_left"):  direction.x = -1
	if Input.is_action_pressed("move_back"):  direction.z = 1
	if Input.is_action_pressed("move_forward"): direction.z = -1
	

	# Movement processing
	if direction != Vector3.ZERO:
		is_moving = true
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	else:
		is_moving = false
	
	# Rotation processing
	direction = direction.rotated(Vector3.UP, $".".rotation.y)
	
	# Velocity calculations
	if rolling:
		target_velocity.x = -lookingDirection.x * roll_speed
		target_velocity.z = -lookingDirection.z * roll_speed
	else:
		if direction != Vector3.ZERO:
			lookingDirection = direction
		target_velocity.x = -direction.x * speed
		target_velocity.z = -direction.z * speed
		if Input.is_action_pressed("Sprint") && !eating: 
			target_velocity.x = -direction.x * sprint_speed
			target_velocity.z = -direction.z * sprint_speed

	# Jump and gravity and animations
	if is_on_floor():
		
		if is_moving:
			
			
				
			
			
			if rolling == false:
				if Input.is_action_just_pressed("eatOrdrink"):
					eating = true
					$Pivot/AnimationPlayer.play("DrinkingRunning/mixamo_com", -1, 1)
				else:
					if $Pivot/AnimationPlayer.current_animation != "DrinkingRunning/mixamo_com":
						eating = false
					if eating == false:
						if Input.is_action_pressed("Sprint"):
							$Pivot/AnimationPlayer.play("Fast Run/mixamo_com", -1, 1)
						else:
							$Pivot/AnimationPlayer.play("Running/mixamo_com", -1, 1)
		else:
			if rolling == false:
				$Pivot/AnimationPlayer.play("Breathing Idle/mixamo_com", -1, 1)
			
		if Input.is_action_just_pressed("jump"):
			target_velocity.y = jump_velocity
			$Pivot/AnimationPlayer.play("Backflip2/mixamo_com", -1, 1.5)
		else:
			target_velocity.y = 0
			
		if  Input.is_action_just_pressed("roll") || jumpedOnce == true:
			$Pivot/AnimationPlayer.play("Quick Roll To Run/mixamo_com", -1, 1.3)
			rolling = true
			jumpedOnce = false
		if $Pivot/AnimationPlayer.current_animation != "Quick Roll To Run/mixamo_com":
				rolling = false
			
	else:
		if Input.is_action_just_pressed("jump") && jumpedOnce == false: 
			target_velocity.y = double_jump_velocity
			$Pivot/AnimationPlayer.play("Front Twist Flip/mixamo_com", -1, 1)
			jumpedOnce = true
		else:
			target_velocity.y -= fall_acceleration * delta
			if !$Pivot/AnimationPlayer.is_playing():
				$Pivot/AnimationPlayer.play("Falling/mixamo_com", -1, 1)
	
	# collision processing
	if is_on_floor():
		for i in get_slide_collision_count():
			checkForCollision(get_slide_collision(i))
	
	# Apply movement
	velocity = target_velocity
	move_and_slide()
	
	
	
	
	
	
	#============================================================== CAMERA
	
	zoomDirection = $CameraPivot/CameraMover/Camera3D.global_transform.basis.z
	zoomPosition = $CameraPivot/CameraMover.position.z
	
	if Input.is_action_just_pressed("zoom_in"):
		if zoomPosition < -cameraOriginOffsetZ:
			target_direction.x = -zoomDirection.x * zoomSpeed
			target_direction.y = -zoomDirection.y * zoomSpeed
			target_direction.z = -zoomDirection.z * zoomSpeed
		if zoomPosition >= -cameraOriginOffsetZ:
				$CameraPivot/CameraMover.position.x = -cameraOriginOffsetX
				$CameraPivot/CameraMover.position.y = -cameraOriginOffsetY + 0.6
				$CameraPivot/CameraMover.position.z = -cameraOriginOffsetZ + 0.4
				if bodyVisible == true:
					bodyVisible = false
					$Pivot.visible = false
					
	else:
		if Input.is_action_just_pressed("zoom_out"):
			if zoomPosition > zoom_out_max:
				target_direction.x =  zoomDirection.x * zoomSpeed
				target_direction.y =  zoomDirection.y * zoomSpeed
				target_direction.z =  zoomDirection.z * zoomSpeed
				
			if zoomPosition >= -cameraOriginOffsetZ:
				$CameraPivot/CameraMover.position.x = 0
				$CameraPivot/CameraMover.position.y = 0
				$CameraPivot/CameraMover.position.z = 0
				if bodyVisible == false:
					bodyVisible = true
					$Pivot.visible = true
				
		else:
			target_direction = Vector3.ZERO
			
		
	$CameraPivot/CameraMover.velocity = target_direction
	$CameraPivot/CameraMover.move_and_slide()
	
	
	

func checkForCollision(kinematicCollision):
	var colObj = kinematicCollision.get_collider()
	#var collisionLayerEnabled = colObj.get_collision_layer_value(3);
	#var collisionLayerEnabled = colObj.is_in_group("Interactable") || colObj.is_in_group("Ground");
	#if collisionLayerEnabled == true:
	if colObj.is_in_group("Interactable") == true:
		var push_direction = (colObj.global_transform.origin - global_transform.origin).normalized()
		colObj.apply_force(push_direction * 60, Vector3.ZERO )
