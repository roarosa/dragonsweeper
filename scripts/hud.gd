class_name HUD
extends Node

signal level_up_pressed
signal restart_pressed
var _hearts: Array[TextureRect] = []
var _experience_slots: Array[TextureRect] = []
var _hero_state: HERO_STATE = HERO_STATE.NORMAL

enum HERO_STATE {
  NORMAL,
  INJURED,
  LEVEL_UP,
  DEAD,
  VICTORY,
}

func _ready() -> void:
  _hearts.assign(%HealthContainer.find_children("*", "TextureRect"))
  _experience_slots.assign(%ExperienceContainer.find_children("*", "TextureRect"))
  %PlayerIcon.gui_input.connect(_on_PlayerIcon_gui_input)
  %GameOverBar.gui_input.connect(_on_GameOverBar_gui_input)


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
  %StatusContainer.visible = false
  %GameOverBar.visible = true
  %Message.text = _get_loss_message(grid.get_cell(killed_by), grid)


func show_win() -> void:
  %StatusContainer.visible = false
  %GameOverBar.visible = true
  %Message.text = "You won!"


func reset() -> void:
  %StatusContainer.visible = true
  %GameOverBar.visible = false
  _hero_state = HERO_STATE.NORMAL


func update_health(health: int, max_health: int) -> void:
  for i in range(_hearts.size()):
    var heart: TextureRect = _hearts[i]
    if i >= max_health:
      heart.visible = false
    elif i < health:
      heart.visible = true
      heart.texture = Sprites.get_sprite("heart_full")
      heart.modulate = Color.WHITE
    else:
      heart.visible = true
      heart.texture = Sprites.get_sprite("heart_empty")
      heart.modulate = Color.DARK_GRAY


func update_experience(experience: int, next_level: int) -> void:
  for i in range(_experience_slots.size()):
    var slot: TextureRect = _experience_slots[i]
    if i >= next_level:
      slot.visible = false
    elif i < experience:
      slot.visible = true
      slot.texture = Sprites.get_sprite("exp_full")
      slot.modulate = Color.WHITE
    else:
      slot.visible = true
      slot.texture = Sprites.get_sprite("exp_empty")


func update_hero_state(state: HERO_STATE) -> void:
  _hero_state = state
  match _hero_state:
    HERO_STATE.LEVEL_UP:
      %PlayerIcon.texture = Sprites.get_sprite("hero_level_up")
    HERO_STATE.INJURED:
      %PlayerIcon.texture = Sprites.get_sprite("hero_injured")
    HERO_STATE.DEAD:
      %PlayerIcon.texture = Sprites.get_sprite("hero_dead")
    HERO_STATE.VICTORY:
      %PlayerIcon.texture = Sprites.get_sprite("hero_victory")
    _:
      %PlayerIcon.texture = Sprites.get_sprite("hero")


func _on_PlayerIcon_gui_input(event: InputEvent) -> void:
  if event.is_action_pressed("left_click"):
    if _hero_state == HERO_STATE.LEVEL_UP:
      level_up_pressed.emit()
    else:
      print("No level up!")


func _on_GameOverBar_gui_input(event: InputEvent) -> void:
  if event.is_action_pressed("left_click"):
    if _hero_state == HERO_STATE.VICTORY or _hero_state == HERO_STATE.DEAD:
      restart_pressed.emit()
    else:
      print("No restart!")
