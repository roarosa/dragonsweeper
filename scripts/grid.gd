class_name Grid
extends GridContainer

const CELL_SCENE := preload("res://cell.tscn")

@onready var popup_node: GuessPopup = %GuessPopup

var grid_disabled = false
signal cell_clicked(location: Vector2i)

func _ready() -> void:
  clear_grid()


func clear_grid() -> void:
  for child in get_children():
    remove_child(child)
    child.queue_free()


func populate_grid(grid: GameState.GridState) -> void:
  for i in grid.cells.size():
    var cell_data = grid.cells[i]
    var cell_node: Cell = CELL_SCENE.instantiate()
    cell_node.clicked.connect(cell_clicked.emit.bind(grid.convert_index_to_location(i)))
    cell_node.right_clicked.connect(_on_cell_right_clicked.bind(grid.convert_index_to_location(i), cell_node))
    add_child(cell_node)
    _set_cell_data(cell_node, cell_data, grid)


func update_cell(location: Vector2i, cell_data: CellData, grid: GameState.GridState) -> void:
  var cell_node = get_child(grid.convert_location_to_index(location))
  _set_cell_data(cell_node, cell_data, grid)


func disable_grid() -> void:
  for cell_node in get_children():
    cell_node.cell_disabled = true


func show_loss(grid: GameState.GridState, killed_by: Vector2i) -> void:
  var killed_by_i = grid.convert_location_to_index(killed_by)
  for i in get_child_count():
    var cell_node: Control = get_child(i)
    var cell_data = grid.cells[i]
    if cell_data.state == CellData.CellState.HIDDEN or cell_data.state == CellData.CellState.REVEALED:
      if cell_data is CellData.MonsterMimic:
        cell_node.set_mode_revealed(Cell.MonsterView.MIMIC_REVEALED, cell_data.health, i != killed_by_i)
      elif cell_data is CellData.Wall or cell_data is CellData.Chest:
        cell_node.set_mode_revealed_icon_only(_get_monster_view(cell_data, grid), i != killed_by_i)
      else:
        cell_node.set_mode_revealed(_get_monster_view(cell_data, grid), cell_data.health, i != killed_by_i)
    elif cell_data.state == CellData.CellState.DEAD:
      if cell_data.rewards.size() > 0:
        var reward = cell_data.rewards[0]
        if reward.type == CellData.Reward.Type.EXPERIENCE:
          cell_node.set_mode_reward_experience(_get_monster_view(cell_data, grid), reward.experience, true)
        elif reward.type == CellData.Reward.Type.SCROLL:
          cell_node.set_mode_reward_scroll(reward.scroll, true)
        elif reward.type == CellData.Reward.Type.WIN:
          cell_node.set_mode_reward_crown(true)
      elif cell_data.is_gazer_hidden(grid):
        cell_node.set_mode_gazer_hidden()
      else:
        cell_node.set_mode_empty(cell_data.get_surrounding_value(grid))
    else:
      print("cell_data_error: unexpected cell state: ", cell_data.state)
    cell_node.cell_disabled = true


