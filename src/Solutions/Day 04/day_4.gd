extends Control

var inputs: String = ProblemInputs.day4Inputs


func _ready() -> void:
	var grid: Array[Array] = convertInputToGrid(inputs)

	#Part 1
	var count: int = countXmasOccurrences(grid)
	print_rich("Total occurrences of [rainbow freq=0.5 sat=0.3 val=1.0]XMAS[/rainbow]:", "[color=Green]", count, "[/color]")
	
	#Part 2
	count = countXmas(grid)
	print_rich("Total occurrences of [color=Yellow]MAS[/color] in [color=Red]X[/color]: ", "[color=Green]", count, "[/color]")


#region setup
# Converts a multiline string into a 2D Array[Array]
func convertInputToGrid(input: String) -> Array[Array]:
	var grid: Array[Array] = []
	var lines: PackedStringArray = input.strip_edges().split("\n")
	for line in lines:
		var row: Array = line.split("")
		grid.append(row)
	return grid
#endregion

#region part 1
# Helper function to check bounds
func isInBounds(row: int, col: int, rows: int, cols: int) -> bool:
	return row >= 0 and row < rows and col >= 0 and col < cols


func countXmasOccurrences(grid: Array[Array]) -> int:
	var word: String = "XMAS"
	var word_len: int = word.length()
	var count: int = 0
	var rows: int = grid.size()
	var cols: int = grid[0].size()

	# All 8 possible directions as (row_offset, col_offset)
	var directions: Array[Vector2i] = [
		Vector2i(0, 1),    # Right
		Vector2i(0, -1),   # Left
		Vector2i(1, 0),    # Down
		Vector2i(-1, 0),   # Up
		Vector2i(1, 1),    # Down-Right
		Vector2i(1, -1),   # Down-Left
		Vector2i(-1, 1),   # Up-Right
		Vector2i(-1, -1)   # Up-Left
	]

	# Check all starting points in the grid
	for row: int in range(rows):
		for col: int in range(cols):
			# Check each direction from this starting point
			for direction: Vector2i in directions:
				var Match: bool = true
				for i: int in range(word_len):
					var new_row: int = row + direction.x * i
					var new_col: int = col + direction.y * i
					if not isInBounds(new_row, new_col, rows, cols) or grid[new_row][new_col] != word[i]:
						Match = false
						break
				if Match:
					count += 1

	return count
#endregion

#region part 2
func countXmas(grid: Array) -> int:
	var count: int = 0
	var rows: int = grid.size()
	var cols: int = grid[0].size()

	# Iterate over all possible centers where "X-MAS" can fit
	for row: int in range(1, rows - 1):  # Skip the first and last rows
		for col: int in range(1, cols - 1):  # Skip the first and last columns
			if grid[row][col] == "A":
				var TL: String = grid[row-1][col-1]  # top-left diagonal
				var TR: String = grid[row-1][col+1]  # top-right diagonal
				var BL: String = grid[row+1][col-1]  # bottom-left diagonal
				var BR: String = grid[row+1][col+1]  # bottom-right diagonal
				
				 # Check for valid X-MAS patterns
				if (TL == "M" or TL == "S") and (TR == "M" or TR == "S") and (BL == "S" or BL == "M") and (BR == "M" or BR == "S"):
					if (TL == "M" and BR == "S" or TL == "S" and BR == "M") and (TR == "M" and BL == "S" or TR == "S" and BL == "M"):
						count += 1

	return count
#endregion
