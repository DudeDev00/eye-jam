class_name Item
extends RigidBody3D

var throw_factor: float = 1.0


func pre_pick():
	freeze = true


func pre_drop():
	freeze = false
