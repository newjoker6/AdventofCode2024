extends Control

var inputs: String = ProblemInputs.day6Inputs
# Caches the results of obstruction checks for optimization
var obstruction_cache: Dictionary = {}
var virtual_walls: Dictionary = {}
enum Direction { LEFT, RIGHT, UP, DOWN }
var direction_vectors = {
	Direction.LEFT: Vector2(-1, 0),
	Direction.RIGHT: Vector2(1, 0),
	Direction.UP: Vector2(0, -1),
	Direction.DOWN: Vector2(0, 1),
}

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	var grid: Array = parse_grid(inputs)
	
	# Find the starting position and direction of the guard
	var guard_info: Array = find_guard_position(grid)
	var start_pos: Vector2 = guard_info[0]
	var direction: Vector2 = guard_info[1]
	
	# Part 1: Simulate the guard's movement and get the number of distinct positions visited
	var visited_positions: Array = simulate_guard_path(grid, start_pos, direction)
	print_rich("[center]------------------------------------------")
	print("[center]Distinct positions visited (Part 1): [color=Green]{visits}[/color]".format({"visits": visited_positions.size()}))
	print_rich("[center]------------------------------------------")

	# Part 2: Find all positions for adding an obstruction and causing the guard to loop
	print_rich("[center][b]Calculating...[/b][/center]")
	var start = Time.get_ticks_msec()
	var valid_positions = find_valid_obstruction_positions(grid, start_pos, visited_positions)
	var end = Time.get_ticks_msec()
	print_rich("[center]------------------------------------------")
	print("[center]Part 2: Valid obstruction positions: [color=Green]{obstructions}[/color]".format({"obstructions": valid_positions.size()}))
	print_rich("[center]------------------------------------------")
	print_rich("[center][b]Calculations finished: {time}seconds[/b][/center]".format({"time": (floor((end - start) / 1000.0))}) )


#region setup
# Converts the input string into a grid of characters
func parse_grid(input: String) -> Array:
	var grid: Array = []
	var lines: PackedStringArray = input.strip_edges().split("\n")
	for line in lines:
		grid.append(line.split(""))
	return grid
#endregion


#region part 1
# Finds the starting position and direction of the guard
func find_guard_position(grid: Array) -> Array:
	var directions: Dictionary = {
		"^": Vector2(0, -1),
		">": Vector2(1, 0),
		"v": Vector2(0, 1),
		"<": Vector2(-1, 0)
	}
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] in directions.keys():
				return [Vector2(x, y), directions[grid[y][x]]]  # Position and direction
	return [Vector2.ZERO, Vector2.ZERO]  # Default fallback

# Simulates the guard's movement and returns the list of distinct positions visited
func simulate_guard_path(grid: Array, start_pos: Vector2, direction: Vector2) -> Array:
	var visited_positions: Array = []  # Initialize with an empty array
	visited_positions.append(start_pos)  # Add the starting position to the array
	
	var pos: Vector2 = start_pos
	
	while true:
		var next_pos: Vector2 = pos + direction
		
		# Check if the next position is outside the grid
		if next_pos.y < 0 or next_pos.y >= grid.size() or next_pos.x < 0 or next_pos.x >= grid[0].size():
			break  # Guard has left the mapped area
		
		# Check if there is an obstacle in the next position
		if grid[next_pos.y][next_pos.x] == "#":
			# Turn the guard to the right
			direction = Vector2(-direction.y, direction.x)
		else:
			# Move the guard forward
			pos = next_pos
			
			# Add the position if it's not already in the array
			if not visited_positions.has(pos):
				visited_positions.append(pos)
	
	return visited_positions
#endregion


#region part 2
# Simulates the guard's movement and returns all visited positions.
func simulate_guard(map: Array, start: Vector2) -> Array:
	var pos = start
	var direction = Direction.UP
	var visited_positions = {}  # Using a Dictionary for fast lookup

	while is_within_bounds(map, pos):
		visited_positions[pos] = true

		var next_pos = pos + direction_vectors[direction]
		if not is_within_bounds(map, next_pos):
			break

		if is_wall(map, next_pos):
			direction = turn_right(direction)
		else:
			pos = next_pos

	return visited_positions.keys()



# Finds valid positions for adding an obstruction that causes a loop
func find_valid_obstruction_positions(map: Array, start: Vector2, traversed_path: Array) -> Array:
	var valid_positions = []
	var virtual_walls = {}  # Dictionary to simulate temporary walls without modifying map

	for candidate in traversed_path:
		if candidate == start:
			continue  # Skip the starting position

		# Check the cache before recalculating
		if obstruction_cache.has(candidate):
			if obstruction_cache[candidate]:
				valid_positions.append(candidate)
			continue

		# Simulate placing an obstruction
		virtual_walls[candidate] = true
		var causes_loop_result = causes_loop(map, start, virtual_walls)
		obstruction_cache[candidate] = causes_loop_result  # Cache the result
		if causes_loop_result:
			valid_positions.append(candidate)
		virtual_walls.erase(candidate)  # Remove the virtual wall

	return valid_positions


# Optimized loop detection with iteration limit
func causes_loop(map: Array, start: Vector2, virtual_walls: Dictionary) -> bool:
	var pos = start
	var direction = Direction.UP
	var visited_states = {}  # Use a Dictionary to track states (position + direction)

	while is_within_bounds(map, pos):
		var state = str(pos) + ":" + str(direction)  # Serialize state for hashing
		if visited_states.has(state):
			return true  # Loop detected
		visited_states[state] = true

		var next_pos = pos + direction_vectors[direction]
		if not is_within_bounds(map, next_pos):
			break

		# Check for virtual walls first, then physical walls
		if virtual_walls.has(next_pos) or is_wall(map, next_pos):
			direction = turn_right(direction)
		else:
			pos = next_pos

	return false


# Returns true if the position is within the bounds of the map
func is_within_bounds(map: Array, pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < map[0].size() and pos.y >= 0 and pos.y < map.size()


# Returns true if the position contains a wall
func is_wall(map: Array, pos: Vector2) -> bool:
	return is_within_bounds(map, pos) and (map[pos.y][pos.x] == "#" or virtual_walls.has(pos))


func turn_right(direction: int):
	match direction:
		Direction.UP:
			return Direction.RIGHT
		Direction.RIGHT:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.LEFT
		Direction.LEFT:
			return Direction.UP

#endregion
