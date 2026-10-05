extends Control

var state_manager: StateManager = StateManager.new()


func _ready() -> void:
  state_manager.generate_state()
  %Grid.populate_grid(state_manager.game_state.grid)
  %Grid.cell_clicked.connect(_on_cell_clicked)

  var player = state_manager.game_state.player
  %HUD.update_health(player.current_health, player.max_health())
  %HUD.update_experience(player.current_experience, player.next_level_experience())
  %HUD.level_up_pressed.connect(_on_level_up_pressed)

  %GuessPopup.guess_selected.connect(_on_guess_selected)


func _on_cell_clicked(location: Vector2i) -> void:
  var events = state_manager.handle_cell_click(location)
  _handle_events(events)


func _on_guess_selected(location: Vector2i, value: CellData.GuessValue) -> void:
  var events = state_manager.handle_guess(location, value)
  _handle_events(events)


func _on_level_up_pressed() -> void:
  state_manager.game_state.player.level_up()
  %HUD.update_health(state_manager.game_state.player.current_health, state_manager.game_state.player.max_health())
  %HUD.update_experience(state_manager.game_state.player.current_experience, state_manager.game_state.player.next_level_experience())


func _handle_events(events: Array[StateEvent]) -> void:
  for event in events:
    if event is StateEvent.CellUpdatedEvent:
      %Grid.update_cell(
        event.location,
        state_manager.game_state.grid.get_cell(event.location),
        state_manager.game_state.grid
      )
    elif event is StateEvent.HealthUpdatedEvent:
      %HUD.update_health(state_manager.game_state.player.current_health, state_manager.game_state.player.max_health())
    elif event is StateEvent.ExperienceUpdatedEvent:
      %HUD.update_experience(state_manager.game_state.player.current_experience, state_manager.game_state.player.next_level_experience())
    elif event is StateEvent.GameLostEvent:
      %Grid.show_loss(state_manager.game_state.grid, state_manager.game_state.status.killed_by)
      %HUD.show_loss(state_manager.game_state.grid, state_manager.game_state.status.killed_by)
    elif event is StateEvent.GameWonEvent:
      %Grid.disable_grid()
      %HUD.show_win()
      if state_manager.game_state.status.win_type == GameState.WinTypeEnum.CLEAR:
        %WinScreenClear.visible = true
      else:
        %WinScreen.visible = true
