class_name Item
extends RigidBody3D

func pre_pick():
	freeze = true


func pre_drop():
	freeze = false
