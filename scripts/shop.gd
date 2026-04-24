class_name Shop
extends Area3D

@export var container: Node3D = null
@export var anim_player: AnimationPlayer = null
@export var money_label: Label = null
@export var decay_label_3d: Label3D = null

var has_item: bool = false
var decay_range_rand: Vector2i = Vector2(0, 100)
var default_bonus: int = 200
var bonus: int = default_bonus


func _ready() -> void:
	money_label.text = str(PlayerStats.money)

	gen_range()


func _physics_process(_delta: float) -> void:
	if not anim_player.is_playing() and has_item:
		var item := container.get_child(0)
		item.queue_free()
		anim_player.play("RESET")
		has_item = false


func gen_range() -> void:
	decay_range_rand.x = randi_range(0, 100)
	decay_range_rand.y = randi_range(decay_range_rand.x, 100)

	decay_label_3d.text = "Decay - " + str(decay_range_rand)


func sell() -> void:
	bonus = default_bonus
	var item: Item = container.get_child(0)

	anim_player.play("slide")
	has_item = true

	if item is DeadBody:
		var dead_body: DeadBody = item
		if dead_body.decay_range.x < decay_range_rand.y and dead_body.decay_range.x > decay_range_rand.x:
			PlayerStats.money += bonus
			bonus += default_bonus * 2
		if dead_body.decay_range.y > decay_range_rand.x and dead_body.decay_range.y < decay_range_rand.y:
			PlayerStats.money += bonus

	PlayerStats.money += 100

	money_label.text = str(PlayerStats.money)

	gen_range()
