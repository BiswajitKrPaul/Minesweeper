extends TileMap

@export var rows: int = 9
@export var columns: int = 9
@export var no_of_mines: int = 10
@onready var map: TileMap = %Map

const layer_id: int = 0
const source_id: int = 0

var gameOver: bool = false
var mineTappedIndex: int = -10
var clickedOnce: bool = false

var mines_coordinate: Array[Vector2]
var flag_coordinates: Array[Vector2i]
var tapped_coordinates: Array[Vector2i]
var first_click_coordinate: Vector2i

var number_map = {}

var cell_map = {
	"1": Vector2i(0, 0),
	"2": Vector2i(1, 0),
	"3": Vector2i(2, 0),
	"4": Vector2i(3, 0),
	"5": Vector2i(4, 0),
	"6": Vector2i(0, 1),
	"7": Vector2i(1, 1),
	"8": Vector2i(2, 1),
	"blank": Vector2(3, 1),
	"mine_tapped": Vector2i(4, 1),
	"flag": Vector2i(0, 2),
	"mine": Vector2i(1, 2),
	"default": Vector2i(2, 2),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.new().gameOver.connect(on_game_over)
	_restart()


func _restart() -> void:
	on_game_over(false)
	clickedOnce = false
	first_click_coordinate = Vector2i(-100, -100)
	mineTappedIndex = -10
	mines_coordinate.clear()
	flag_coordinates.clear()
	tapped_coordinates.clear()
	number_map.clear()
	scale = Vector2(1.5, 1.5)
	build_map()


func _process(_delta):
	on_mouse_click()


func on_game_over(isGameOver: bool):
	gameOver = isGameOver
	for i in mines_coordinate.size():
		if mineTappedIndex != i:
			erase_cell(layer_id, Vector2(mines_coordinate[i].x, mines_coordinate[i].y))
			set_tile_cell(Vector2(mines_coordinate[i].x, mines_coordinate[i].y), cell_map["mine"])


func on_mouse_click() -> void:
	if gameOver == true:
		return
	if Input.is_action_just_pressed("on_tap"):
		if clickedOnce == false:
			first_click_coordinate = map.local_to_map(get_local_mouse_position())
			place_mines()
			clickedOnce = true
			if !number_map.has(first_click_coordinate):
				flood_mines(first_click_coordinate)

		var coor: Vector2i = map.local_to_map(get_local_mouse_position())
		# //Checking if the mouse clicked outside the map or not
		if map.get_cell_atlas_coords(layer_id, coor) != Vector2i(-1, -1):
			if is_valid_coordinate(coor) and not tapped_coordinates.has(coor):
				tapped_coordinates.append(coor)
				if get_cell_tile_data(layer_id, coor).get_custom_data("has_mine") == true:
					erase_cell(layer_id, coor)
					set_tile_cell(coor, cell_map["mine_tapped"])
					mineTappedIndex = mines_coordinate.find(Vector2(coor.x, coor.y))
					on_game_over(true)
				else:
					if flag_coordinates.has(coor):
						return
					elif mines_coordinate.has(Vector2(coor.x, coor.y)):
						return
					else:
						erase_cell(layer_id, coor)
						if number_map.has(coor):
							match number_map[coor]:
								1:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["1"])
								2:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["2"])
								3:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["3"])
								4:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["4"])
								5:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["5"])
								6:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["6"])
								7:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["7"])
								8:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["8"])
								_:
									erase_cell(layer_id, coor)
									set_tile_cell(coor, cell_map["blank"])

						else:
							erase_cell(layer_id, coor)
							set_tile_cell(coor, cell_map["blank"])
							flood_mines(coor)
			else:
				if is_valid_coordinate(coor) and tapped_coordinates.has(coor):
					if number_map.has(coor):
						match number_map[coor]:
							1:
								var neighbor_coor = get_8_neighbors(coor.x, coor.y)
								var _not_in_tapped_coor:Array = neighbor_coor.filter(not_in(tapped_coordinates))
								if  _not_in_tapped_coor.size() > 0 :
									var _flag_coor = _not_in_tapped_coor.filter(are_in(flag_coordinates))
									var _mine_coor = _flag_coor.filter(are_in(toVector2i(mines_coordinate)))
									print(_flag_coor)
									print(_mine_coor)
									if _flag_coor.size() == _mine_coor.size():
										flood_mines(coor)
								

							2:
								print("2")
							3:
								print("3")
							4:
								print("4")
							5:
								print("5")
							6:
								print("6")
							7:
								print("7")
							8:
								print("8")
							_:
								print("blank")

	if Input.is_action_just_pressed("on_right_click") and clickedOnce == true:
		var coor: Vector2i = map.local_to_map(get_local_mouse_position())
		if map.get_cell_atlas_coords(layer_id, coor) != Vector2i(-1, -1):
			if is_valid_coordinate(coor):
				if (
					map.get_cell_atlas_coords(layer_id, coor) == cell_map["default"]
					|| map.get_cell_atlas_coords(layer_id, coor) == cell_map["flag"]
				):
					if flag_coordinates.has(coor) and tapped_coordinates.has(coor):
						tapped_coordinates.remove_at(tapped_coordinates.find(coor))
						flag_coordinates.remove_at(flag_coordinates.find(coor))
						erase_cell(layer_id, coor)
						if mines_coordinate.has(Vector2(coor.x, coor.y)):
							set_cell(layer_id, coor, source_id, cell_map["default"], 1)
						else:
							set_tile_cell(coor, cell_map["default"])
					else:
						erase_cell(layer_id, coor)
						set_tile_cell(coor, cell_map["flag"])
						flag_coordinates.append(coor)
						tapped_coordinates.append(coor)



