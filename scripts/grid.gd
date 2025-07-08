extends Node2D




@onready var main: Node = get_node("..")


# contains references to instantiated nodes of noughts and crosses
# used to delete these nodes in order to empty the board
var grid_data_node_references: Dictionary[Vector2i, Node2D] = {
}
"""
btw, can somebody ELI5 how tf typed keys work? that shit is SUPER cool, and I do understand how to use them,
but I don't understand how it works on a more technical level
"""


# draws symbols on the playing field
func f_draw_board() -> void:
    const CELL_CENTRE: float = float(Main.CELL_LENGTH) / 2.0
    var draw_coordinates_x: float = 0.0
    var draw_coordinates_y: float = 0.0

    for x: int in main.GRID_LENGTH:
        for y: int in main.GRID_LENGTH:
            # draw_coordinates_ vars are inverted for readability,
            # see comment in `func _input`
            draw_coordinates_x = main.valid_coordinates_x[y * 2] + CELL_CENTRE
            draw_coordinates_y = main.valid_coordinates_y[x * 2] + CELL_CENTRE
            var symbol: Node2D

            # if internal game state recognises cell as unpopulated...
            if (main.grid_data[x][y] == 0):
                if (grid_data_node_references.has(Vector2i(x, y))):
                    # visually empties cell if it has been depopulated (e.g. on game reset)
                    grid_data_node_references[Vector2i(x, y)].queue_free()
                    grid_data_node_references.erase(Vector2i(x, y))
                continue
            # else if cell is cell is populated in internal game state but not presented visually...
            elif (!grid_data_node_references.has(Vector2i(x, y))):
                if (main.grid_data[x][y] == 1):
                    # if cell is populated by player 1, instantiate a nought
                    symbol = main.nought_scene.instantiate()
                elif (main.grid_data[x][y] == 2):
                    # if cell is populated by player 2, instantiate a cross
                    symbol = main.cross_scene.instantiate()
                elif (main.grid_data[x][y] != 0):
                    # if cell errored out, instantiate a questionmark
                    symbol = main.questionmark_scene.instantiate()

                # set symbol position, store reference of symbol in dictionary
                add_child(symbol)
                grid_data_node_references[Vector2i(x, y)] = symbol
                symbol.global_position = Vector2(draw_coordinates_x, draw_coordinates_y)
    return
