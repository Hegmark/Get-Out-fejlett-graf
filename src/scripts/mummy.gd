extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast3D
@onready var player_raycast: RayCast3D = $"../../Player/TwistPivot/PitchPivot/Camera3D/Flashlight/RayCast3D"
@onready var pause_timer := $Timer
@onready var footsteps = $footsteps
@onready var anim = $Walking_mummy/AnimationPlayer


var waypoints := [Vector3(52, 0, 41), Vector3(-44, 0, 40), Vector3(-52, 0, -4), Vector3(-39, 0, -29), Vector3(1, 0, -30), Vector3(50, 0, -40)] 
var current_index := 0 
var speed := 3 
var player_locked := false

@export var player: Node3D 

func _ready():
	if waypoints.size() > 0:
		navigation_agent_3d.set_target_position(waypoints[current_index])
		anim.play("walk")

func _physics_process(_delta: float) -> void:
	if !pause_timer.is_stopped():
		footsteps.stop()
		anim.play("idle")
		return
	if !footsteps.playing:
		footsteps.play()
		anim.play("walk")
	check_vision()
	move_along_path() 


func move_along_path():
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()

	if (player_locked and local_destination.length() <= 1.5) or local_destination.length() <= 0.5:
		speed = 3

		if pause_timer.is_stopped() and player_locked and player_caught():
			Global.victory = false
			get_tree().change_scene_to_file("res://src/end.tscn")
			return

		if !player_locked:
			current_index = (current_index + 1) % waypoints.size()
			navigation_agent_3d.set_target_position(waypoints[current_index])

	if player_locked:
		navigation_agent_3d.set_target_position(Vector3(player.global_position.x, 0, player.global_position.z))
		speed = 15 

	if direction.length() > 0:
		var flat_direction = Vector3(direction.x, 0, direction.z).normalized()
		look_at(global_position + flat_direction, Vector3.UP)
		velocity = direction * speed
		move_and_slide()
		
	if velocity.length() < 0.1 and not navigation_agent_3d.is_navigation_finished():
		navigation_agent_3d.set_target_position(navigation_agent_3d.target_position)

func check_vision():
	if raycast.is_colliding():
		var seen_object = raycast.get_collider()
		if seen_object == player and !player_caught():
			navigation_agent_3d.set_target_position(Vector3(seen_object.global_position.x, 0, seen_object.global_position.z))
			player_locked = true
			speed = 15
			
	if player_raycast.is_colliding():
		var seen_object = player_raycast.get_collider()
		if seen_object == self and player.get("flashlight_on"):
			_start_pause()
			
func player_caught():
	var distance_x = abs(player.global_transform.origin.x - global_transform.origin.x)
	var distance_z = abs(player.global_transform.origin.z - global_transform.origin.z)
	return distance_x <= 1.2 and distance_z <= 1.2
	
func _start_pause():
	if pause_timer.is_stopped():
		pause_timer.start(5)
