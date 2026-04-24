class_name Shop
extends Area3D

@export var container: Node3D = null
@export var anim_player: AnimationPlayer = null

var has_item: bool = false


func _physics_process(_delta: float) -> void:
	if not anim_player.is_playing() and has_item:
		var item := container.get_child(0)
		item.queue_free()
		anim_player.play("RESET")
		has_item = false


func sell() -> void:
	var item := container.get_child(0)

	anim_player.play("slide")
	has_item = true

	if item is DeadBody:
		var dead_body: DeadBody = item
		if dead_body.decay_range == Vector2(0, 100):
			pass
