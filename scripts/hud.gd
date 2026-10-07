extends Node

const EXPERIENCE_COLOR_GOOD = Color("#e39b44")
const EXPERIENCE_COLOR_BAD = Color("#000000")

signal level_up_pressed
var _can_level_up: bool = false
var _hearts: Array[TextureRect] = []
var _experience_slots: Array[TextureRect] = []


func _ready() -> void:
  %PlayerIcon.pressed.connect(_button_pressed)
  _hearts.assign(%HealthContainer.find_children("*", "TextureRect"))
  _experience_slots.assign(%ExperienceContainer.find_children("*", "TextureRect"))


func _get_loss_message(cell_data: CellData, grid: GameState.GridState) -> String:
  if cell_data is CellData.MonsterRat:
    return "You were killed by a rat. How embarrassing."
  elif cell_data is CellData.MonsterBat:
    return "You were killed by a bat."
  elif cell_data is CellData.MonsterSkeleton:
    return "You were killed by a spooky scary skeleton."
  elif cell_data is CellData.MonsterGargoyle:
    return "You were killed by a gargoyle."
  elif cell_data is CellData.MonsterSlime:
    return "You got slimed. Gross."
  elif cell_data is CellData.MonsterMinotaur:
    return "You were killed by a minotaur."
  elif cell_data is CellData.MonsterGuardian:
    return "You were killed by a guardian."
  elif cell_data is CellData.MonsterPurpleSlime:
    return "You got purple slimed. Gross."
  elif cell_data is CellData.MonsterLover:
    var lover_killed = cell_data.is_lover_killed(grid)
    if lover_killed:
      return "You were killed by a vengeful lover. Serves you right."
    else:
      return "You were killed by a lover. How romantic."
  elif cell_data is CellData.MonsterEngineer:
    return "You avoided his mines, but were killed by the mine king himself."
  elif cell_data is CellData.MonsterRatKing:
    return "You were killed by the rat king. Long live the king!"
  elif cell_data is CellData.MonsterGazer:
    return "You were lost to the mists of a Watcher."
  elif cell_data is CellData.MonsterSlimeWitch:
    return "You were killed by the slime witch."
  elif cell_data is CellData.MonsterMimic:
    return "You were eaten by a mimic. Can't trust anything these days."
  elif cell_data is CellData.MonsterMine:
    return "You were exploded by a mine."
  elif cell_data is CellData.MonsterDragon:
    return "You were killed by a dragon. Should have prepared better."
  return "YOU DIED"


func show_loss(grid: GameState.GridState, killed_by: Vector2i) -> void:
  %PlayerIcon.disabled = true
  %HealthContainer.visible = false
  %ExperienceContainer.visible = false
  %LossMessage.visible = true
  %LossMessage.text = _get_loss_message(grid.get_cell(killed_by), grid) + "\nTry again!"


func show_win() -> void:
  %PlayerIcon.disabled = true
  %HealthContainer.visible = false
  %ExperienceContainer.visible = false


func update_health(health: int, max_health: int) -> void:
  for i in range(_hearts.size()):
    var heart: TextureRect = _hearts[i]
    if i < health:
      heart.visible = true
      heart.texture = Sprites.get_sprite("heart_full")
      heart.modulate = Color.WHITE
    elif i < max_health:
      heart.visible = true
      heart.texture = Sprites.get_sprite("heart_empty")
      heart.modulate = Color.DARK_GRAY
    else:
      heart.visible = false


func update_experience(experience: int, next_level: int) -> void:
  _can_level_up = experience >= next_level
  # var current_experience_nodes = %ExperienceContainer.get_child_count()
  # if current_experience_nodes < next_level:
  #   for i in next_level - current_experience_nodes:
  #     %ExperienceContainer.add_child(_make_experience_slot())
  # elif next_level < current_experience_nodes:
  #   var to_remove = %ExperienceContainer.get_children().slice(next_level)
  #   for child in to_remove:
  #     %ExperienceContainer.remove_child(child)
  #     child.queue_free()

  # for i in range(next_level):
  #   var slot = %ExperienceContainer.get_child(i)
  #   slot.color = EXPERIENCE_COLOR_GOOD if i < experience else EXPERIENCE_COLOR_BAD
  for i in range(_experience_slots.size()):
    var slot: TextureRect = _experience_slots[i]
    if i < experience:
      slot.visible = true
      slot.texture = Sprites.get_sprite("exp_full")
      slot.modulate = Color.WHITE
    elif i < next_level:
      slot.visible = true
      slot.texture = Sprites.get_sprite("exp_empty")
      slot.modulate = Color.DARK_GRAY
    else:
      slot.visible = false


func _make_experience_slot():
  var slot = ColorRect.new()
  slot.custom_minimum_size = Vector2(20, 20)
  return slot

func _button_pressed() -> void:
  if _can_level_up:
    level_up_pressed.emit()
  else:
    print("No level up!")
