extends Node3D

@onready var spot = $key/SpotLight3D
var possible_locations := [Vector3(37, 1, 19), Vector3(10, 1, -14), Vector3(-15, 1, -27), Vector3(-31, 1, -31), Vector3(-42, 1, 10), Vector3(-4, 1, 46)] 

func _ready():
	teleport_to_random_position()
	$AnimationPlayer.play("idle")


func teleport_to_random_position():
	var random_index = randi() % possible_locations.size()
	var random_position = possible_locations[random_index]
	global_transform.origin = random_position
	
func toggleBeacon():
	spot.visible = !spot.visible
