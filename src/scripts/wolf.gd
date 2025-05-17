extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player_raycast: RayCast3D = $"../../Player/TwistPivot/PitchPivot/Camera3D/Flashlight/RayCast3D"
@onready var pause_timer := $Timer
@onready var footsteps = $footsteps
@onready var anim = $"wolf/AnimationPlayer"


var waypoints := [Vector3(7, 0, -58),
Vector3(80, 0, -58),
Vector3(23, 0, 34),
Vector3(-138, 0, -43),
Vector3(-117, 0, -66),
Vector3(138, 0, -88),
Vector3(97, 0, -17),
Vector3(91, 0, -41),
Vector3(127, 0, 77),
Vector3(28, 0, -33),
Vector3(101, 0, 58),
Vector3(56, 0, -56),
Vector3(34, 0, -9),
Vector3(75, 0, -16),
Vector3(-136, 0, -80),
Vector3(135, 0, 32),
Vector3(-119, 0, -116),
Vector3(72, 0, -37),
Vector3(-122, 0, -5),
Vector3(142, 0, -27),
Vector3(40, 0, 65),
Vector3(-106, 0, -19),
Vector3(60, 0, -14),
Vector3(-135, 0, 49)]
var speed := 10
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
		speed = 10

		if pause_timer.is_stopped() and player_locked and player_caught():
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
		pause_timer.start(15)