func _get_monster_view(cell_data: CellData, grid: GameState.GridState) -> Cell.MonsterView:
  if cell_data is CellData.MonsterRat:
    var direction = cell_data.get_direction(grid)
    match direction:
      CellData.MonsterRat.Direction.UP:
        return Cell.MonsterView.RAT_UP
      CellData.MonsterRat.Direction.LEFT:
        return Cell.MonsterView.RAT_LEFT
      CellData.MonsterRat.Direction.RIGHT:
        return Cell.MonsterView.RAT_RIGHT
      _:
        print("monster_view_error: unexpected direction for rat: ", direction)
        return Cell.MonsterView.RAT_UP
  if cell_data is CellData.MonsterBat:
    return Cell.MonsterView.BAT
  if cell_data is CellData.MonsterSkeleton:
    return Cell.MonsterView.SKELETON
  if cell_data is CellData.MonsterGargoyle:
    match cell_data.direction:
      CellData.MonsterGargoyle.Direction.UP:
        return Cell.MonsterView.GARGOYLE_UP
      CellData.MonsterGargoyle.Direction.LEFT:
        return Cell.MonsterView.GARGOYLE_LEFT
      CellData.MonsterGargoyle.Direction.RIGHT:
        return Cell.MonsterView.GARGOYLE_RIGHT
      CellData.MonsterGargoyle.Direction.DOWN:
        return Cell.MonsterView.GARGOYLE_DOWN
      _:
        print("monster_view_error: unexpected direction for gargoyle: ", cell_data.direction)
        return Cell.MonsterView.GARGOYLE_DOWN
  if cell_data is CellData.MonsterSlime:
    return Cell.MonsterView.SLIME
  if cell_data is CellData.MonsterMinotaur:
    var chest_opened = cell_data.is_chest_opened(grid)
    var chest_direction = cell_data.get_chest_direction()
    match chest_direction:
      CellData.MonsterMinotaur.Direction.LEFT:
        return Cell.MonsterView.MINOTAUR_LEFT_OPEN if chest_opened else Cell.MonsterView.MINOTAUR_RIGHT
      CellData.MonsterMinotaur.Direction.RIGHT:
        return Cell.MonsterView.MINOTAUR_RIGHT_OPEN if chest_opened else Cell.MonsterView.MINOTAUR_LEFT
      _:
        print("monster_view_error: unexpected direction for minotaur: ", chest_direction)
        return Cell.MonsterView.MINOTAUR_LEFT
  if cell_data is CellData.MonsterGuardian:
    return Cell.MonsterView.GUARDIAN
  if cell_data is CellData.MonsterPurpleSlime:
    return Cell.MonsterView.PURPLE_SLIME
  if cell_data is CellData.MonsterLover:
    var broken = cell_data.is_lover_killed(grid)
    var direction = cell_data.get_direction()
    match direction:
      CellData.MonsterLover.Direction.LEFT:
        return Cell.MonsterView.LOVER_LEFT_BROKEN if broken else Cell.MonsterView.LOVER_LEFT
      CellData.MonsterLover.Direction.RIGHT:
        return Cell.MonsterView.LOVER_RIGHT_BROKEN if broken else Cell.MonsterView.LOVER_RIGHT
      _:
        print("monster_view_error: unexpected direction for lover: ", direction)
        return Cell.MonsterView.LOVER_LEFT
  if cell_data is CellData.MonsterEngineer:
    return Cell.MonsterView.ENGINEER
  if cell_data is CellData.MonsterRatKing:
    return Cell.MonsterView.RAT_KING
  if cell_data is CellData.MonsterGazer:
    return Cell.MonsterView.GAZER
  if cell_data is CellData.MonsterSlimeWitch:
    return Cell.MonsterView.SLIME_WITCH
  if cell_data is CellData.MonsterMimic:
    return Cell.MonsterView.MIMIC
  if cell_data is CellData.MonsterMine:
    return Cell.MonsterView.MINE
  if cell_data is CellData.Chest:
    return Cell.MonsterView.CHEST
  if cell_data is CellData.MonsterDragon:
    return Cell.MonsterView.DRAGON
  if cell_data is CellData.DragonEgg:
    return Cell.MonsterView.DRAGON_EGG
  if cell_data is CellData.EmptyCell:
    return Cell.MonsterView.FAIRY
  if cell_data is CellData.Wall:
    match cell_data.health:
      0:
        return Cell.MonsterView.WALL_0
      1:
        return Cell.MonsterView.WALL_1
      2:
        return Cell.MonsterView.WALL_2
      3:
        return Cell.MonsterView.WALL_3
      _:
        print("monster_view_error: unexpected health for wall: ", cell_data.health)
        return Cell.MonsterView.WALL_3
  print("monster_view_error: unexpected cell type encountered at location ", cell_data.location)
  return Cell.MonsterView.FALLBACK

func _set_cell_data(cell_node: Cell, cell_data: CellData, grid: GameState.GridState) -> void:
  match cell_data.state:
    CellData.CellState.HIDDEN:
      if cell_data.guess_value == CellData.GuessValue.NONE:
        cell_node.set_mode_hidden()
      else:
        cell_node.set_mode_guess(cell_data.guess_value)
    CellData.CellState.REVEALED:
      if cell_data is CellData.Wall or cell_data is CellData.Chest or cell_data is CellData.MonsterMimic:
        cell_node.set_mode_revealed_icon_only(_get_monster_view(cell_data, grid))
      else:
        cell_node.set_mode_revealed(_get_monster_view(cell_data, grid), cell_data.health)
    CellData.CellState.DEAD:
      if cell_data.rewards.size() > 0:
        var reward = cell_data.rewards[0]
        if reward.type == CellData.Reward.Type.EXPERIENCE:
          cell_node.set_mode_reward_experience(_get_monster_view(cell_data, grid), reward.experience)
        elif reward.type == CellData.Reward.Type.SCROLL:
          cell_node.set_mode_reward_scroll(reward.scroll)
        elif reward.type == CellData.Reward.Type.WIN:
          cell_node.set_mode_reward_crown()
      elif cell_data.is_gazer_hidden(grid):
        cell_node.set_mode_gazer_hidden()
      else:
        cell_node.set_mode_empty(cell_data.get_surrounding_value(grid))
    _:
      print("cell_data_error: unexpected cell state: ", cell_data.state)


func _on_cell_right_clicked(location: Vector2i, cell_node: Cell) -> void:
  popup_node.cell_location = location
  var popup_size = popup_node.get_contents_minimum_size()
  var popup_position = cell_node.global_position + Vector2(cell_node.size.x, cell_node.size.y / 2 - popup_size.y / 2)
  popup_node.popup(Rect2i(popup_position, popup_size))
