class_name Main extends Node


@export var nought_scene: PackedScene
@export var cross_scene: PackedScene
@export var questionmark_scene: PackedScene


@onready var grid: Node = get_node("grid_3x3")


const BORDER_WIDTH:  int = 14     # length of border between cells in pixels
const CELL_LENGTH:   int = 286    # length of each side of a singular cell in pixels
const GRID_LENGTH:   int = 3      # length of grid in number of cells
const GRID_MARGIN_X: int = 517    # horizontal space between start of first column and screen border in pixels
const GRID_MARGIN_Y: int = 97     # vertical   space between start of first row    and screen border in pixels




# arrays that contain start and end coordinates for each column/row
# serves to calculate coordinates for cells within the grid
var valid_coordinates_x: PackedInt32Array = f_coordinates_setter(GRID_MARGIN_X)
var valid_coordinates_y: PackedInt32Array = f_coordinates_setter(GRID_MARGIN_Y)

func f_coordinates_setter(grid_margin: int) -> PackedInt32Array:
    var temp_array: PackedInt32Array = []

    temp_array.push_back(grid_margin)                                         # start coordinate of first cell
    temp_array.push_back(temp_array[temp_array.size() - 1] + CELL_LENGTH)     # end coordinate of first cell
    temp_array.push_back(temp_array[temp_array.size() - 1] + BORDER_WIDTH)    # start coordinate of second cell
    temp_array.push_back(temp_array[temp_array.size() - 1] + CELL_LENGTH)     # end coordinate of second cell
    temp_array.push_back(temp_array[temp_array.size() - 1] + BORDER_WIDTH)    # start coordinate of third cell
    temp_array.push_back(temp_array[temp_array.size() - 1] + CELL_LENGTH)     # end coordinate of third cell

    return temp_array



# used to determine which cell is being clicked in and has to be modified
var grid_pos_x: int = 0
var grid_pos_y: int = 0

# used to keep track of game state
var grid_data: Array[PackedInt32Array] = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
]


# converts mouse input coordinates (float) into grid coordinates (int) to
# calculate which cell is being clicked on (if any)
func f_input_to_grid_coordinates(coordinates_valid: PackedInt32Array, coordinates_input: float) -> int:
    var array_index: int = 0

    # if input coordinates are beyond the lowest or highest coordinates of the playable grid,
    # returns -1 to indicate an error
    if (coordinates_input < coordinates_valid[0]
    ||  coordinates_input > coordinates_valid[GRID_LENGTH * 2 - 1]):
        return -1

    for iterator: int in range(0, GRID_LENGTH, 1):
        array_index = iterator * 2

        # if input is within valid coordinates,
        # return iterator (== coordinate for `grid_data`)
        if (coordinates_input >= coordinates_valid[array_index]
        &&  coordinates_input <= coordinates_valid[array_index + 1]):
            return iterator
        else:
            continue

    # if input are within the grid but not within a cell, i.e. on a border between cells,
    # returns -1 to indicate an error
    return -1


# registers and processes left mouse button inputs
func _input(event: InputEvent) -> void:
    # exits function if registered input is not a mouse button input
    if (!is_instance_of(event, InputEventMouseButton)):
        return

    var mouse: InputEventMouseButton = event
    if (mouse.pressed && mouse.button_index == MOUSE_BUTTON_LEFT):
        # for purposes of the game logic, the x and y axes are inverted
        # compared to the x and y axes as perceived by the player.
        # I do not understand why that is, but I know that inverting them here
        # makes it easier for me to read and write the code.
        grid_pos_x = f_input_to_grid_coordinates(valid_coordinates_y, mouse.global_position.y)
        grid_pos_y = f_input_to_grid_coordinates(valid_coordinates_x, mouse.global_position.x)

        # if input is within a valid cell and
        # game has not already been won by a player,
        # update internal game state and update visual presentation of the board
        if (grid_pos_x != -1 && grid_pos_y != -1 && game_won == 0):
            # if cell has not been played before, play clicked
            if (grid_data[grid_pos_x][grid_pos_y] == 0):
                grid_data[grid_pos_x][grid_pos_y] = f_turn_process()
                grid.f_draw_board()

                # calls `f_win_con()` to update `game_won` variable if
                # win condition has been met by any player
                game_won = f_win_con()

    return



# variables used to determine which player is currently playing
var turn_noughts: int = 1
var turn_crosses: int = 0

func f_turn_process() -> int:
    # return 0 would indicate no change in playstate, as `grid_data` is initialised with all values at 0
    # return 1 will indicate that a cell has been played by noughts
    # return 2 will indicate that a cell has been played by crosses
    # return -1 should never occur, indicating an error

    if   (turn_noughts == 1 && turn_crosses == 0):
        turn_noughts = 0
        turn_crosses = 1
        return 1
    elif (turn_noughts == 0 && turn_crosses == 1):
        turn_noughts = 1
        turn_crosses = 0
        return 2
    else:
        print(
            "Function `f_turn_process` ran into an error."
            + "It could not be determined which player's turn it is."
            + "Inspect `grid_data`, `turn_noughts`, and `turn_crosses`." + "\n"
            + "\n"
            + "grid_data: " + str(grid_data) + "\n"
            + "turn_noughts: " + str(turn_noughts) + "\n"
            + "turn_crosses: " + str(turn_crosses)
        )
        return -1




