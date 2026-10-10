class_name GridGenerator
extends RefCounted

static func _remove_location(locations: Array[Vector2i], loc: Vector2i) -> bool:
  var loc_index = locations.find(loc)
  if loc_index == -1:
    return false
  locations.pop_at(loc_index)
  return true


static func _pop_random_location(locations: Array[Vector2i], rng: RandomNumberGenerator) -> Vector2i:
  var loc_index = rng.randi_range(0, locations.size() - 1)
  return locations.pop_at(loc_index)


static func _pop_random_filtered_location(locations: Array[Vector2i], rng: RandomNumberGenerator, filter: Callable) -> Vector2i:
  var filtered_locations: Array[Vector2i] = locations.filter(filter)
  if filtered_locations.size() == 0:
    return Vector2i(-1, -1)
  var loc = filtered_locations[rng.randi_range(0, filtered_locations.size() - 1)]
  _remove_location(locations, loc)
  return loc


static func _min_distance_away(a: Vector2i, b: Vector2i, dist: int) -> bool:
  return abs(a.x - b.x) + abs(a.y - b.y) > dist

static func _scry_distance_away(a: Vector2i, b: Vector2i) -> bool:
  return _min_distance_away(a, b, 2)

static func _is_edge(a: Vector2i) -> bool:
  return a.x == 0 or a.x == 9 or a.y == 0 or a.y == 12

static func _is_corner(a: Vector2i) -> bool:
  return (a.x == 0 or a.x == 9) and (a.y == 0 or a.y == 12)

static func _is_valid_location(a: Vector2i) -> bool:
  return a.x >= 0 and a.x <= 9 and a.y >= 0 and a.y <= 12


