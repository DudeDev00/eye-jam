class_name AliveBody
extends CharacterBody3D

enum States { STATIC, STAND, FOLLOW, ATTACK }

@export var dead_body: PackedScene

@export var visual: Node3D = null
@export var static_pos: Marker3D = null
@export var timer: Timer = null

var state: States = States.STATIC

var speed: float = 2
var default_speed: float = speed

var chance: int = 9

var stand_pos: Vector3 = Vector3.ZERO
var stand_rot: Vector3 = Vector3.ZERO

var is_attacking: bool = false


func _ready() -> void:
	stand_pos = visual.position
	stand_rot = visual.rotation

	visual.position = static_pos.position
	visual.rotation = static_pos.rotation


func _physics_process(delta: float) -> void:
	match state:
		States.STATIC:
			if not is_on_floor():
				velocity += get_gravity() * delta

			visual.position.x = move_toward(visual.position.x, static_pos.position.x, delta)
			visual.position.y = move_toward(visual.position.y, static_pos.position.y, delta)
			visual.position.z = move_toward(visual.position.z, static_pos.position.z, delta)

			visual.rotation.x = move_toward(visual.rotation.x, static_pos.rotation.x, delta)
			visual.rotation.y = move_toward(visual.rotation.y, static_pos.rotation.y, delta)
			visual.rotation.z = move_toward(visual.rotation.z, static_pos.rotation.z, delta)

			move_and_slide()
		# States.STAND:
		# 	if not is_on_floor():
		# 		velocity += get_gravity() * delta
		#
		# 	visual.position.x = move_toward(visual.position.x, stand_pos.x, delta)
		# 	visual.position.y = move_toward(visual.position.y, stand_pos.y, delta)
		# 	visual.position.z = move_toward(visual.position.z, stand_pos.z, delta)
		#
		# 	visual.rotation.x = move_toward(visual.rotation.x, stand_rot.x, delta)
		# 	visual.rotation.y = move_toward(visual.rotation.y, stand_rot.y, delta)
		# 	visual.rotation.z = move_toward(visual.rotation.z, stand_rot.z, delta)
		#
		# 	if visual.position == stand_pos and visual.rotation == stand_rot:
		# 		state = States.FOLLOW
		#
		# 	move_and_slide()
		States.FOLLOW:
			if not is_on_floor():
				velocity += get_gravity() * delta

			var direction: Vector3 = (PlayerStats.position - global_position)
			var distance: float = direction.length()
			direction = direction.normalized()

			if distance < 1.5 and not is_attacking:
				state = States.ATTACK

			look_at(PlayerStats.position)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

			move_and_slide()
		States.ATTACK:
			is_attacking = true
			PlayerStats.take_damage = true

			state = States.FOLLOW

			await get_tree().create_timer(0.5).timeout
			is_attacking = false


func _on_timer_timeout() -> void:
	chance = clampi(chance, 0, 9)
	var num = randi_range(0, chance)
	if num == 0:
		state = States.FOLLOW
		timer.queue_free()


func _on_detector_body_entered(body: Node3D) -> void:
	if body is Item:
		var item: Item = body
		var direction: Vector3 = (PlayerStats.position - global_position)
		item.linear_velocity += direction.normalized() * speed * 2

		chance -= 2
		speed += 0.2


func _on_detector_area_entered(area: Area3D) -> void:
	if area is Shop:
		var shop: Shop = area
		var instance: DeadBody = dead_body.instantiate()

		shop.container.add_child(instance)

		instance.global_position = shop.container.global_position
		instance.global_rotation = shop.container.global_rotation

		shop.sell()

		queue_free()