func not_in(exclude_values):
	return func(element):
		return not element in exclude_values
		
func are_in(exclude_values):
	return func(element):
		return element in exclude_values
		
func toVector2i(old_values:Array[Vector2]) -> Array[Vector2i]:
	var tempArray : Array[Vector2i] = []
	for value in old_values:
		tempArray.append(Vector2i(value))
	return tempArray

func flood_mines(start_coordinate: Vector2i) -> void:
	var stack = [start_coordinate]

	while stack.size() > 0:
		var current_coordinate = stack.pop_back()
		print(is_valid_coordinate(current_coordinate) and not flag_coordinates.has(current_coordinate))
		if is_valid_coordinate(current_coordinate) and not flag_coordinates.has(current_coordinate):
			tapped_coordinates.append(current_coordinate)
			if number_map.has(current_coordinate):
				match number_map[current_coordinate]:
					1:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["1"])
					2:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["2"])
					3:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["3"])
					4:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["4"])
					5:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["5"])
					6:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["6"])
					7:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["7"])
					8:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["8"])
					_:
						erase_cell(layer_id, current_coordinate)
						set_tile_cell(current_coordinate, cell_map["blank"])
			else:
				update_cell(current_coordinate, "blank")

				var neighbors = get_8_neighbors(current_coordinate.x, current_coordinate.y)
				for neighbor in neighbors:
					if is_valid_coordinate(neighbor) and not tapped_coordinates.has(neighbor):
						stack.append(neighbor)


func get_random_coor() -> Vector2:
	if rows % 2 == 0:
		return Vector2(
			randi_range(-rows / floor(2), rows / floor(2) - 1),
			randi_range(-columns / floor(2), columns / floor(2) - 1)
		)
	else:
		return Vector2(
			randi_range(-rows / floor(2), rows / floor(2)),
			randi_range(-columns / floor(2), columns / floor(2))
		)


func is_valid_coordinate(coor: Vector2) -> bool:
	if rows % 2 == 0:
		return (
			coor.x >= -rows / floor(2)
			&& coor.x <= rows / floor(2) - 1
			&& coor.y <= columns / floor(2) - 1
			&& coor.y >= -columns / floor(2)
		)
	else:
		return (
			coor.x >= -rows / floor(2)
			&& coor.x <= rows / floor(2)
			&& coor.y <= columns / floor(2)
			&& coor.y >= -columns / floor(2)
		)


func update_cell(coor: Vector2, cell_type: String) -> void:
	erase_cell(layer_id, coor)
	set_tile_cell(coor, cell_map[cell_type])


func build_map() -> void:
	for i in rows:
		for j in columns:
			var cell_coordinate = Vector2i(int(i - rows / floor(2)), int(j - columns / floor(2)))
			set_tile_cell(cell_coordinate, cell_map["default"])


func set_tile_cell(coor: Vector2, cell_type: Vector2i) -> void:
	set_cell(layer_id, coor, source_id, cell_type)


