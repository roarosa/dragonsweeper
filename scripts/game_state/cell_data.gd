@abstract
class_name CellData
extends RefCounted

enum CellState {
  HIDDEN,
  REVEALED,
  DEAD,
}

enum GuessValue {
  ONE,
  TWO,
  THREE,
  FOUR,
  FIVE,
  SIX,
  SEVEN,
  EIGHT,
  NINE,
  TEN,
  MINE,
  CHEST,
  BLUE,
  GREEN,
  RED,
  NONE,
}

class Reward:
  enum Type {
    EXPERIENCE,
    SCROLL,
    WIN,
  }

  enum ScrollType {
    NONE,
    HEALING,
    SCRYING,
    SCRYING_INITIAL,
    MINES,
    RATS,
    SLIMES,
  }

  var type: Type
  var experience: int
  var scroll: ScrollType

  func _init(p_type: Type, p_experience: int, p_scroll: ScrollType) -> void:
    type = p_type
    experience = p_experience
    scroll = p_scroll


var location: Vector2i
var health: int

var state: CellState
var guess_value: GuessValue
var rewards: Array[Reward]


func _init(p_location: Vector2i, p_health: int = 0) -> void:
  location = p_location
  health = p_health
  state = CellState.HIDDEN
  guess_value = GuessValue.NONE
  rewards = [Reward.new(Reward.Type.EXPERIENCE, p_health, Reward.ScrollType.NONE)]


func get_surrounding_value(grid: GameState.GridState) -> int:
  grid.get_immediate_neighbors(location)
  var value = 0
  for neighbor in grid.get_immediate_neighbors(location):
    if neighbor.state != CellState.DEAD and neighbor is not CellData.Wall:
      value += neighbor.health
  return value


func is_gazer_hidden(grid: GameState.GridState) -> bool:
  for cell_data in grid.get_diamond_neighbors(location):
    if cell_data is not MonsterGazer:
      continue
    if cell_data.state != CellState.DEAD:
      return true
  return false


class MonsterRat extends CellData:
  enum Direction {
    UP,
    LEFT,
    RIGHT,
  }

  var rat_king_location: Vector2i

  func _init(p_location: Vector2i, p_rat_king_location: Vector2i) -> void:
    super(p_location, 1)
    rat_king_location = p_rat_king_location
  
  func is_rat_king_killed(grid: GameState.GridState) -> bool:
    var king_state = grid.get_cell(rat_king_location).state
    return king_state == CellState.DEAD
  
  func get_direction(grid: GameState.GridState) -> Direction:
    if is_rat_king_killed(grid):
      return Direction.UP
    var dir_diff = rat_king_location.y - location.y
    if dir_diff == 0:
      return Direction.UP
    elif dir_diff > 0:
      return Direction.RIGHT
    else:
      return Direction.LEFT


class MonsterBat extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 2)


class MonsterSkeleton extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 3)


class MonsterGargoyle extends CellData:
  enum Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT,
  }

  var direction: Direction

  func _init(p_location: Vector2i, p_direction: Direction) -> void:
    super(p_location, 4)
    direction = p_direction


class MonsterSlime extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 5)


class MonsterMinotaur extends CellData:
  enum Direction {
    LEFT,
    RIGHT,
  }

  var chest_location: Vector2i
  
  func _init(p_location: Vector2i, p_chest_location: Vector2i) -> void:
    super(p_location, 6)
    chest_location = p_chest_location

  func is_chest_opened(grid: GameState.GridState) -> bool:
    var chest_state = grid.get_cell(chest_location).state
    return chest_state == CellState.DEAD

  func get_chest_direction() -> Direction:
    var dir_diff = chest_location.y - location.y
    return Direction.RIGHT if dir_diff > 0 else Direction.LEFT


class MonsterGuardian extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 7)


class MonsterPurpleSlime extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 8)


class MonsterLover extends CellData:
  enum Direction {
    LEFT,
    RIGHT,
  }

  var lover_location: Vector2i

  func _init(p_location: Vector2i, p_lover_location: Vector2i) -> void:
    super(p_location, 9)
    lover_location = p_lover_location
    rewards = [
      Reward.new(Reward.Type.EXPERIENCE, health, Reward.ScrollType.NONE),
      Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.HEALING),
    ]
  
  func get_direction() -> Direction:
    var dir_diff = lover_location.y - location.y
    return Direction.RIGHT if dir_diff > 0 else Direction.LEFT
  
  func is_lover_killed(grid: GameState.GridState) -> bool:
    return grid.get_cell(lover_location).state == CellState.DEAD


class MonsterEngineer extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 10)
    rewards = [
      Reward.new(Reward.Type.EXPERIENCE, health, Reward.ScrollType.NONE),
      Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.MINES),
    ]


class MonsterRatKing extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 5)
    rewards = [
      Reward.new(Reward.Type.EXPERIENCE, health, Reward.ScrollType.NONE),
      Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.RATS),
    ]


class MonsterGazer extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 5)


class MonsterSlimeWitch extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 1)
    rewards = [
      Reward.new(Reward.Type.EXPERIENCE, health, Reward.ScrollType.NONE),
      Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.SLIMES),
    ]


class MonsterMimic extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 11)


class EmptyCell extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location)
    rewards = []


class MonsterMine extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 100)
    rewards = [Reward.new(Reward.Type.EXPERIENCE, 3, Reward.ScrollType.NONE)]


class Chest extends CellData:
  enum Content {
    MONEY,
    HEALTH,
  }
  var minotaur_location: Vector2i

  func _init(p_location: Vector2i, p_minotaur_location: Vector2i, p_content: Content) -> void:
    super(p_location)
    minotaur_location = p_minotaur_location
    if p_content == Content.MONEY:
      rewards = [Reward.new(Reward.Type.EXPERIENCE, 5, Reward.ScrollType.NONE)]
    elif p_content == Content.HEALTH:
      rewards = [Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.HEALING)]


class ScrollHealth extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location)
    rewards = [Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.HEALING)]

 
class ScrollScrying extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location)
    rewards = [Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.SCRYING)]

 
class MonsterDragon extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 13)
    state = CellState.REVEALED
    rewards = [
      Reward.new(Reward.Type.EXPERIENCE, health, Reward.ScrollType.NONE),
      Reward.new(Reward.Type.WIN, 0, Reward.ScrollType.NONE),
    ]


class ScryingOrb extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location)
    state = CellState.DEAD
    rewards = [Reward.new(Reward.Type.SCROLL, 0, Reward.ScrollType.SCRYING_INITIAL)]


class DragonEgg extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location)
    rewards = [Reward.new(Reward.Type.EXPERIENCE, 3, Reward.ScrollType.NONE)]


class Wall extends CellData:
  func _init(p_location: Vector2i) -> void:
    super(p_location, 3)
    rewards = [Reward.new(Reward.Type.EXPERIENCE, 1, Reward.ScrollType.NONE)]
