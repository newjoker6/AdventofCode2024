extends Control

var inputs: String = ProblemInputs.day8Inputs

func _ready() -> void:
	# Parse the grid
	var grid: Array = parse_grid(inputs)
	
	# Part 1
	var start: float = Time.get_ticks_msec()
	var ustart: float = Time.get_ticks_usec()
	var antennas: Dictionary = find_antennas(grid)
	var antinodes: Dictionary = calculate_antinodes(grid, antennas)
	var unique_count: int = count_unique_within_bounds(grid, antinodes)
	var end: float = Time.get_ticks_msec()
	var uend: float = Time.get_ticks_usec()
	print_rich("[center]------------------------------------------")
	print_rich("[center]Unique antinode locations (Part 1): [color=Green]{count}[/color]".format({"count": unique_count}))
	print_rich("[center]------------------------------------------")
	print_rich("[center]Time: [color=Green]{time}[/color]".format({"time": ((end - start) / 1000.0)}))
	print_rich("[center]Accurate Time: [color=Green]{time}[/color]".format({"time": ((uend - ustart) / 1000000.0)}))
	
	# Part 2
	start = Time.get_ticks_msec()
	ustart = Time.get_ticks_usec()
	var part_two_antinodes: Dictionary = calculate_antinodes_part_two(grid, antennas)
	var part_two_unique_count: int = count_unique_within_bounds(grid, part_two_antinodes)
	end = Time.get_ticks_msec()
	uend = Time.get_ticks_usec()
	print_rich("[center]------------------------------------------")
	print_rich("[center]Unique antinode locations (Part 2): [color=Green]{count}[/color]".format({"count": part_two_unique_count}))
	print_rich("[center]------------------------------------------")
	print_rich("[center]Time (Part 2): [color=Green]{time}[/color]".format({"time": ((end - start) / 1000.0)}))
	print_rich("[center]Accurate Time (Part 2): [color=Green]{time}[/color]".format({"time": ((uend - ustart) / 1000000.0)}))


# Parse the input into a 2D array
func parse_grid(input: String) -> Array:
	var grid: Array = []
	for line in input.strip_edges().split("\n"):
		grid.append(line.split(""))
	return grid

#region part 1
# Identify all antennas and group them by frequency
func find_antennas(grid: Array) -> Dictionary:
	var antennas: Dictionary = {}
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var cell = grid[y][x]
			if cell != ".":
				if not antennas.has(cell):
					antennas[cell] = []
				antennas[cell].append(Vector2(x, y))
	return antennas


# Calculate all potential antinode positions
func calculate_antinodes(grid: Array, antennas: Dictionary) -> Dictionary:
	var antinodes: Dictionary = {}
	for freq in antennas.keys():
		antinodes[freq] = []
		var positions = antennas[freq]
		for i in range(positions.size()):
			for j in range(i + 1, positions.size()):
				var p1 = positions[i]
				var p2 = positions[j]
				# Calculate potential antinode locations
				var antinode1 = p1 + (p1 - p2)
				var antinode2 = p2 + (p2 - p1)
				if is_within_bounds(grid, antinode1):
					antinodes[freq].append(antinode1)
				if is_within_bounds(grid, antinode2):
					antinodes[freq].append(antinode2)
	return antinodes


# Count unique antinodes within the bounds of the map
func count_unique_within_bounds(grid: Array, antinodes: Dictionary) -> int:
	var unique_positions: Dictionary = {}
	for freq in antinodes.keys():
		for pos in antinodes[freq]:
			unique_positions[pos] = true
	return unique_positions.size()


# Check if a position is within the bounds of the grid
func is_within_bounds(grid: Array, pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < grid[0].size() and pos.y >= 0 and pos.y < grid.size()
#endregion

#region part 2
# Calculate all potential antinode positions for Part Two
func calculate_antinodes_part_two(grid: Array, antennas: Dictionary) -> Dictionary:
	var antinodes: Dictionary = {}
	for freq in antennas.keys():
		antinodes[freq] = []
		var positions = antennas[freq]

		# Mark all antennas of this frequency as antinodes
		for pos in positions:
			antinodes[freq].append(pos)

		# Calculate antinodes for every pair of antennas
		for i in range(positions.size()):
			for j in range(i + 1, positions.size()):
				var p1 = positions[i]
				var p2 = positions[j]

				# Find all grid positions exactly in line with these two
				var in_line_positions = find_all_in_line(p1, p2, grid)
				for pos in in_line_positions:
					antinodes[freq].append(pos)

	return antinodes



# Finds all grid positions exactly in line with two given positions
func find_all_in_line(p1: Vector2, p2: Vector2, grid: Array) -> Array:
	var in_line_positions: Array = []

	# Calculate the step vector (difference between p1 and p2)
	var dx = p2.x - p1.x
	var dy = p2.y - p1.y

	# Reduce to smallest step using GCD (to handle diagonal lines properly)
	var gcd = abs(greatest_common_divisor(dx, dy))
	dx /= gcd
	dy /= gcd

	# Extend in both directions from p1 and p2
	var pos = p1 - Vector2(dx, dy)
	while is_within_bounds(grid, pos):
		in_line_positions.append(pos)
		pos -= Vector2(dx, dy)

	pos = p2 + Vector2(dx, dy)
	while is_within_bounds(grid, pos):
		in_line_positions.append(pos)
		pos += Vector2(dx, dy)

	return in_line_positions


# Greatest Common Divisor (for reducing step vectors)
func greatest_common_divisor(a: int, b: int) -> int:
	if b == 0:
		return abs(a)
	return greatest_common_divisor(b, a % b)
#endregion
