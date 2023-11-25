extends TileMap

@export var rows: int = 8
@export var columns: int = 8
@export var no_of_mines: int = 10
@onready var map: TileMap = %Map

const layer_id: int = 0
const source_id: int = 0

var gameOver: bool = false

var mines_coordinate: Array[Vector2]
var flag_coordinates: Array[Vector2i]

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
	mines_coordinate.clear()
	flag_coordinates.clear()
	scale = Vector2(2.5, 2.5)
	build_map()
	place_mines()
	print(mines_coordinate)


func _process(_delta):
	on_mouse_click()


func on_game_over(isGameOver: bool):
	gameOver = isGameOver


func on_mouse_click() -> void:
	if gameOver == true:
		return
	if Input.is_action_just_pressed("on_tap"):
		var coor: Vector2i = map.local_to_map(get_local_mouse_position())
		# //Checking if the mouse clicked outside the map or not
		if map.get_cell_atlas_coords(layer_id, coor) != Vector2i(-1, -1):
			if (coor.x >= -4 || coor.x <= 3) && (coor.y <= 3 || coor.y <= -4):
				if get_cell_tile_data(layer_id, coor).get_custom_data("has_mine") == true:
					erase_cell(layer_id, coor)
					set_tile_cell(coor, cell_map["mine"])
					on_game_over(true)
	if Input.is_action_just_pressed("on_right_click"):
		var coor: Vector2i = map.local_to_map(get_local_mouse_position())
		if map.get_cell_atlas_coords(layer_id, coor) != Vector2i(-1, -1):
			if (coor.x >= -4 || coor.x <= 3) && (coor.y <= 3 || coor.y <= -4):
				if (
					map.get_cell_atlas_coords(layer_id, coor) == cell_map["default"]
					|| map.get_cell_atlas_coords(layer_id, coor) == cell_map["flag"]
				):
					if flag_coordinates.has(coor):
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


func build_map() -> void:
	for i in rows:
		for j in columns:
			var cell_coordinate = Vector2i(int(i - rows / floor(2)), int(j - columns / floor(2)))
			set_tile_cell(cell_coordinate, cell_map["default"])


func set_tile_cell(coor: Vector2, cell_type: Vector2i) -> void:
	set_cell(layer_id, coor, source_id, cell_type)


func place_mines() -> void:
	for i in no_of_mines:
		var random_mine_coordinate = Vector2(
			randi_range(-rows / 2, rows / 2 - 1), randi_range(-columns / 2, columns / 2 - 1)
		)

		while mines_coordinate.has(random_mine_coordinate):
			random_mine_coordinate = Vector2(
				randi_range(-rows / 2, rows / 2 - 1), randi_range(-columns / 2, columns / 2 - 1)
			)
		mines_coordinate.append(random_mine_coordinate)
		erase_cell(layer_id, random_mine_coordinate)
		set_cell(layer_id, random_mine_coordinate, source_id, cell_map["default"], 1)


func _on_button_pressed():
	_restart()
