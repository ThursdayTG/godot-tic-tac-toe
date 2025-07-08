extends Button




@onready var main: Node = get_node(".")


# restarts the game by resetting `grid_data` and then
# resetting `game_won` and `game_won_by` accordingly
func _on_button_pressed() -> void:
    # resets `grid_data' to reconise all cells as unpopulated
    for x: int in main.grid_data.size():
        for y: int in main.grid_data.size():
            main.grid_data[x][y] = 0

    # redraws all symbols, i.e. removing them (since cells have been depopulated)
    main.f_draw_board()

    # resets win state of the game and sets player turns to starting states
    main.game_won = main.f_win_con()
    main.game_won_by = main.f_determine_winner()
    main.turn_noughts = 1
    main.turn_crosses = 0
    return