func place_mines() -> void:
	for i in no_of_mines:
		var random_mine_coordinate = get_random_coor()

		while (
			mines_coordinate.has(random_mine_coordinate)
			|| Vector2(first_click_coordinate) == random_mine_coordinate
		):
			random_mine_coordinate = get_random_coor()
		mines_coordinate.append(random_mine_coordinate)
		_place_map_numbers(random_mine_coordinate)
		erase_cell(layer_id, random_mine_coordinate)
		set_cell(layer_id, random_mine_coordinate, source_id, cell_map["default"], 1)


func _place_map_numbers(i: Vector2) -> void:
	var temp_mine_coordinate: Vector2 = i
	if is_valid_coordinate(temp_mine_coordinate):
		var mine_place_coor = Vector2i(temp_mine_coordinate)
		# mine right side
		if number_map.has(mine_place_coor + Vector2i.RIGHT):
			number_map[mine_place_coor + Vector2i.RIGHT] = (
				number_map[mine_place_coor + Vector2i.RIGHT] + 1
			)

		else:
			number_map[mine_place_coor + Vector2i.RIGHT] = 1

		#mine left side
		if number_map.has(mine_place_coor + Vector2i.LEFT):
			number_map[mine_place_coor + Vector2i.LEFT] = (
				number_map[mine_place_coor + Vector2i.LEFT] + 1
			)

		else:
			number_map[mine_place_coor + Vector2i.LEFT] = 1

		# mine Up side
		if number_map.has(mine_place_coor + Vector2i.UP):
			number_map[mine_place_coor + Vector2i.UP] = (
				number_map[mine_place_coor + Vector2i.UP] + 1
			)

		else:
			number_map[mine_place_coor + Vector2i.UP] = 1

		# mine Down side
		if number_map.has(mine_place_coor + Vector2i.DOWN):
			number_map[mine_place_coor + Vector2i.DOWN] = (
				number_map[mine_place_coor + Vector2i.DOWN] + 1
			)

		else:
			number_map[mine_place_coor + Vector2i.DOWN] = 1

		# mine right up diagonal
		if number_map.has(Vector2i(mine_place_coor.x + 1, mine_place_coor.y - 1)):
			number_map[Vector2i(mine_place_coor.x + 1, mine_place_coor.y - 1)] = (
				number_map[Vector2i(mine_place_coor.x + 1, mine_place_coor.y - 1)] + 1
			)

		else:
			number_map[Vector2i(mine_place_coor.x + 1, mine_place_coor.y - 1)] = 1

		# mine right down diagonal
		if number_map.has(Vector2i(mine_place_coor.x + 1, mine_place_coor.y + 1)):
			number_map[Vector2i(mine_place_coor.x + 1, mine_place_coor.y + 1)] = (
				number_map[Vector2i(mine_place_coor.x + 1, mine_place_coor.y + 1)] + 1
			)

		else:
			number_map[Vector2i(mine_place_coor.x + 1, mine_place_coor.y + 1)] = 1

		# mine left up diagonal
		if number_map.has(Vector2i(mine_place_coor.x - 1, mine_place_coor.y - 1)):
			number_map[Vector2i(mine_place_coor.x - 1, mine_place_coor.y - 1)] = (
				number_map[Vector2i(mine_place_coor.x - 1, mine_place_coor.y - 1)] + 1
			)

		else:
			number_map[Vector2i(mine_place_coor.x - 1, mine_place_coor.y - 1)] = 1

		# mine left down diagonal
		if number_map.has(Vector2i(mine_place_coor.x - 1, mine_place_coor.y + 1)):
			number_map[Vector2i(mine_place_coor.x - 1, mine_place_coor.y + 1)] = (
				number_map[Vector2i(mine_place_coor.x - 1, mine_place_coor.y + 1)] + 1
			)

		else:
			number_map[Vector2i(mine_place_coor.x - 1, mine_place_coor.y + 1)] = 1


func _on_button_pressed():
	_restart()


func get_8_neighbors(x, y):
	var neighbors = [
		Vector2i(x - 1, y),  # Left
		Vector2i(x + 1, y),  # Right
		Vector2i(x, y - 1),  # Up
		Vector2i(x, y + 1),  # Down
		Vector2i(x - 1, y - 1),  # Up-Left
		Vector2i(x - 1, y + 1),  # Down-Left
		Vector2i(x + 1, y - 1),  # Up-Right
		Vector2i(x + 1, y + 1)  # Down-Right
	]
	return neighbors
