class_name Sprites
extends RefCounted

const SPRITE_SIZE = 40

const SHEET := preload("res://sprites.png")
const SPRITES := {
  "rat_side": Rect2(0 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "rat_side_dead": Rect2(0 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "rat_up": Rect2(1 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "rat_up_dead": Rect2(1 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "bat": Rect2(2 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "bat_dead": Rect2(2 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "skeleton": Rect2(3 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "skeleton_dead": Rect2(3 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gargoyle_side": Rect2(4 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gargoyle_side_dead": Rect2(4 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gargoyle_up": Rect2(5 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gargoyle_up_dead": Rect2(5 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gargoyle_down": Rect2(6 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gargoyle_down_dead": Rect2(6 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "slime": Rect2(7 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "slime_dead": Rect2(7 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "minotaur": Rect2(8 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "minotaur_dead": Rect2(8 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "minotaur_opened": Rect2(9 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "minotaur_opened_dead": Rect2(9 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),

  "guardian": Rect2(0 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "guardian_dead": Rect2(0 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "purple_slime": Rect2(1 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "purple_slime_dead": Rect2(1 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_woman": Rect2(2 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_woman_dead": Rect2(2 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_woman_heartbroken": Rect2(3 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_woman_heartbroken_dead": Rect2(3 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_man": Rect2(4 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_man_dead": Rect2(4 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_man_heartbroken": Rect2(5 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "lover_man_heartbroken_dead": Rect2(5 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "engineer": Rect2(6 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "engineer_dead": Rect2(6 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "rat_king": Rect2(7 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "rat_king_dead": Rect2(7 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gazer": Rect2(8 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "gazer_dead": Rect2(8 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "slime_witch": Rect2(9 * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "slime_witch_dead": Rect2(9 * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
 
  "mimic": Rect2(0 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "chest": Rect2(0 * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "mine": Rect2(1 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "mine_dead": Rect2(1 * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "fairy": Rect2(2 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "fairy_caught": Rect2(2 * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "dragon": Rect2(3 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "dragon_dead": Rect2(3 * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "dragon_egg": Rect2(4 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "dragon_egg_dead": Rect2(4 * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),

  "wall_3": Rect2(6 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "wall_2": Rect2(7 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "wall_1": Rect2(8 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "wall_0": Rect2(9 * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),

  "reward_orb": Rect2(0 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "reward_scroll_orb": Rect2(1 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "reward_scroll_health": Rect2(2 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "reward_scroll_mine": Rect2(3 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "reward_scroll_rat": Rect2(4 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "reward_scroll_slime": Rect2(5 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "reward_crown": Rect2(6 * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),

  "guess_chest": Rect2(0 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "guess_green": Rect2(1 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "guess_blue": Rect2(2 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "guess_red": Rect2(3 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "guess_mine": Rect2(4 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "guess_trash": Rect2(5 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),

  "hero": Rect2(10 * SPRITE_SIZE, 50 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "hero_level_up": Rect2(10 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "hero_injured": Rect2(11 * SPRITE_SIZE, 0 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "hero_dead": Rect2(10 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
  "hero_victory": Rect2(11 * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),

  "exp_full": Rect2(5 * SPRITE_SIZE + 5, 4 * SPRITE_SIZE + 5, SPRITE_SIZE - 9, SPRITE_SIZE - 9), # custom to remove padding
  "exp_empty": Rect2(5 * SPRITE_SIZE + 5, 5 * SPRITE_SIZE + 5, SPRITE_SIZE - 9, SPRITE_SIZE - 9), # custom to remove padding
  "heart_full": Rect2(6 * SPRITE_SIZE + 5, 5 * SPRITE_SIZE + 6, SPRITE_SIZE - 9, SPRITE_SIZE - 9), # custom to remove padding
  "heart_empty": Rect2(7 * SPRITE_SIZE + 5, 5 * SPRITE_SIZE + 6, SPRITE_SIZE - 9, SPRITE_SIZE - 9), # custom to remove padding
  "book": Rect2(9 * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
}

static var _cache: Dictionary = {}

static func get_sprite(name: String) -> AtlasTexture:
    if not _cache.has(name):
      if not SPRITES.has(name):
        return null
      var tex := AtlasTexture.new()
      tex.atlas = SHEET
      tex.region = SPRITES[name]
      _cache[name] = tex
    return _cache[name]
