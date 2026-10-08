class_name StateManager
extends RefCounted

var game_state: GameState


func generate_state():
  var rng := RandomNumberGenerator.new()
  game_state = GameState.new(_generate_cells(rng), rng.seed)
  return game_state


func _generate_cells(_rng: RandomNumberGenerator) -> Array[CellData]:
  # TODO dynamically generate grid
  return TestGrid.get_test_grid()


func handle_cell_click(location: Vector2i) -> Array[StateEvent]:
  var cell = game_state.grid.get_cell(location)
  match cell.state:
    CellData.CellState.HIDDEN:
      if cell is CellData.MonsterMimic or cell is CellData.Chest:
        cell.state = CellData.CellState.REVEALED
        return [StateEvent.CellUpdatedEvent.new(location)]
      return _kill_cell(cell)
    CellData.CellState.REVEALED:
      return _kill_cell(cell)
    CellData.CellState.DEAD:
      var reward = cell.rewards.pop_front()
      if not reward:
        return []
      var events = _apply_reward(reward, location)
      events.append(StateEvent.CellUpdatedEvent.new(location))
      return events
    _:
      print("state_manager_error: unexpected cell state: ", cell.state, cell.location)
  return []


func _calculate_win_type() -> GameState.WinTypeEnum:
  for cell in game_state.grid.cells:
    if cell.state != CellData.CellState.DEAD and cell.health > 0:
      return GameState.WinTypeEnum.NORMAL
  return GameState.WinTypeEnum.CLEAR


func _reveal_cell(cell: CellData) -> void:
  if cell.health > 0:
    cell.state = CellData.CellState.REVEALED
  elif cell is CellData.Chest or cell is CellData.DragonEgg:
    cell.state = CellData.CellState.REVEALED
  else:
    # Consider: make one emty cell reveal (fairy)
    _kill_cell(cell)


func _update_grid_on_loss() -> void:
  for cell in game_state.grid.cells:
    if cell.state == CellData.CellState.HIDDEN:
      _reveal_cell(cell)


func _apply_scry(cells: Array[CellData]) -> Array[StateEvent]:
  var events: Array[StateEvent] = []
  for cell_data in cells:
    if cell_data.state == CellData.CellState.HIDDEN:
      _reveal_cell(cell_data)
      events.append(StateEvent.CellUpdatedEvent.new(cell_data.location))
  return events


func _apply_reward(reward: CellData.Reward, location: Vector2i) -> Array[StateEvent]:
  if reward.type == CellData.Reward.Type.WIN:
    game_state.status.result = GameState.GameStatusEnum.WIN
    game_state.status.win_type = _calculate_win_type()
    return [StateEvent.GameWonEvent.new()]

  if reward.type == CellData.Reward.Type.EXPERIENCE:
    game_state.player.current_experience += reward.experience
    return [StateEvent.ExperienceUpdatedEvent.new()]

  if reward.type == CellData.Reward.Type.SCROLL:
    # TODO: add a bunch of animation events
    match reward.scroll:
      CellData.Reward.ScrollType.HEALING:
        game_state.player.current_health = game_state.player.max_health()
        return [StateEvent.HealthUpdatedEvent.new()]
      CellData.Reward.ScrollType.SCRYING:
        var center = game_state.grid.cells.pick_random().location
        var cells_to_scry = game_state.grid.get_immediate_neighbors(center)
        cells_to_scry.append(game_state.grid.get_cell(center))
        return _apply_scry(cells_to_scry)
      CellData.Reward.ScrollType.SCRYING_INITIAL:
        var cells_to_scry = game_state.grid.get_diamond_neighbors(location)
        return _apply_scry(cells_to_scry)
      CellData.Reward.ScrollType.MINES:
        var mines = game_state.grid.cells.filter(func(c: CellData): return c is CellData.MonsterMine)
        var events: Array[StateEvent] = []
        for mine in mines:
          mine.health = 0
          if mine.state == CellData.CellState.REVEALED:
            mine.state = CellData.CellState.DEAD
            events.append(StateEvent.CellUpdatedEvent.new(mine.location))
          for neighbor in game_state.grid.get_immediate_neighbors(mine.location):
            events.append(StateEvent.CellUpdatedEvent.new(neighbor.location))
        return events
      CellData.Reward.ScrollType.RATS:
        var rats = game_state.grid.cells.filter(func(c: CellData): return c is CellData.MonsterRat)
        var events: Array[StateEvent] = []
        for rat in rats:
          if rat.state == CellData.CellState.HIDDEN:
            rat.state = CellData.CellState.REVEALED
            events.append(StateEvent.CellUpdatedEvent.new(rat.location))
        return events
      CellData.Reward.ScrollType.SLIMES:
        var slimes = game_state.grid.cells.filter(func(c: CellData): return c is CellData.MonsterSlime or c is CellData.MonsterPurpleSlime)
        var events: Array[StateEvent] = []
        for slime in slimes:
          if slime.state == CellData.CellState.HIDDEN:
            slime.state = CellData.CellState.REVEALED
            events.append(StateEvent.CellUpdatedEvent.new(slime.location))
        return events
      _:
        print("state_manager_error: unexpected scroll type: ", reward.scroll)
        return []

  print("state_manager_error: unexpected reward type: ", reward.type)
  return []


