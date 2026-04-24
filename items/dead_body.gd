class_name DeadBody
extends Item

@export var decay_range: Vector2 = Vector2(0, 100)


func _ready() -> void:
	throw_factor = 0.5
