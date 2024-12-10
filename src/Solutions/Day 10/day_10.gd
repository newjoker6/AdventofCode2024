extends Control

var inputs: String = ProblemInputs.day10Inputs

func _ready() -> void:
	var start: float = Time.get_ticks_msec()
	var ustart: float = Time.get_ticks_usec()
	var result:int = calculate_total_score(inputs)
	var end: float = Time.get_ticks_msec()
	var uend: float = Time.get_ticks_usec()
	print_rich("[center]------------------------------------------\n Part 1")
	print_rich("[center]------------------------------------------")
	print_rich("[center]Total Score: [color=Green]", result)
	print_rich("[center]Time: [color=Green]{time}ms[/color]".format({"time": ((end - start) / 1000.0)}))
	print_rich("[center]Accurate Time: [color=Green]{time}µs[/color]".format({"time": ((uend - ustart) / 1000000.0)}))
	print_rich("[center]------------------------------------------")

	start = Time.get_ticks_msec()
	ustart = Time.get_ticks_usec()
	result = calculate_total_ratings(inputs)
	end = Time.get_ticks_msec()
	uend = Time.get_ticks_usec()
	print_rich("\n[center]------------------------------------------")
	print_rich("[center]Part 2")
	print_rich("[center]------------------------------------------")
	print_rich("[center]Total Ratings: [color=Green]", result)
	print_rich("[center]Time: [color=Green]{time}ms[/color]".format({"time": ((end - start) / 1000.0)}))
	print_rich("[center]Accurate Time: [color=Green]{time}µs[/color]".format({"time": ((uend - ustart) / 1000000.0)}))
	print_rich("[center]------------------------------------------")


#region part 1
func parse_map(input: String) -> Array:
	var grid:Array = []
	for line:String in input.strip_edges().split("\n"):
		var row:Array = []
		for c:String in line.strip_edges():
			if c.is_valid_int():
				row.append(int(c))
		grid.append(row)
	return grid


func is_valid_position(grid: Array, x: int, y: int) -> bool:
	return x >= 0 and x < grid.size() and y >= 0 and y < grid[0].size()


func find_trailheads(grid: Array) -> Array:
	var trailheads:Array = []
	for x:int in range(grid.size()):
		for y:int in range(grid[0].size()):
			if grid[x][y] == 0:
				trailheads.append(Vector2(x, y))
	return trailheads


func find_reachable_nines(grid: Array, start: Vector2) -> int:
	var visited:Dictionary = {}
	var stack:Array = [start]
	var reachable_nines:Array  = []

	while stack.size() > 0:
		var current:Vector2 = stack.pop_back()
		if current in visited:
			continue
		visited[current] = true
		var x:int = int(current.x)
		var y:int = int(current.y)
		var current_height:int = grid[x][y]

		if current_height == 9:
			reachable_nines.append(current)

		for offset:Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			var nx:int = int(x + offset.x)
			var ny:int = int(y + offset.y)
			if is_valid_position(grid, nx, ny) and not Vector2(nx, ny) in visited:
				var next_height:int = grid[nx][ny]
				if next_height == current_height + 1:  
					stack.append(Vector2(nx, ny))

	return reachable_nines.size()


func calculate_total_score(input: String) -> int:
	var grid:Array = parse_map(input)
	var trailheads:Array = find_trailheads(grid)
	var total_score:int = 0

	for trailhead in trailheads:
		total_score += find_reachable_nines(grid, trailhead)

	return total_score
#endregion

#region part 2
func calculate_trailhead_rating(grid: Array, start: Vector2) -> int:
	var distinct_trails:int = 0
	var stack:Array = [[start]] 

	while stack.size() > 0:
		var current_path:Array = stack.pop_back()
		var current_position:Vector2 = current_path[-1]  

		var x:int = int(current_position.x)
		var y:int = int(current_position.y)
		var current_height:int = grid[x][y]

		if current_height == 9:
			distinct_trails += 1
			continue
		
		for offset:Vector2 in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			var nx:int = int(x + offset.x)
			var ny:int = int(y + offset.y)
			var next_position:Vector2 = Vector2(nx, ny)

			if is_valid_position(grid, nx, ny):
				var next_height:int = grid[nx][ny]
				if next_height == current_height + 1 and not next_position in current_path:
					var new_path:Array = current_path.duplicate()
					new_path.append(next_position)
					stack.append(new_path)

	return distinct_trails


func calculate_total_ratings(input: String) -> int:
	var grid:Array = parse_map(input)
	var trailheads:Array = find_trailheads(grid)
	var total_ratings:int = 0

	for trailhead:Vector2 in trailheads:
		total_ratings += calculate_trailhead_rating(grid, trailhead)

	return total_ratings

#endregion
