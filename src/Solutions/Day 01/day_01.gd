extends Control


var input: String = ProblemInputs.day1Inputs


func _ready() -> void:
	var lists: Array = setupLists()
	var listLeft: Array[int] = lists[0]
	var listRight: Array[int] = lists[1]
	part1(listLeft, listRight)
	part2(listLeft, listRight)


func part1(left_list: Array[int], right_list: Array[int]) -> void:
	var result: int = calculate_total_distance(left_list, right_list)
	print("Total Distance: ", result)

func setupLists() -> Array:
	var lines: PackedStringArray = input.split("\n")
	var listL: Array[int]
	var listR: Array[int]
	
	for line: String in lines:
		var numbers: PackedStringArray = line.strip_edges().split(" ")
		numbers.remove_at(1)
		numbers.remove_at(1)
		
		if numbers.size() >= 2:
			listL.append(int(numbers[0]))
			listR.append(int(numbers[1]))
			
	return [listL, listR]


func calculate_total_distance(left_list: Array[int], right_list: Array[int]) -> int:
	left_list.sort()
	right_list.sort()

	var total_distance: int = 0

	for i: int in range(left_list.size()):
		total_distance += abs(left_list[i] - right_list[i])

	return total_distance


func part2(left_list: Array[int], right_list: Array[int]) -> void:

	# Compute the similarity score
	var result: int = calculate_similarity_score(left_list, right_list)
	print("Similarity Score: ", result)


func calculate_similarity_score(left_list: Array, right_list: Array) -> int:
	# Create a dictionary to store the frequency of each number in the right list
	var frequency: Dictionary = {}
	for num: int in right_list:
		frequency[num] = frequency.get(num, 0) + 1

	# Calculate the similarity score
	var similarity_score: int = 0
	for num: int in left_list:
		if num in frequency:
			similarity_score += num * frequency[num]

	return similarity_score
