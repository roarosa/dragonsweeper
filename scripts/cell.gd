class_name Cell
extends PanelContainer

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
  LICH,
  RAT_KING,
  MIND_FLAYER,
  SLIME_WITCH,
  MIMIC,
  MINE,
  GNOME,
  DRAGON,
  DRAGON_EGG,
  CHEST,
  WALL_0,
  WALL_1,
  WALL_2,
  WALL_3,
  FALLBACK,
}

# TODO: replace with assets
const MONSTER_LABELS = {
  MonsterView.RAT_LEFT: "<🐀",
  MonsterView.RAT_RIGHT: "🐀>",
  MonsterView.RAT_UP: "^🐀^",
  MonsterView.BAT: "🦇",
  MonsterView.SKELETON: "💀",
  MonsterView.GARGOYLE_UP: "^🧟",
  MonsterView.GARGOYLE_DOWN: "🧟v",
  MonsterView.GARGOYLE_LEFT: "<🧟",
  MonsterView.GARGOYLE_RIGHT: "🧟>",
  MonsterView.SLIME: "💧",
  MonsterView.MINOTAUR_LEFT: "<🐂",
  MonsterView.MINOTAUR_RIGHT: "🐂>",
  MonsterView.MINOTAUR_LEFT_OPEN: "<!🐂",
  MonsterView.MINOTAUR_RIGHT_OPEN: "🐂!>",
  MonsterView.GUARDIAN: "🛡️",
  MonsterView.PURPLE_SLIME: "💧+",
  MonsterView.LOVER_LEFT: "<💕",
  MonsterView.LOVER_RIGHT: "💕>",
  MonsterView.LOVER_LEFT_BROKEN: "<!💕",
  MonsterView.LOVER_RIGHT_BROKEN: "💕!>",
  MonsterView.LICH: "🧛🏻‍♀️",
  MonsterView.RAT_KING: "🐀👑",
  MonsterView.MIND_FLAYER: "👾",
  MonsterView.SLIME_WITCH: "🧙",
  MonsterView.MIMIC: "🎁",
  MonsterView.MINE: "💥",
  MonsterView.GNOME: "🧚",
  MonsterView.DRAGON: "🐉",
  MonsterView.DRAGON_EGG: "🥚",
  MonsterView.CHEST: "🎁",
  MonsterView.WALL_0: "🧱0",
  MonsterView.WALL_1: "🧱1",
  MonsterView.WALL_2: "🧱2",
  MonsterView.WALL_3: "🧱3",
  MonsterView.FALLBACK: "⍰",
}

# TODO replace with assets
const SCROLL_REWARD_LABELS = {
  CellData.Reward.ScrollType.HEALING: "(❤️)",
  CellData.Reward.ScrollType.SCRYING: "(👀)",
  CellData.Reward.ScrollType.SCRYING_INITIAL: "(👀)",
  CellData.Reward.ScrollType.MINES: "(💥)",
  CellData.Reward.ScrollType.RATS: "(🐁)",
  CellData.Reward.ScrollType.SLIMES: "(💧)",
}

var cell_disabled: bool = false
var _can_guess: bool


func set_mode_hidden() -> void:
  _set_background_color(Color.WHITE)
  _display_name(false)
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
  elif guess_value == CellData.GuessValue.MINE:
    guess_color = Color.RED
  _display_name(true, GuessPopup.GUESS_LABELS[guess_value], guess_color)
  _display_number(false)
  _display_symbol(false)
  _can_guess = true

func set_mode_mind_flayer_hidden() -> void:
  _set_background_color(Color.DARK_GRAY)
  _display_name(false)
  _display_number(true, "?", Color.PURPLE)
  _display_symbol(false)
  _can_guess = false

func set_mode_empty(surrounding_value: int) -> void:
  _set_background_color(Color.DARK_GRAY)
  _display_name(false)
  _display_number(true, "" if surrounding_value == 0 else str(surrounding_value))
  _display_symbol(false)
  _can_guess = false

func set_mode_revealed(monster_view: MonsterView, health: int, locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(true, MONSTER_LABELS[monster_view])
  _display_number(true, str(health), Color.YELLOW)
  _display_symbol(false)
  _can_guess = false

func set_mode_revealed_icon_only(monster_view: MonsterView, locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(true, MONSTER_LABELS[monster_view])
  _display_number(false)
  _display_symbol(false)
  _can_guess = false

func set_mode_reward_experience(monster_view: MonsterView, experience: int, locked: bool = false) -> void:
  _set_background_color(Color.YELLOW if not locked else Color.DARK_GRAY)
  _display_name(true, MONSTER_LABELS[monster_view])
  _display_number(true, str(experience))
  _display_symbol(true)
  _can_guess = false

func set_mode_reward_scroll(scroll_type: CellData.Reward.ScrollType, locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(true, SCROLL_REWARD_LABELS[scroll_type], Color.CORNFLOWER_BLUE)
  _display_number(false)
  _display_symbol(false)
  _can_guess = false

func set_mode_reward_crown(locked: bool = false) -> void:
  _set_background_color(Color.WHITE if not locked else Color.DARK_GRAY)
  _display_name(true, "(👑)", Color.GOLDENROD)
  _display_number(false)
  _display_symbol(false)
  _can_guess = false


func _set_background_color(color: Color) -> void:
  background_node.modulate = color

# TODO: replace with icon assets
func _display_name(p_visible: bool, p_text: String = "", p_modulate: Color = Color.WHITE) -> void:
  name_node.visible = p_visible
  name_node.modulate = p_modulate
  name_node.text = p_text

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
