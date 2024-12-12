extends Control

var inputs: String = ProblemInputs.day11Inputs

func _ready() -> void:
	var stones: PackedInt64Array = parse_input(inputs)  # Use PackedInt64Array for larger values
	
	var start: float = Time.get_ticks_msec()
	var ustart: float = Time.get_ticks_usec()

	# Run the first part of the simulation
	var stones_after_25_blinks: PackedInt64Array = run_simulation_over_frames(stones, 25)
	stones.clear()  # Free memory by clearing the initial stones array

	var end: float = Time.get_ticks_msec()
	var uend: float = Time.get_ticks_usec()

	# Output results for Part 1
	print_rich("[center]------------------------------------------\n Part 1")
	print_rich("[center]------------------------------------------")
	print_rich("[center]Number of stones after 25 blinks: [color=Green]", stones_after_25_blinks.size())
	print_rich("[center]Time: [color=Green]{time}s[/color]".format({"time": ((end - start) / 1000.0)}))
	print_rich("[center]Accurate Time: [color=Green]{time}s[/color]".format({"time": ((uend - ustart) / 1000000.0)}))
	print_rich("[center]------------------------------------------")

#region dont run part 2
	#start = Time.get_ticks_msec()
	#ustart = Time.get_ticks_usec()
#
	## Run the second part of the simulation
	#var stones_after_75_blinks: PackedInt64Array = run_simulation_over_frames(stones_after_25_blinks, 50)
	#stones_after_25_blinks.clear()  # Free memory after using this array
#
	#end = Time.get_ticks_msec()
	#uend = Time.get_ticks_usec()
	##DisplayServer.clipboard_set(str(stones_after_75_blinks.size()))
#
	#print_rich("[center]------------------------------------------\n Part 2")
	#print_rich("[center]------------------------------------------")
	#print_rich("[center]Number of stones after 75 blinks: [color=Green]", stones_after_75_blinks.size())
	#print_rich("[center]Time: [color=Green]{time}s[/color]".format({"time": ((end - start) / 1000.0)}))
	#print_rich("[center]Accurate Time: [color=Green]{time}s[/color]".format({"time": ((uend - ustart) / 1000000.0)}))
	#print_rich("[center]------------------------------------------")
#endregion
	# Clean up remaining temporary files
	cleanup_temporary_files("user://")


func parse_input(input: String) -> PackedInt64Array:
	var packed_array: PackedStringArray = input.split(" ", false)
	var result: PackedInt64Array = PackedInt64Array()
	for element: String in packed_array:
		result.append(int(element))
	return result

# Save a chunk to disk
func save_chunk_to_disk(chunk: PackedInt64Array, filename: String) -> void:
	var file = FileAccess.open(filename, FileAccess.WRITE)
	print(file)
	for stone in chunk:
		file.store_line(str(stone))
	file.close()

# Load a chunk from disk
func load_chunk_from_disk(filename: String) -> PackedInt64Array:
	var file = FileAccess.open(filename, FileAccess.READ)
	var chunk: PackedInt64Array = PackedInt64Array()
	while file.get_position() < file.get_length():
		chunk.append(file.get_line().to_int())
	file.close()
	return chunk

# Clean up temporary files
func cleanup_temporary_files(temp_dir: String) -> void:
	var dir = DirAccess.open(temp_dir)
	if dir == OK:
		dir.list_dir_begin()
		var filename: String = dir.get_next()
		while filename != "":
			if !dir.current_is_dir():  # Ensure it's a file
				dir.remove(temp_dir + "/" + filename)
			filename = dir.get_next()
		dir.list_dir_end()

# Run simulation in chunks with disk offloading
func run_simulation_in_chunks_with_disk(stones: PackedInt64Array, total_blinks: int, chunk_size: int, temp_dir: String) -> PackedInt64Array:
	var current_stones: PackedInt64Array = stones
	var chunk_filenames: Array = []
	var num_chunks = int(ceil(float(current_stones.size()) / chunk_size))

	for i in range(num_chunks):
		var start_index = i * chunk_size
		var end_index = min((i + 1) * chunk_size, current_stones.size())
		var chunk: PackedInt64Array = current_stones.slice(start_index, end_index)
		
		var chunk_result: PackedInt64Array = simulate_blinks(chunk, total_blinks)
		chunk.clear()  # Free memory for the chunk

		var chunk_filename = "%schunk_%s.txt" %[temp_dir, str(i)]
		print(chunk_filename)
		save_chunk_to_disk(chunk_result, chunk_filename)
		chunk_filenames.append(chunk_filename)
		chunk_result.clear()  # Free memory for the result

	var combined_result: PackedInt64Array = PackedInt64Array()
	for chunk_filename in chunk_filenames:
		var chunk_from_disk = load_chunk_from_disk(chunk_filename)
		combined_result.append_array(chunk_from_disk)
		var dir = DirAccess.open(temp_dir)
		dir.remove(chunk_filename)  # Delete after loading

	return combined_result

func run_simulation_over_frames(stones: PackedInt64Array, total_blinks: int) -> PackedInt64Array:
	var temp_dir = "user://simulation_chunks"
	var dir = DirAccess.open("user://")
	if !dir.dir_exists(temp_dir):
		dir.make_dir(temp_dir)
	
	var chunk_size = 1000  # Adjust based on memory constraints
	return run_simulation_in_chunks_with_disk(stones, total_blinks, chunk_size, temp_dir)

# Apply the blink transformation to stones
func applyBlink(stones: PackedInt64Array) -> PackedInt64Array:
	var new_stones: PackedInt64Array = PackedInt64Array()
	for stone: int in stones:
		if stone == 0:
			new_stones.append(1)
		elif str(stone).length() % 2 == 0:
			var stone_str: String = str(stone)
			var mid: int = stone_str.length() / 2
			var left: int = int(stone_str.substr(0, mid))
			var right: int = int(stone_str.substr(mid, stone_str.length() - mid))
			new_stones.append(left)
			new_stones.append(right)
		else:
			new_stones.append(stone * 2024)
	return new_stones

# Simulate multiple blinks
func simulate_blinks(stones: PackedInt64Array, num_blinks: int) -> PackedInt64Array:
	var current_stones: PackedInt64Array = stones
	for i in range(num_blinks):
		current_stones = applyBlink(current_stones)
	return current_stones
