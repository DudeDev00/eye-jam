extends CharacterBody3D

const MAX_WALK_SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5

var current_speed: float = MAX_WALK_SPEED
var health: int = 10

@onready var camera: Camera3D = $Camera
@onready var anim_player: AnimationPlayer = $AnimPlayer


func _physics_process(delta: float) -> void:
	PlayerStats.position = global_position

	if PlayerStats.take_damage:
		health -= 1
		anim_player.play("damage")
		if health == 0:
			PlayerStats.reset()
			get_tree().reload_current_scene()
		PlayerStats.take_damage = false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		current_speed = lerpf(current_speed, MAX_WALK_SPEED / 2, delta)
	elif Input.is_action_pressed("run"):
		current_speed = lerpf(current_speed, MAX_WALK_SPEED * 2, delta)
	else:
		current_speed = lerpf(current_speed, MAX_WALK_SPEED, delta)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := camera.global_basis * Vector3(input_dir.x, 0, input_dir.y)
	direction = Vector3(direction.x, 0, direction.z).normalized() * input_dir.length()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
