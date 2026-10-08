extends Control

var state_manager: StateManager = StateManager.new()


func _ready() -> void:
  %Grid.cell_clicked.connect(_on_cell_clicked)
  %HUD.level_up_pressed.connect(_on_level_up_pressed)
  %HUD.restart_pressed.connect(_restart_game)
  %GuessPopup.guess_selected.connect(_on_guess_selected)
  _start_game()


func _on_cell_clicked(location: Vector2i) -> void:
  var events = state_manager.handle_cell_click(location)
  _handle_events(events)


func _on_guess_selected(location: Vector2i, value: CellData.GuessValue) -> void:
  var events = state_manager.handle_guess(location, value)
  _handle_events(events)


func _on_level_up_pressed() -> void:
  if state_manager.game_state.player.current_experience >= state_manager.game_state.player.next_level_experience():
    state_manager.game_state.player.level_up()
    %HUD.update_health(state_manager.game_state.player.current_health, state_manager.game_state.player.max_health())
    %HUD.update_experience(state_manager.game_state.player.current_experience, state_manager.game_state.player.next_level_experience())
    _update_hero_state()


func _restart_game() -> void:
  %WinScreenClear.visible = false
  %WinScreen.visible = false
  %Grid.clear_grid()
  %HUD.reset()
  _start_game()


func _start_game() -> void:
  state_manager.generate_state()
  %Grid.populate_grid(state_manager.game_state.grid)
  var player = state_manager.game_state.player
  %HUD.update_health(player.current_health, player.max_health())
  %HUD.update_experience(player.current_experience, player.next_level_experience())
  _update_hero_state()


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
      _update_hero_state()
    elif event is StateEvent.ExperienceUpdatedEvent:
      %HUD.update_experience(state_manager.game_state.player.current_experience, state_manager.game_state.player.next_level_experience())
      _update_hero_state()
    elif event is StateEvent.GameLostEvent:
      %Grid.show_loss(state_manager.game_state.grid, state_manager.game_state.status.killed_by)
      %HUD.show_loss(state_manager.game_state.grid, state_manager.game_state.status.killed_by)
      _update_hero_state()
    elif event is StateEvent.GameWonEvent:
      %Grid.disable_grid()
      %HUD.show_win()
      if state_manager.game_state.status.win_type == GameState.WinTypeEnum.CLEAR:
        %WinScreenClear.visible = true
      else:
        %WinScreen.visible = true
      _update_hero_state()

func _update_hero_state() -> void:
  if state_manager.game_state.status.result == GameState.GameStatusEnum.WIN:
    %HUD.update_hero_state(HUD.HERO_STATE.VICTORY)
  elif state_manager.game_state.status.result == GameState.GameStatusEnum.LOSE:
    %HUD.update_hero_state(HUD.HERO_STATE.DEAD)
  else:
    if state_manager.game_state.player.current_experience >= state_manager.game_state.player.next_level_experience():
      %HUD.update_hero_state(HUD.HERO_STATE.LEVEL_UP)
    elif state_manager.game_state.player.current_health == 0:
      %HUD.update_hero_state(HUD.HERO_STATE.INJURED)
    else:
      %HUD.update_hero_state(HUD.HERO_STATE.NORMAL)
