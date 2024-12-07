extends Control

var inputs: String = ProblemInputs.day7Inputs


func _ready() -> void:
	# Process and print the result
	#part 1
	var result: int = process_equations(inputs)
	print_rich("[center]---------------------------------\nPart 1\n---------------------------------")
	print_rich("[center]Total calibration result: [color=Green]%d[/color]\n---------------------------------" %result)
	
	# part 2
	var start:float = Time.get_ticks_msec()
	result = process_equations_part2(inputs)
	var end:float = Time.get_ticks_msec()
	print_rich("[center]---------------------------------\nPart 2\n---------------------------------")
	print_rich("[center]Total calibration result: [color=Green]%d[/color]\n---------------------------------" %result)
	print_rich("[center][b]Calculations finished: {time}seconds[/b][/center]".format({"time": (floor((end - start) / 1000.0))}) )


#region part 1
func evaluate_expression(numbers: Array[int], operators: Array[String]) -> int:
	# Evaluates the expression left-to-right based on numbers and operators
	var result: int = numbers[0]
	for i in range(operators.size()):
		if operators[i] == "+":
			result += numbers[i + 1]
		elif operators[i] == "*":
			result *= numbers[i + 1]
	return result


func is_valid_equation(target: int, numbers: Array[int]) -> bool:
	# Checks if any combination of +/* operators can make the numbers produce the target
	var operator_count: int = numbers.size() - 1
	var operator_combinations: Array[Array] = get_operator_combinations(operator_count)

	for operators in operator_combinations:
		if evaluate_expression(numbers, operators) == target:
			return true
	return false


func get_operator_combinations(count: int) -> Array[Array]:
	# Generate all combinations of "+" and "*" for the given count
	var combinations: Array[Array] = []
	var total_combinations: int = int(pow(2, count))
	for i in range(total_combinations):
		var combination: Array[String] = []
		for j in range(count):
			if i & (1 << j) != 0:
				combination.append("*")
			else:
				combination.append("+")
		combinations.append(combination)
	return combinations


func parse_input(input: String) -> Array[Dictionary]:
	# Parse the input into test values and number arrays
	var equations: Array[Dictionary] = []
	for line in input.strip_edges().split("\n"):
		
		var parts_strings: PackedStringArray = line.split(":")
		var parts: Array[String] = []
		for part in parts_strings:
			parts.append(str(part))
			
		var target: int = int(parts[0].strip_edges())
		
		var number_strings: PackedStringArray = parts[1].strip_edges().split(" ")
		var numbers: Array[int] = []
		for num_str in number_strings:
			numbers.append(int(num_str))
		equations.append({"target": target, "numbers": numbers})
		
	return equations


func process_equations(input: String) -> int:
	# Processes all equations and returns the sum of valid test values
	var equations: Array[Dictionary] = parse_input(input)
	var valid_sum: int = 0

	for equation in equations:
		var target: int = equation["target"]
		var numbers: Array[int] = equation["numbers"]
		if is_valid_equation(target, numbers):
			valid_sum += target

	return valid_sum
#endregion


#region part 2
func evaluate_expression_part2(numbers: Array[int], operators: Array[String]) -> int:
	# Evaluates the expression left-to-right based on numbers and operators (including "||" for concatenation)
	var result: int = numbers[0]
	for i in range(operators.size()):
		if operators[i] == "+":
			result += numbers[i + 1]
		elif operators[i] == "*":
			result *= numbers[i + 1]
		elif operators[i] == "||":
			# Concatenate the numbers as strings and convert back to integer
			result = int(str(result) + str(numbers[i + 1]))
	return result


func get_operator_combinations_part2(count: int) -> Array[Array]:
	# Generate all combinations of "+", "*", and "||" for the given count
	var combinations: Array[Array] = []
	var total_combinations: int = int(pow(3, count))  # Now base-3 for three operators
	for i in range(total_combinations):
		var combination: Array[String] = []
		for j in range(count):
			var operator_index: int = (i / int(pow(3, j))) % 3
			if operator_index == 0:
				combination.append("+")
			elif operator_index == 1:
				combination.append("*")
			else:
				combination.append("||")
		combinations.append(combination)
	return combinations


func is_valid_equation_part2(target: int, numbers: Array[int]) -> bool:
	# Checks if any combination of +, *, or || operators can make the numbers produce the target
	var operator_count: int = numbers.size() - 1
	var operator_combinations: Array[Array] = get_operator_combinations_part2(operator_count)

	for operators in operator_combinations:
		if evaluate_expression_part2(numbers, operators) == target:
			return true
	return false


func process_equations_part2(input: String) -> int:
	# Processes all equations and returns the sum of valid test values for Part 2 (with +, *, and || operators)
	var equations: Array[Dictionary] = parse_input(input)
	var valid_sum: int = 0

	for equation in equations:
		var target: int = equation["target"]
		var numbers: Array[int] = equation["numbers"]
		if is_valid_equation_part2(target, numbers):
			valid_sum += target

	return valid_sum

#endregion
