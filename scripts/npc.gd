extends CharacterBody3D

@export var speed = 14
@export var jump_velocity = 25.0
@export var fall_acceleration = 75
@export var randomXdirection = 1
@export var randomZdirection = 1

var target_velocity = Vector3.ZERO
var direction = Vector3.ZERO

func _ready():
	direction.x = randomXdirection
	direction.z = randomZdirection
	$NpcTimer.timeout.connect(_on_npctimer_timer_timeout)
	$NpcTimer2.timeout.connect(_on_npctimer2_timer_timeout)
	$NpcTimer.start()
	$NpcTimer2.start()

func _physics_process(delta):
	
	$Skeleton3D/AnimationPlayer.play("Front Twist Flip/mixamo_com", -1, 2)
	
	var is_moving = false
	
	
	
	# Movement processing
	if direction != Vector3.ZERO:
		is_moving = true
		direction = direction.normalized()
		$Skeleton3D.basis = Basis.looking_at(direction)
		
	# Velocity calculations
	target_velocity.x = -direction.x * speed
	target_velocity.z = -direction.z * speed
	
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	
	velocity = target_velocity
	move_and_slide()

func _on_npctimer_timer_timeout():
	
	direction.x = randf_range(-1, 1)
	direction.z = randf_range(-1, 1)
	
func _on_npctimer2_timer_timeout():
	
	if is_on_floor():
		target_velocity.y = jump_velocity
	
	
