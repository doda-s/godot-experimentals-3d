extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5

var gravity_force = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_direction = Vector3.ZERO

@export_range(0.01, 1, 0.01) var horizontal_sense = 5.0
@export_range(0.01, 1, 0.01) var vertical_sense = 5.0

@onready var camera_mount = %CameraMount
@onready var model = $Model

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		var h_rotation = deg_to_rad(-event.relative.x * horizontal_sense)
		var v_rotation = deg_to_rad(-event.relative.y*vertical_sense)
		rotate_y(h_rotation)
		camera_mount.rotate_x(v_rotation)
		model.rotate_y(h_rotation*-1)

func _physics_process(delta):
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity_force * delta
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction = get_direction()
	if direction != Vector3.ZERO:
		model.look_at(global_position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func get_direction() -> Vector3:
	input_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input_direction.y = 0
	input_direction.z = int(Input.is_action_pressed("backward")) - int(Input.is_action_pressed("forward"))
	return (transform.basis * input_direction).normalized()