static func generate_grid(rng: RandomNumberGenerator) -> Array[CellData]:
  # return TestGrid.get_test_grid()
  var empty_locations: Array[Vector2i] = []
  for row in range(10):
    for col in range(13):
      empty_locations.append(Vector2i(row, col))
  var grid: Array[CellData] = []

  # dragon
  var dragon_location = Vector2i(4, 6)
  grid.append(CellData.MonsterDragon.new(dragon_location))
  _remove_location(empty_locations, dragon_location)

  # egg
  var egg_index = rng.randi_range(0, 7)
  var egg_location = dragon_location
  if egg_index < 3:
    egg_location.x -= 1
  elif egg_index > 4:
    egg_location.x += 1
  if egg_index == 0 or egg_index == 3 or egg_index == 5:
    egg_location.y -= 1
  elif egg_index == 2 or egg_index == 4 or egg_index == 7:
    egg_location.y += 1
  grid.append(CellData.DragonEgg.new(egg_location))
  _remove_location(empty_locations, egg_location)

  # engineer
  var eng_index = rng.randi_range(0, 3)
  var eng_location = Vector2i(0, 0)
  if eng_index == 0:
    eng_location = Vector2i(0, 0)
  elif eng_index == 1:
    eng_location = Vector2i(9, 0)
  elif eng_index == 2:
    eng_location = Vector2i(0, 12)
  elif eng_index == 3:
    eng_location = Vector2i(9, 12)
  grid.append(CellData.MonsterEngineer.new(eng_location))
  _remove_location(empty_locations, eng_location)

  # scry orb
  var scry_orb_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(loc: Vector2i):
      return _scry_distance_away(loc, dragon_location) \
        and _scry_distance_away(loc, egg_location) \
        and _scry_distance_away(loc, eng_location) \
        and (loc.x > 1 and loc.x < 8) and (loc.y > 1 and loc.y < 11)
  )
  grid.append(CellData.ScryingOrb.new(scry_orb_location))
  _remove_location(empty_locations, scry_orb_location)

  # slime witch + purple slimes
  var slime_witch_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(l: Vector2i):
      return _is_edge(l) \
        and not _is_corner(l) \
        and _min_distance_away(l, scry_orb_location, 4) \
        and _min_distance_away(l, eng_location, 2)
  )
  grid.append(CellData.MonsterSlimeWitch.new(slime_witch_location))
  _remove_location(empty_locations, slime_witch_location)
  for r in range(-1, 2):
    for c in range(-1, 2):
      var loc = Vector2i(r, c) + slime_witch_location
      if loc != slime_witch_location and _is_valid_location(loc):
        grid.append(CellData.MonsterPurpleSlime.new(loc))
        _remove_location(empty_locations, loc)

  # lovers
  var lover_left_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(l: Vector2i): return l.y < 6 and empty_locations.has(Vector2i(l.x, 12 - l.y))
  )
  var lover_right_location = Vector2i(lover_left_location.x, 12 - lover_left_location.y)
  grid.append(CellData.MonsterLover.new(lover_left_location, lover_right_location))
  grid.append(CellData.MonsterLover.new(lover_right_location, lover_left_location))
  _remove_location(empty_locations, lover_left_location)
  _remove_location(empty_locations, lover_right_location)

  # chests + minotaurs
  for i in range(5):
    var chest_location = _pop_random_filtered_location(
      empty_locations,
      rng,
      func(l: Vector2i): return _scry_distance_away(l, scry_orb_location)
    )
    var minotaur_location = _pop_random_filtered_location(
      empty_locations,
      rng,
      func(l: Vector2i): return abs(l.y - chest_location.y) == 1 and abs(l.x - chest_location.x) <= 1
    )
    if minotaur_location == Vector2i(-1, -1):
      return [] # small chance of no minotaur placement
    grid.append(CellData.MonsterMinotaur.new(minotaur_location, chest_location))
    grid.append(CellData.Chest.new(
      chest_location,
      minotaur_location,
      CellData.Chest.Content.HEALTH if i < 2 else CellData.Chest.Content.MONEY
    ))
    _remove_location(empty_locations, chest_location)
    _remove_location(empty_locations, minotaur_location)

  # gargoyles
  for i in range(4):
    if rng.randi_range(0, 1) == 0:
      # up/down gargoyles
      var loc1 = _pop_random_filtered_location(
        empty_locations,
        rng,
        func(l: Vector2i): return l.x < 9 and empty_locations.has(Vector2i(l.x + 1, l.y))
      )
      if loc1 == Vector2i(-1, -1):
        return [] # small chance of no gargoyle placement
      var loc2 = loc1 + Vector2i(1, 0)
      grid.append(CellData.MonsterGargoyle.new(loc1, CellData.MonsterGargoyle.Direction.DOWN))
      grid.append(CellData.MonsterGargoyle.new(loc2, CellData.MonsterGargoyle.Direction.UP))
      _remove_location(empty_locations, loc2)
    else:
      # left/right gargoyles
      var loc1 = _pop_random_filtered_location(
        empty_locations,
        rng,
        func(l: Vector2i): return l.y < 12 and empty_locations.has(Vector2i(l.x, l.y + 1))
      )
      if loc1 == Vector2i(-1, -1):
        return [] # small chance of no gargoyle placement
      var loc2 = loc1 + Vector2i(0, 1)
      grid.append(CellData.MonsterGargoyle.new(loc1, CellData.MonsterGargoyle.Direction.RIGHT))
      grid.append(CellData.MonsterGargoyle.new(loc2, CellData.MonsterGargoyle.Direction.LEFT))
      _remove_location(empty_locations, loc2)

  # walls
  for i in range(3):
    if rng.randi_range(0, 1) == 0:
      # up/down walls
      var loc1 = _pop_random_filtered_location(
        empty_locations,
        rng,
        func(l: Vector2i): return l.x < 9 and empty_locations.has(Vector2i(l.x + 1, l.y))
      )
      if loc1 == Vector2i(-1, -1):
        return [] # small chance of no wall placement
      var loc2 = loc1 + Vector2i(1, 0)
      grid.append(CellData.Wall.new(loc1))
      grid.append(CellData.Wall.new(loc2))
      _remove_location(empty_locations, loc2)
    else:
      # left/right walls
      var loc1 = _pop_random_filtered_location(
        empty_locations,
        rng,
        func(l: Vector2i): return l.y < 12 and empty_locations.has(Vector2i(l.x, l.y + 1))
      )
      if loc1 == Vector2i(-1, -1):
        return [] # small chance of no wall placement
      var loc2 = loc1 + Vector2i(0, 1)
      grid.append(CellData.Wall.new(loc1))
      grid.append(CellData.Wall.new(loc2))
      _remove_location(empty_locations, loc2)

  # guardians
  var guardian_upperleft_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(l: Vector2i): return l.x < 4 and l.y < 6
  )
  var guardian_upperright_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(l: Vector2i): return l.x < 4 and l.y > 6
  )
  var guardianlowerleft_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(l: Vector2i): return l.x > 4 and l.y < 6
  )
  var guardianlowerright_location = _pop_random_filtered_location(
    empty_locations,
    rng,
    func(l: Vector2i): return l.x > 4 and l.y > 6
  )
  grid.append(CellData.MonsterGuardian.new(guardian_upperleft_location))
  grid.append(CellData.MonsterGuardian.new(guardian_upperright_location))
  grid.append(CellData.MonsterGuardian.new(guardianlowerleft_location))
  grid.append(CellData.MonsterGuardian.new(guardianlowerright_location))
  _remove_location(empty_locations, guardian_upperleft_location)
  _remove_location(empty_locations, guardian_upperright_location)
  _remove_location(empty_locations, guardianlowerleft_location)
  _remove_location(empty_locations, guardianlowerright_location)

  # other random placements
  var scry_scroll_location = _pop_random_filtered_location(empty_locations, rng, func(loc: Vector2i): return _scry_distance_away(loc, scry_orb_location))
  grid.append(CellData.ScrollScrying.new(scry_scroll_location))
  var rat_king_location = _pop_random_filtered_location(empty_locations, rng, func(loc: Vector2i): return _scry_distance_away(loc, scry_orb_location))
  grid.append(CellData.MonsterRatKing.new(rat_king_location))
  var mimic_location = _pop_random_filtered_location(empty_locations, rng, func(loc: Vector2i): return _scry_distance_away(loc, scry_orb_location))
  grid.append(CellData.MonsterMimic.new(mimic_location))
  for i in range(rng.randi_range(1, 2)):
    var loc = _pop_random_filtered_location(empty_locations, rng, func(l: Vector2i): return _scry_distance_away(l, scry_orb_location))
    grid.append(CellData.MonsterGazer.new(loc))
  for i in range(9):
    var loc = _pop_random_filtered_location(empty_locations, rng, func(l: Vector2i): return _scry_distance_away(l, scry_orb_location))
    grid.append(CellData.MonsterMine.new(loc))
  for i in range(13):
    var loc = _pop_random_location(empty_locations, rng)
    grid.append(CellData.MonsterRat.new(loc, rat_king_location))
  for i in range(12):
    var loc = _pop_random_location(empty_locations, rng)
    grid.append(CellData.MonsterBat.new(loc))
  for i in range(10):
    var loc = _pop_random_location(empty_locations, rng)
    grid.append(CellData.MonsterSkeleton.new(loc))
  for i in range(8):
    var loc = _pop_random_location(empty_locations, rng)
    grid.append(CellData.MonsterSlime.new(loc))
  for i in range(5):
    var loc = _pop_random_location(empty_locations, rng)
    grid.append(CellData.ScrollHealth.new(loc))

  # empty cells
  for loc in empty_locations:
    grid.append(CellData.EmptyCell.new(loc))

  grid.sort_custom(func(a, b): return a.location.y < b.location.y if a.location.x == b.location.x else a.location.x < b.location.x)
  validate_grid(grid)
  return grid


static func validate_grid(_grid: Array[CellData]) -> bool:
  # TODO validate grid
  # coordinates in order
  # monster counts
  # dragon in center
  # egg near dragon
  # engineer in corner
  # lovers mirrored
  # slime witch + purple slimes configuration
  # gargoyles face each other
  # rats face rat king (correct pointer)
  # one guardian per quadrant
  # minotaurs connected to chests (unique and nearby)
  # walls adjacent
  # scry orb far enough away from edges
  # not in scry: scry scroll, dragon, egg, engineer, witch+slimes, chest, rat king, mimic, gazer, mine
  return true