class_name ItemSystem
extends Node

## Time taken to throw in milliseconds.
@export var hold_duration: float = 500.0

@export var ray_cast: RayCast3D
@export var left_hand: Node3D
@export var interact_label: Label

var hit_node

var pressed_time: float = 0
var elasped_time: float = 0

var hand_pos: Vector3


func _ready() -> void:
	hand_pos = left_hand.position


func _physics_process(delta: float) -> void:
	interact_label.visible = false

	if left_hand.get_child_count():
		hit_node = null
		var picked_item: Item = left_hand.get_child(0)
		if ray_cast.is_colliding():
			hit_node = ray_cast.get_collider()

		if hit_node is Shop:
			interact_label.visible = true
			if Input.is_action_just_pressed("interact"):
				var shop: Shop = hit_node

				left_hand.remove_child(picked_item)
				shop.container.add_child(picked_item)

				picked_item.global_position = shop.container.global_position
				picked_item.global_rotation = shop.container.global_rotation

				shop.sell()
				return

		if Input.is_action_just_pressed("interact"):
			left_hand.remove_child(picked_item)

			get_tree().current_scene.add_child(picked_item)

			picked_item.pre_drop()

			picked_item.global_position = left_hand.global_position
			picked_item.global_rotation = left_hand.global_rotation
		elif Input.is_action_just_pressed("attack"):
			pressed_time = Time.get_ticks_msec()
		elif Input.is_action_pressed("attack"):
			var current_time: float = Time.get_ticks_msec()
			elasped_time = current_time - pressed_time
			elasped_time = clampf(elasped_time, 0, hold_duration)
			if elasped_time >= hold_duration / 5:
				left_hand.position.x = move_toward(left_hand.position.x, 0, delta * 10)
		elif Input.is_action_just_released("attack"):
			if elasped_time >= hold_duration / 5:
				throw_item()
				elasped_time = 0
			left_hand.position = hand_pos

		return

	if !ray_cast.is_colliding():
		return

	hit_node = ray_cast.get_collider()
	if hit_node is not Item:
		return

	var item: Item = hit_node

	interact_label.visible = true

	if Input.is_action_just_pressed("interact"):
		if item.get_parent():
			item.get_parent().remove_child(item)
		left_hand.add_child(item)

		item.pre_pick()

		item.global_position = left_hand.global_position
		item.global_rotation = left_hand.global_rotation


func throw_item() -> void:
	var picked_item: Item = left_hand.get_child(0)
	left_hand.remove_child(picked_item)
	get_tree().current_scene.add_child(picked_item)

	picked_item.pre_drop()

	picked_item.global_position = left_hand.global_position
	picked_item.global_rotation = left_hand.global_rotation

	var direction: Vector3 = (ray_cast.global_basis * ray_cast.target_position + Vector3.UP)
	direction = direction.normalized()
	picked_item.linear_velocity = direction * (elasped_time / 50) * picked_item.throw_factor
