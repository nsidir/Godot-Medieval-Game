extends Marker3D

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotationCamera = deg_to_rad(event.relative.y * mouse_sensY)
		rotate_x(rotationCamera)
	
func _physics_process(delta):
	
	zoomDirection = $CameraMover/Camera3D.global_transform.basis.z
	zoomPosition = $CameraMover.position.z
	
	if Input.is_action_just_pressed("zoom_in"):
		if zoomPosition < -cameraOriginOffsetZ:
			target_direction.x = -zoomDirection.x * zoomSpeed
			target_direction.y = -zoomDirection.y * zoomSpeed
			target_direction.z = -zoomDirection.z * zoomSpeed
		if zoomPosition >= -cameraOriginOffsetZ:
				$CameraMover.position.x = -cameraOriginOffsetX
				$CameraMover.position.y = -cameraOriginOffsetY + 0.6
				$CameraMover.position.z = -cameraOriginOffsetZ + 0.4
	else:
		if Input.is_action_just_pressed("zoom_out"):
			if zoomPosition > zoom_out_max:
				target_direction.x =  zoomDirection.x * zoomSpeed
				target_direction.y =  zoomDirection.y * zoomSpeed
				target_direction.z =  zoomDirection.z * zoomSpeed
				
			if zoomPosition >= -cameraOriginOffsetZ:
				$CameraMover.position.x = 0
				$CameraMover.position.y = 0
				$CameraMover.position.z = 0
				
		else:
			target_direction = Vector3.ZERO
			
		
	$CameraMover.velocity = target_direction
	$CameraMover.move_and_slide()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
