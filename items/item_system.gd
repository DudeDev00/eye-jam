extends Node

@export var ray_cast: RayCast3D
@export var left_hand: Node3D
@export var interact_label: Label


func _physics_process(_delta: float) -> void:
	interact_label.visible = false

	if left_hand.get_child_count():
		if Input.is_action_just_pressed("interact"):
			var picked_item: Item = left_hand.get_child(0)
			left_hand.remove_child(picked_item)
			get_tree().current_scene.add_child(picked_item)

			picked_item.global_position = left_hand.global_position
			picked_item.global_rotation = left_hand.global_rotation
			picked_item.pre_drop()
		return

	if !ray_cast.is_colliding():
		return

	var hit_node := ray_cast.get_collider()
	if hit_node is not Item:
		return

	var item: Item = hit_node

	interact_label.visible = true

	if Input.is_action_just_pressed("interact"):
		if item.get_parent():
			item.get_parent().remove_child(item)
		left_hand.add_child(item)
		item.global_position = left_hand.global_position
		item.global_rotation = left_hand.global_rotation
		item.pre_pick()
