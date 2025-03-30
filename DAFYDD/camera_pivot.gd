extends Marker3D

var rotationCamera = 0
var mouse_sensY = 0.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotationCamera = deg_to_rad(event.relative.y * mouse_sensY)
		$Camera3D.rotate_x(rotationCamera)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
