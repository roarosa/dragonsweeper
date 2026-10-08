class_name Cell
extends Container

@onready var number_node: Label = %Number
@onready var symbol_node: TextureRect = %ExpIcon
@onready var icon_node: TextureRect = %Icon
@onready var name_node: Label = %Name
@onready var background_node: PanelContainer = %Background

signal clicked
signal right_clicked

enum CellMode {
  NORMAL,
  EMPTY,
  REWARD,
}

enum MonsterView {
  RAT_LEFT,
  RAT_RIGHT,
  RAT_UP,
  BAT,
  SKELETON,
  GARGOYLE_UP,
  GARGOYLE_DOWN,
  GARGOYLE_LEFT,
  GARGOYLE_RIGHT,
  SLIME,
  MINOTAUR_LEFT,
  MINOTAUR_RIGHT,
  MINOTAUR_LEFT_OPEN,
  MINOTAUR_RIGHT_OPEN,
  GUARDIAN,
  PURPLE_SLIME,
  LOVER_LEFT,
  LOVER_RIGHT,
  LOVER_LEFT_BROKEN,
  LOVER_RIGHT_BROKEN,
  ENGINEER,
  RAT_KING,
  GAZER,
  SLIME_WITCH,
  MIMIC,
  MINE,
  FAIRY,
  DRAGON,
  DRAGON_EGG,
  CHEST,
  WALL_0,
  WALL_1,
  WALL_2,
  WALL_3,
  FALLBACK,
}

const MONSTER_TEXTURES = {
  MonsterView.RAT_LEFT: ["rat_side", true],
  MonsterView.RAT_RIGHT: ["rat_side", false],
  MonsterView.RAT_UP: ["rat_up", false],
  MonsterView.BAT: ["bat", false],
  MonsterView.SKELETON: ["skeleton", false],
  MonsterView.GARGOYLE_UP: ["gargoyle_up", false],
  MonsterView.GARGOYLE_DOWN: ["gargoyle_down", false],
  MonsterView.GARGOYLE_LEFT: ["gargoyle_side", true],
  MonsterView.GARGOYLE_RIGHT: ["gargoyle_side", false],
  MonsterView.SLIME: ["slime", false],
  MonsterView.MINOTAUR_LEFT: ["minotaur", true],
  MonsterView.MINOTAUR_RIGHT: ["minotaur", false],
  MonsterView.MINOTAUR_LEFT_OPEN: ["minotaur_opened", false],
  MonsterView.MINOTAUR_RIGHT_OPEN: ["minotaur_opened", true],
  MonsterView.GUARDIAN: ["guardian", false],
  MonsterView.PURPLE_SLIME: ["purple_slime", false],
  MonsterView.LOVER_LEFT: ["lover_woman", false],
  MonsterView.LOVER_RIGHT: ["lover_man", false],
  MonsterView.LOVER_LEFT_BROKEN: ["lover_woman_heartbroken", false],
  MonsterView.LOVER_RIGHT_BROKEN: ["lover_man_heartbroken", false],
  MonsterView.ENGINEER: ["engineer", false],
  MonsterView.RAT_KING: ["rat_king", false],
  MonsterView.GAZER: ["gazer", false],
  MonsterView.SLIME_WITCH: ["slime_witch", false],
  MonsterView.MIMIC: ["chest", false],
  MonsterView.MINE: ["mine", false],
  MonsterView.FAIRY: ["fairy", false],
  MonsterView.DRAGON: ["dragon", false],
  MonsterView.DRAGON_EGG: ["dragon_egg", false],
  MonsterView.CHEST: ["chest", false],
  MonsterView.WALL_0: ["wall_0", false],
  MonsterView.WALL_1: ["wall_1", false],
  MonsterView.WALL_2: ["wall_2", false],
  MonsterView.WALL_3: ["wall_3", false],
  MonsterView.FALLBACK: ["", false],
}

const SCROLL_REWARD_TEXTURE_NAMES = {
  CellData.Reward.ScrollType.HEALING: "reward_scroll_health",
  CellData.Reward.ScrollType.SCRYING: "reward_scroll_orb",
  CellData.Reward.ScrollType.SCRYING_INITIAL: "reward_orb",
  CellData.Reward.ScrollType.MINES: "reward_scroll_mine",
  CellData.Reward.ScrollType.RATS: "reward_scroll_rat",
  CellData.Reward.ScrollType.SLIMES: "reward_scroll_slime",
}

