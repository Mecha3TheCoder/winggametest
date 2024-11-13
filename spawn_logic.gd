extends Node


@onready var old_level: Node2D = $"../Levels/level"


const LEVEL1 = preload("res://level.tscn")


func _ready() -> void:
	self.set_multiplayer_authority(1)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("e"):
		spawn_level.rpc()


@rpc("any_peer", "call_local")
func spawn_level():
	print("worked")
	var new_level = LEVEL1.instantiate()
	new_level.global_position = old_level.get_node("end").global_position
	$"../Levels".add_child(new_level, true)
	old_level = new_level
