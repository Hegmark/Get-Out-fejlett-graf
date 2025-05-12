extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player_raycast: RayCast3D = $"../../Player/TwistPivot/PitchPivot/Camera3D/Flashlight/RayCast3D"
@onready var pause_timer := $Timer
@onready var footsteps = $footsteps
@onready var anim = $"wolf/AnimationPlayer"


var waypoints := [
	Vector3(-132, 0, 33),
	Vector3(-50, 0, 47),
	Vector3(89, 0, 38),
	Vector3(-44, 0, 51),
	Vector3(-71, 0, 62),
	Vector3(-41, 0, 45),
	Vector3(48, 0, 38),
	Vector3(-103, 0, 52),
	Vector3(-95, 0, 23),
	Vector3(-13, 0, 32),
	Vector3(75, 0, 37),
	Vector3(-134, 0, 32),
];
var speed := 3 
var player_locked := false
var rng := RandomNumberGenerator.new()

@export var player: Node3D 

func _ready():
	rng.randomize()   
	if waypoints.size() > 0:
		navigation_agent_3d.set_target_position(waypoints[rng.randi_range(0, waypoints.size() - 1)])
		anim.play("chase")

func _physics_process(_delta: float) -> void:
	if !pause_timer.is_stopped():
		footsteps.stop()
		anim.play("idle")
		return
	if !footsteps.playing:
		footsteps.play()
		anim.play("chase")
	check_player_distance()
	move_along_path() 


func move_along_path():
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()

	if (player_locked and local_destination.length() <= 1.5) or local_destination.length() <= 0.5:
		speed = 3

		if player_locked and player_caught():
			Global.victory = false
			get_tree().change_scene_to_file("res://src/end.tscn")

		if !player_locked:
			navigation_agent_3d.set_target_position(waypoints[rng.randi_range(0, waypoints.size() - 1)])

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

func check_player_distance():
	var distance_x = abs(player.global_transform.origin.x - global_transform.origin.x)
	var distance_z = abs(player.global_transform.origin.z - global_transform.origin.z)
	if distance_x <= 30 and distance_z <= 30:
		if !player_caught():
			navigation_agent_3d.set_target_position(Vector3(player.global_position.x, 0, player.global_position.z))
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
		pause_timer.start(12)
