class_name GameState
extends RefCounted

enum GameStatusEnum {
  NONE,
  WIN,
  LOSE,
}

enum WinTypeEnum {
  NONE,
  NORMAL,
  CLEAR,
}

class GameStatus:
  var result: GameStatusEnum
  var win_type: WinTypeEnum
  var killed_by: Vector2i

  func _init() -> void:
    result = GameStatusEnum.NONE
    win_type = WinTypeEnum.NONE
    killed_by = Vector2i.ZERO


class GridState:
  var cells: Array[CellData]
  var empty_count: int
  var seed_v: int

  func _init(p_cells: Array[CellData], p_seed_v: int) -> void:
    cells = p_cells
    seed_v = p_seed_v
    empty_count = 0
    for cell in p_cells:
      if cell is CellData.EmptyCell:
        empty_count += 1
  
  func convert_index_to_location(cell_index: int) -> Vector2i:
    return Vector2i(cell_index / 13, cell_index % 13)

  func convert_location_to_index(location: Vector2i) -> int:
    return location.x * 13 + location.y

  func get_cell(location: Vector2i) -> CellData:
    return cells[convert_location_to_index(location)]

  func get_immediate_neighbors(location: Vector2i) -> Array[CellData]:
    var surrounding_cells: Array[CellData] = []
    for i in range(-1, 2):
      for j in range(-1, 2):
        if i == 0 and j == 0:
          continue
        var possible_neighbor_loc = location + Vector2i(i, j)
        if not is_valid_location(possible_neighbor_loc):
          continue
        surrounding_cells.append(get_cell(possible_neighbor_loc))
    return surrounding_cells

  func get_diamond_neighbors(location: Vector2i) -> Array[CellData]:
    var surrounding_cells: Array[CellData] = []
    var diffs = [
      Vector2i(-2, 0),
      Vector2i(-1, -1),
      Vector2i(-1, 0),
      Vector2i(-1, 1),
      Vector2i(0, -2),
      Vector2i(0, -1),
      Vector2i(0, 1),
      Vector2i(0, 2),
      Vector2i(1, -1),
      Vector2i(1, 0),
      Vector2i(1, 1),
      Vector2i(2, 0),
    ]
    for diff in diffs:
      var possible_neighbor_loc = location + diff
      if not is_valid_location(possible_neighbor_loc):
        continue
      surrounding_cells.append(get_cell(possible_neighbor_loc))
    return surrounding_cells

  func is_valid_location(location: Vector2i) -> bool:
    return location.x >= 0 and location.x < 10 and location.y >= 0 and location.y < 13


class PlayerState:
  var level: int
  var current_health: int
  var current_experience: int
  
  func _init() -> void:
    level = 1
    current_health = max_health()
    current_experience = 0
  
  func level_up() -> void:
    current_experience -= next_level_experience()
    level += 1
    current_health = max_health()

  func max_health() -> int:
    return {
      1: 5,
      2: 5, # heart
      3: 6,
      4: 6, # heart
      5: 7,
      6: 7, # heart
      7: 8,
      8: 8, # heart
      9: 9,
      10: 9, # heart
      11: 10,
      12: 10, # heart
      13: 11,
      14: 11, # heart
      15: 12,
      16: 12, # heart
      17: 13,
      18: 13, # heart
      19: 14,
      20: 14, # heart
      21: 15,
      22: 15, # heart
    }[level]

  func next_level_experience() -> int:
    return {
      1: 4,
      2: 5,
      3: 7,
      4: 9,
      5: 9,
      6: 10,
      7: 12,
      8: 12,
      9: 12,
      10: 15,
      11: 18,
      12: 21,
      13: 21,
      14: 25,
      15: 25,
      16: 25,
      17: 25,
      18: 25,
      19: 25,
      20: 25,
      21: 25,
      22: 25,
    }[level]


var status: GameStatus
var grid: GridState
var player: PlayerState

func _init(p_grid: Array[CellData], seed_v: int) -> void:
  status = GameStatus.new()
  grid = GridState.new(p_grid, seed_v)
  player = PlayerState.new()
