extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast3D  # Raycast for vision
@export var player: Node3D  # Assign player in Inspector

var waypoints := [Vector3(-8, 0, -8), Vector3(8, 0, -8), Vector3(8, 0, 8), Vector3(-8, 0, 8)] # List of waypoints
var current_index := 0 # Current target index
var speed := 5.0 # Movement speed
var player_locked := false # True if current target is player
var force_target := false # Helps changing target from player to next checkpoint

func _ready():
	# Set initial target position
	if waypoints.size() > 0:
		navigation_agent_3d.set_target_position(waypoints[current_index])

func _physics_process(_delta: float) -> void:
	check_vision()  # Continuously check if the player is in sight
	move_along_path()  # Move along the waypoints or toward the player

# Move NPC along the path or towards the player
func move_along_path():
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()

	# If close to target, go to next waypoint or stop chasing if player was reached
	if local_destination.length() < 0.6:
		speed = 5  # Reset the speed to normal
		if player_locked:
			# Stop chasing player and start going back to waypoints
			player_locked = false
			# Reset the force_target flag to allow moving to waypoints
			force_target = false  
		if !player_locked:
			# Proceed to the next waypoint
			current_index = (current_index + 1) % waypoints.size()
		navigation_agent_3d.set_target_position(waypoints[current_index])

	# If the NPC is locked on the player, constantly update target position towards the player
	if player_locked:
		# Continuously update the target position towards the player, ignoring raycast
		navigation_agent_3d.set_target_position(Vector3(player.global_position.x, 0, player.global_position.z))
		speed = 10  # Increase speed when chasing the player

	if direction.length() > 0:
		# Get the direction while ignoring the Y axis
		var flat_direction = Vector3(direction.x, 0, direction.z).normalized()
		# Use `look_at()` to make NPC face the movement direction on the XZ plane
		look_at(global_position + flat_direction, Vector3.UP)
		velocity = direction * speed
		move_and_slide()

	# Prevent getting stuck when velocity is small but navigation is not finished
	if velocity.length() < 0.1 and not navigation_agent_3d.is_navigation_finished():
		navigation_agent_3d.set_target_position(navigation_agent_3d.target_position)

# Check if the NPC can see the player
func check_vision():
	if raycast.is_colliding():
		var seen_object = raycast.get_collider()
		if seen_object == player and !player_locked and !force_target:
			# If the player is seen, start moving towards the player
			navigation_agent_3d.set_target_position(Vector3(seen_object.global_position.x, 0, seen_object.global_position.z))
			player_locked = true  # Lock the target to the player
			speed = 10  # Increase speed when chasing the player
	# No raycast needed for continuous player tracking; if player_locked, continue chasing even without line of sight.