# checks whether the game has been won by any player.
# `grid_data[x][y] != 0` evaluation ensures that the game is not
# considered won by an empty field.
var game_won: int = f_win_con()
func f_win_con() -> int:
    for i: int in range(0, GRID_LENGTH, 1):
        # checks if 3 cells match straight from left to right (iterates through all rows)
        if (grid_data[i][0] != 0
        &&  grid_data[i][0] == grid_data[i][1]
        &&  grid_data[i][1] == grid_data[i][2]):
            return 1
        # checks if 3 cells match straight from top to bottom (iterates through all columns)
        if (grid_data[0][i] != 0
        &&  grid_data[0][i] == grid_data[1][i]
        &&  grid_data[1][i] == grid_data[2][i]):
            return 1

    # checks if 3 cells match from top left to bottom right
    if (grid_data[0][0] != 0
    &&  grid_data[0][0] == grid_data[1][1]
    &&  grid_data[1][1] == grid_data[2][2]):
        return 1
    # checks if 3 cells match from top right to bottom left
    if (grid_data[2][0] != 0
    &&  grid_data[2][0] == grid_data[1][1]
    &&  grid_data[1][1] == grid_data[0][2]):
        return 1

    # if all evaluations returned false, the game continues
    return 0


# determines which player has played the winning move
var game_won_by: String = "none"
func f_determine_winner() -> String:
    if (f_win_con() == 1):
        if (f_turn_process() == 1):
            return "noughts"
        elif (f_turn_process() == 2):
            return "crosses"
        else:
            return "error"
    else:
        return "none"




# function to collect and output data for debugging purposes
func f_debug_data_collector() -> void:
    print("### constants" + "\n"
        + "const BORDER_WIDTH:  " + type_string(typeof(BORDER_WIDTH))  + " = " + str(BORDER_WIDTH)  + "\n"
        + "const CELL_LENGTH:   " + type_string(typeof(CELL_LENGTH))   + " = " + str(CELL_LENGTH)   + "\n"
        + "const GRID_LENGTH:   " + type_string(typeof(GRID_LENGTH))   + " = " + str(GRID_LENGTH)   + "\n"
        + "const GRID_MARGIN_X: " + type_string(typeof(GRID_MARGIN_X)) + " = " + str(GRID_MARGIN_X) + "\n"
        + "const GRID_MARGIN_Y: " + type_string(typeof(GRID_MARGIN_Y)) + " = " + str(GRID_MARGIN_Y) + "\n"
        + "\n"
        + "### global vars" + "\n"
        + "var valid_coordinates_x: " + type_string(typeof(valid_coordinates_x)) + " = " + str(valid_coordinates_x) + "\n"
        + "var valid_coordinates_y: " + type_string(typeof(valid_coordinates_y)) + " = " + str(valid_coordinates_y) + "\n"
        + "var grid_pos_x: " + type_string(typeof(grid_pos_x)) + " = " + str(grid_pos_x) + "\n"
        + "var grid_pos_y: " + type_string(typeof(grid_pos_y)) + " = " + str(grid_pos_y) + "\n"
        + "var turn_noughts: " + type_string(typeof(turn_noughts)) + " = " + str(turn_noughts) + "\n"
        + "var turn_crosses: " + type_string(typeof(turn_crosses)) + " = " + str(turn_crosses) + "\n"
        + "\n"
        + "### internal state of the game" + "\n"
        + "var grid_data: " + type_string(typeof(grid_data)) + " = " + str(grid_data) + "\n"
        + "var game_won: "        + type_string(typeof(game_won)) + " = " + str(game_won) + "\n"
        + "cells (unpopulated): " + str(f_count_cells(0)) + "\n"
        + "cells (noughts):     " + str(f_count_cells(1)) + "\n"
        + "cells (crosses):     " + str(f_count_cells(2)) + "\n"
        + "cells (errors):      " + str(f_count_cells(-1)) + "\n"
    )
    return


func f_count_cells(comparable: int) -> int:
    # cells containing 0 should be unpopulated cells
    # cells containing 1 should be populated with a nought
    # cells containing 2 should be populated with a cross
    # cells containing any other value are unintentional and considered errors
    var valids: PackedInt32Array = [0, 1, 2]

    var count: int = 0
    for x: int in GRID_LENGTH:
        for y: int in GRID_LENGTH:
            if (grid_data[x][y] == valids[comparable]
            || (valids.find(grid_data[x][y]) == -1 && valids.find(comparable) == -1)):
                count += 1

    return count