var cell_disabled: bool = false
var _can_guess: bool


func set_mode_hidden() -> void:
  _set_background_color(Color.WHITE)
  _display_name(false)
  _display_icon(false)
  _display_number(false)
  _display_symbol(false)
  _can_guess = true

func set_mode_guess(guess_value: CellData.GuessValue) -> void:
  _set_background_color(Color.WHITE)
  var guess_color = Color.YELLOW
  if guess_value == CellData.GuessValue.BLUE:
    guess_color = Color.BLUE
  elif guess_value == CellData.GuessValue.GREEN:
    guess_color = Color.GREEN
  elif guess_value == CellData.GuessValue.RED:
    guess_color = Color.RED
  elif guess_value == CellData.GuessValue.CHEST:
    guess_color = Color.YELLOW
  elif guess_value == CellData.GuessValue.MINE:
    guess_color = Color.RED
  _display_name(true, GuessPopup.GUESS_LABELS[guess_value], guess_color)
  _display_icon(false)
  _display_number(false)
  _display_symbol(false)
  _can_guess = true

func set_mode_gazer_hidden() -> void:
  _set_background_color(Color.DARK_GRAY)
  _display_name(false)
  _display_icon(false)
  # TODO: Way too hard to see
  _display_number(true, "?", Color.PURPLE)
  _display_symbol(false)
  _can_guess = false

func set_mode_empty(surrounding_value: int) -> void:
  _set_background_color(Color.DARK_GRAY)
  _display_name(false)
  _display_icon(false)
  _display_number(true, "" if surrounding_value == 0 else str(surrounding_value))
  _display_symbol(false)
  _can_guess = false

func set_mode_revealed(monster_view: MonsterView, health: int, locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(false)
  _display_icon(true, MONSTER_TEXTURES[monster_view][0], MONSTER_TEXTURES[monster_view][1])
  _display_number(true, str(health), Color.YELLOW)
  _display_symbol(false)
  _can_guess = false

func set_mode_revealed_icon_only(monster_view: MonsterView, locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(false)
  _display_icon(true, MONSTER_TEXTURES[monster_view][0], MONSTER_TEXTURES[monster_view][1])
  _display_number(false)
  _display_symbol(false)
  _can_guess = false

func set_mode_reward_experience(monster_view: MonsterView, experience: int, locked: bool = false) -> void:
  _set_background_color(Color.YELLOW if not locked else Color.DARK_GRAY)
  _display_name(false)
  _display_icon(true, MONSTER_TEXTURES[monster_view][0], MONSTER_TEXTURES[monster_view][1])
  _display_number(true, str(experience))
  _display_symbol(true)
  _can_guess = false

func set_mode_reward_scroll(scroll_type: CellData.Reward.ScrollType, locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(false)
  _display_icon(true, SCROLL_REWARD_TEXTURE_NAMES[scroll_type], false, 36)
  _display_number(false)
  _display_symbol(false)
  _can_guess = false

func set_mode_reward_crown(locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(false)
  _display_icon(true, "reward_crown", false, 36)
  _display_number(false)
  _display_symbol(false)
  _can_guess = false


func _set_background_color(color: Color) -> void:
  background_node.modulate = color

func _display_name(p_visible: bool, p_text: String = "", p_modulate: Color = Color.WHITE) -> void:
  name_node.visible = p_visible
  name_node.modulate = p_modulate
  name_node.text = p_text

func _display_icon(p_visible: bool, p_tex_name: String = "", flip_h: bool = false, p_size: int = 26) -> void:
  icon_node.visible = p_visible
  if p_visible:
    icon_node.texture = Sprites.get_sprite(p_tex_name)
    icon_node.flip_h = flip_h
    icon_node.custom_minimum_size = Vector2(p_size, p_size)

func _display_number(p_visible: bool, p_text: String = "", p_modulate: Color = Color.WHITE) -> void:
  number_node.visible = p_visible
  number_node.modulate = p_modulate
  number_node.text = p_text

func _display_symbol(p_visible: bool) -> void:
  symbol_node.visible = p_visible


func _gui_input(event: InputEvent) -> void:
  if event.is_action_pressed("left_click"):
    if not cell_disabled:
      clicked.emit()
    accept_event()
  if event.is_action_pressed("right_click"):
    if not cell_disabled and _can_guess:
      right_clicked.emit()
    accept_event()
