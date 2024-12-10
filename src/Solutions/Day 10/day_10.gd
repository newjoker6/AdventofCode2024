extends Control

var inputs: String = ProblemInputs.day10Inputs

func _ready() -> void:
	#inputs = """89010123
#78121874
#87430965
#96549874
#45678903
#32019012
#01329801
#10456732"""
	var res = calculate_total_score(inputs)
	print("Total Score: ", res)
	DisplayServer.clipboard_set(str(res))
	
	var part2_result = calculate_total_ratings(inputs)
	print("Total Ratings: ", part2_result)
	DisplayServer.clipboard_set(str(part2_result))

#region part 1
# Parse the input map into a 2D array of integers
func parse_map(input: String) -> Array:
	var grid = []
	for line in input.strip_edges().split("\n"):
		var row = []
		for c in line.strip_edges():
			if c.is_valid_int():
				row.append(int(c))
		grid.append(row)
	return grid


# Check if a position is within the grid bounds
func is_valid_position(grid: Array, x: int, y: int) -> bool:
	return x >= 0 and x < grid.size() and y >= 0 and y < grid[0].size()

# Find all trailheads (positions with height 0)
func find_trailheads(grid: Array) -> Array:
	var trailheads = []
	for x in range(grid.size()):
		for y in range(grid[0].size()):
			if grid[x][y] == 0:
				trailheads.append(Vector2(x, y))
	return trailheads

# Perform DFS to find all reachable 9 positions from a trailhead
func find_reachable_nines(grid: Array, start: Vector2) -> int:
	var visited = {}
	var stack = [start]
	var reachable_nines = []

	while stack.size() > 0:
		var current = stack.pop_back()
		if current in visited:
			continue
		visited[current] = true
		var x = int(current.x)
		var y = int(current.y)
		var current_height = grid[x][y]

		# If we reach a height-9 position, add it to the reachable set
		if current_height == 9:
			reachable_nines.append(current)

		# Explore neighbors (up, down, left, right)
		for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			var nx = x + offset.x
			var ny = y + offset.y
			if is_valid_position(grid, nx, ny) and not Vector2(nx, ny) in visited:
				var next_height = grid[nx][ny]
				if next_height == current_height + 1:  # Ensure the path increases by 1
					stack.append(Vector2(nx, ny))

	return reachable_nines.size()

# Main function to calculate the total score
func calculate_total_score(input: String) -> int:
	var grid = parse_map(input)
	var trailheads = find_trailheads(grid)
	var total_score = 0

	for trailhead in trailheads:
		total_score += find_reachable_nines(grid, trailhead)

	return total_score
#endregion

#region part 2
# Perform DFS to calculate all distinct hiking trails from a trailhead
func calculate_trailhead_rating(grid: Array, start: Vector2) -> int:
	var distinct_trails = 0
	var stack = [[start]]  # Stack holds paths; each path is a list of Vector2 positions

	while stack.size() > 0:
		var current_path = stack.pop_back()
		var current_position = current_path[-1]  # Get the last position in the current path

		var x = int(current_position.x)
		var y = int(current_position.y)
		var current_height = grid[x][y]

		# If we reach a height-9 position, this is a valid trail
		if current_height == 9:
			distinct_trails += 1
			continue

		# Explore neighbors (up, down, left, right)
		for offset in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			var nx = x + offset.x
			var ny = y + offset.y
			var next_position = Vector2(nx, ny)

			# Check bounds and ensure the path increases by 1
			if is_valid_position(grid, nx, ny):
				var next_height = grid[nx][ny]
				if next_height == current_height + 1 and not next_position in current_path:
					# Create a new path extending the current one
					var new_path = current_path.duplicate()
					new_path.append(next_position)
					stack.append(new_path)

	return distinct_trails

# Main function for Part 2 to calculate the total ratings
func calculate_total_ratings(input: String) -> int:
	var grid = parse_map(input)
	var trailheads = find_trailheads(grid)
	var total_ratings = 0

	for trailhead in trailheads:
		total_ratings += calculate_trailhead_rating(grid, trailhead)

	return total_ratings

#endregion
