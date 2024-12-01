extends Control


func _ready() -> void:
	var left_list: Array[int] = [3, 4, 2, 1, 3, 3]
	var right_list: Array[int] = [4, 3, 5, 3, 9, 3]

	var result: int = calculate_total_distance(left_list, right_list)
	print("Total Distance: ", result)


func calculate_total_distance(left_list: Array[int], right_list: Array[int]) -> int:
	left_list.sort()
	right_list.sort()

	var total_distance: int = 0

	for i: int in range(left_list.size()):
		total_distance += abs(left_list[i] - right_list[i])

	return total_distance
