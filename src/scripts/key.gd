extends Node3D

@onready var spot = $key/SpotLight3D
var possible_locations := [Vector3(52, 1, 41), Vector3(-44, 1, 40), Vector3(-52, 1, -4), Vector3(-39, 1, -29), Vector3(1, 1, -30), Vector3(50, 1, -40)] 

func _ready():
	teleport_to_random_position()
	$AnimationPlayer.play("idle")


func teleport_to_random_position():
	var random_index = randi() % possible_locations.size()
	var random_position = possible_locations[random_index]
	global_transform.origin = random_position
	
func toggleBeacon():
	spot.visible = !spot.visible
