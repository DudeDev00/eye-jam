extends Node

var default_money: int = 1000

var money: int = default_money
var take_damage: bool = false
var position: Vector3


func reset() -> void:
	money = default_money
