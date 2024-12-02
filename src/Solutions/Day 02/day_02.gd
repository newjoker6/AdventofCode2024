extends Control

var inputs: String = ProblemInputs.day2Inputs


func _ready() -> void:
	var newInputs: Array = convertInputToArrays(inputs)
	
	var safeCount: int = countSafeReports(newInputs)
	print_rich("The [b]undampened[/b] safe count is: [color=Green]", safeCount)
	
	var safeCountDamp: int = countSafeReportsWithDampener(newInputs)
	print_rich("The [b]dampened[/b] safe count is: [color=Green]", safeCountDamp)


## Example of creating built-in docs
## Converts a multiline string into an [Array] of [Array][lb][int][rb]
func convertInputToArrays(input: String) -> Array:
	var result: Array = []
	var lines: PackedStringArray = input.split("\n")  # Split by line breaks
	
	for line: String in lines:
		if line.strip_edges() != "":  # Ignore empty lines
			var cleanLine: String = line.strip_edges()
			var convArray: Array = cleanLine.split(" ") as Array
			var int_array: Array = convArray.map(func(x): return int(x))
			result.append(int_array)
			
	return result

#region part 1
func isSafe(report: Array) -> bool:
	# Determine if the report is strictly increasing or strictly decreasing
	var increasing: bool = true
	var decreasing: bool = true
	
	for i:int in range(report.size() - 1):
		var diff = report[i + 1] - report[i]
		
		# Rule 2: Check if the difference is out of bounds
		if abs(diff) < 1 or abs(diff) > 3:
			return false
		
		# Rule 1: Check for monotonicity violations
		if diff > 0:  # Increasing
			decreasing = false
		elif diff < 0:  # Decreasing
			increasing = false
		
		# If both increasing and decreasing are false, the report is unsafe
		if not increasing && not decreasing:
			return false

	return increasing || decreasing


func countSafeReports(reports: Array) -> int:
	var safe_count: int = 0
	for report: Array in reports:
		if isSafe(report):
			safe_count += 1
	return safe_count
#endregion

#region part 2
func isSafeWithDampener(report: Array) -> bool:
	# First, check if the report is already safe
	if isSafe(report):
		return true
	
	# Try removing each level and check if the modified report becomes safe
	for i in range(report.size()):
		var modified_report:Array = report.duplicate()
		modified_report.remove_at(i)
		
		if isSafe(modified_report):
			return true
	
	return false


func countSafeReportsWithDampener(reports: Array) -> int:
	var safe_count: int = 0
	for report: Array in reports:
		if isSafeWithDampener(report):
			safe_count += 1
	return safe_count
#endregion
