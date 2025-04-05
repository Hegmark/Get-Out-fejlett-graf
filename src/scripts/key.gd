extends Node3D

var possible_locations := [Vector3(52, 2, 41), Vector3(-44, 2, 40), Vector3(-52, 2, -4), Vector3(-39, 2, -29), Vector3(1, 2, -30), Vector3(50, 2, -40)] 

func _ready():
	teleport_to_random_position()
	$AnimationPlayer.play("idle")

func teleport_to_random_position():
	var random_index = randi() % possible_locations.size()
	var random_position = possible_locations[random_index]
	global_transform.origin = random_position
