extends Control

var inputs: String = ProblemInputs.day5Inputs
var inputs2: String = ProblemInputs.day5Inputs2
var invalidPages:Array[Array]


func _ready() -> void:
	#setup
	var rules: Array[Vector2] = setup(inputs)
	var pageNumbers: Array[Array] = prepareUpdates(inputs2)
	
	# Part 1
	var mids: Array[int] = checkPages(rules, pageNumbers)
	var sum:int = sumMids(mids)
	print_rich("[center]\n-------------------------------------------------------\nTotal Sum of all mid pages of [color=Green]valid[/color] pagelists are: [color=Green]",sum,"[/color]\n-------------------------------------------------------")
	
	# Part 2
	var newPageLists:Array[int] = correctUpdates(rules, invalidPages)
	sum = sumMids(newPageLists)
	print_rich("[center]-------------------------------------------------------\nTotal Sum of all mid pages of corrected [color=Red]invalid[/color] pagelists are: [color=Green]",sum,"[/color]\n-------------------------------------------------------")

#region setup
func setup(input: String) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var lines: PackedStringArray = input.strip_edges().split("\n")  # Split into lines
	for line:String in lines:
		var pair: PackedStringArray = line.split("|")  # Split by '|'
		if pair.size() == 2:
			var vec: Vector2 = Vector2(pair[0].to_int(), pair[1].to_int())  # Create Vector2
			result.append(vec)
	return result


func prepareUpdates(input: String) -> Array[Array]:
	var result: Array[Array] = []
	var lines: PackedStringArray = input.strip_edges().split("\n")  # Split into lines
	for line:String in lines:
		var update: Array[int]
		var pageLine: PackedStringArray = line.split(",")
		for page in pageLine:
			update.append(page.to_int())
		result.append(update)
	return result
#endregion


#region part 1
func checkPages(rules: Array[Vector2], pageNumbers: Array[Array]) -> Array[int]:
	var middleNums: Array[int]
	for pageList in pageNumbers:
		var is_valid: bool = true

		for rule in rules:
			var first_page: int = rule.x
			var second_page: int = rule.y

			# Check if both pages are in the current update
			if first_page in pageList and second_page in pageList:
				var first_index: int = pageList.find(first_page)
				var second_index: int = pageList.find(second_page)

				# If the first page does not come before the second, mark invalid
				if first_index >= second_index:
					is_valid = false
					break

		if is_valid:
			var mid: int = int(pageList.size() / 2)
			middleNums.append(pageList[mid])
			print_rich("[color=Green]Valid[/color] page list:", pageList)
		else:
			invalidPages.append(pageList)
			print_rich("[color=Red]Invalid[/color] page list:", pageList)
			
	return middleNums

func sumMids(mids: Array[int]) -> int:
	var total:int
	for num:int in mids:
		total += num
	return total
#endregion


#region part 2
#if there were a much larger set of invalid pages
#or more complex rules a topological sort algorithm
#would be a better and more performant approach

func correctUpdates(rules: Array[Vector2], updates: Array[Array]) -> Array[int]:
	var corrected_updates: Array[int] = []

	for update in updates:
		var sorted_update = update.duplicate()  # Copy the update array
		var changed = true

		# Keep applying rules until no changes are made
		while changed:
			changed = false
			for rule in rules:
				var a = int(rule.x)
				var b = int(rule.y)
				if a in sorted_update and b in sorted_update:
					var index_a = sorted_update.find(a)
					var index_b = sorted_update.find(b)

					# If `a` appears after `b`, swap them
					if index_a > index_b:
						sorted_update[index_a] = b
						sorted_update[index_b] = a
						changed = true

		# Ensure the sorted update matches the size of the original
		if sorted_update.size() == update.size():
			var idx:int = sorted_update.size()/2
			corrected_updates.append(int(sorted_update[idx]))

	return corrected_updates

#endregion