func _kill_cell(cell: CellData) -> Array[StateEvent]:
  var events: Array[StateEvent] = []

  if cell is CellData.Wall:
    if cell.state == CellData.CellState.HIDDEN:
      cell.state = CellData.CellState.REVEALED
      return [StateEvent.CellUpdatedEvent.new(cell.location)]
    if game_state.player.current_health == 0:
      return []
    game_state.player.current_health -= 1
    cell.health -= 1
    if cell.health == 0:
      cell.state = CellData.CellState.DEAD
    else:
      cell.state = CellData.CellState.REVEALED
    return [
      StateEvent.CellUpdatedEvent.new(cell.location),
      StateEvent.HealthUpdatedEvent.new()
    ]

  if cell.health > 0:
    if cell.health > game_state.player.current_health:
      game_state.player.current_health = 0
      game_state.status.result = GameState.GameStatusEnum.LOSE
      game_state.status.killed_by = cell.location
      _update_grid_on_loss()
      return [StateEvent.GameLostEvent.new()]
    game_state.player.current_health -= cell.health
    events.append(StateEvent.HealthUpdatedEvent.new())

  cell.state = CellData.CellState.DEAD
  events.append(StateEvent.CellUpdatedEvent.new(cell.location))

  if cell is CellData.EmptyCell:
    game_state.grid.empty_count -= 1
    if game_state.grid.empty_count == 0:
      cell.rewards.append(CellData.Reward.new(CellData.Reward.Type.EXPERIENCE, 9, CellData.Reward.ScrollType.NONE))
    return events

  if cell is CellData.MonsterGazer:
    for neighbor in game_state.grid.get_diamond_neighbors(cell.location):
      events.append(StateEvent.CellUpdatedEvent.new(neighbor.location))
  if cell is CellData.MonsterRatKing:
    var rats = game_state.grid.cells.filter(func(c: CellData): return c is CellData.MonsterRat)
    for rat in rats:
      events.append(StateEvent.CellUpdatedEvent.new(rat.location))
  if cell is CellData.Chest:
    events.append(StateEvent.CellUpdatedEvent.new(cell.minotaur_location))
  if cell is CellData.MonsterLover:
    events.append(StateEvent.CellUpdatedEvent.new(cell.lover_location))
  
  for neighbor in game_state.grid.get_immediate_neighbors(cell.location):
      events.append(StateEvent.CellUpdatedEvent.new(neighbor.location))
  
  return events


func handle_guess(location: Vector2i, value: CellData.GuessValue) -> Array[StateEvent]:
  var cell = game_state.grid.get_cell(location)
  if cell.state != CellData.CellState.HIDDEN:
    return []
  cell.guess_value = value
  return [StateEvent.CellUpdatedEvent.new(location)]
