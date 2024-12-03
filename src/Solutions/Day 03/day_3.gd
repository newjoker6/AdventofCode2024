extends Control

var inputs: String = ProblemInputs.day3Inputs


func _ready() -> void:
	var result: int = calculateMulSum(inputs)
	print_rich("Part 1\tTotal Sum: ", "[color=Green]%s[/color]" %result)
	result = calculateMulSumWithConditions(inputs)
	print_rich("Part 2\tTotal Sum: ", "[color=Green]%s[/color]" %result)
	print_rich("\n[img height=250]res://src/Solutions/Day 03/LeGasp.jpg[/img]")
	get_tree().quit(0) # Quits the program automatically after running because i said so


#region part 1
func calculateMulSum(memory: String) -> int:
	# Define the regular expression to match valid mul(X,Y) instructions
	var regex: RegEx = RegEx.new()
	regex.compile(r"mul\((\d{1,3}),(\d{1,3})\)")

	var total_sum: int = 0
	var matches: Array = regex.search_all(memory)

	# Process all matches at once
	for match in matches:
		# Extract X and Y from the match groups
		var x: int = match.get_string(1).to_int()
		var y: int = match.get_string(2).to_int()

		# Add the product to the total sum
		total_sum += x * y

	return total_sum
#endregion


#region part 2
func calculateMulSumWithConditions(memory: String) -> int:
	# Define regex to match mul(X,Y), do(), and don't() instructions
	var regex: RegEx = RegEx.new()
	regex.compile(r"(mul\((\d{1,3}),(\d{1,3})\)|do\(\)|don't\(\))")

	var total_sum: int = 0
	var is_enabled: bool = true  # Start with mul instructions enabled
	var matches: Array = regex.search_all(memory)

	# Process all matches
	for match in matches:
		var full_match: String = match.get_string(0)

		if full_match == "do()":
			is_enabled = true
			
		elif full_match == "don't()":
			is_enabled = false
			
		elif full_match.begins_with("mul("):
			# Handle mul(X,Y) only if enabled
			if is_enabled:
				var x: int = match.get_string(2).to_int()
				var y: int = match.get_string(3).to_int()
				total_sum += x * y

	return total_sum

#endregion
