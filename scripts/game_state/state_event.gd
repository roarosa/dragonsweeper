@abstract
class_name StateEvent
extends RefCounted

class CellUpdatedEvent extends StateEvent:
  var location: Vector2i

  func _init(p_location: Vector2i):
    self.location = p_location

class HealthUpdatedEvent extends StateEvent:
  pass

class ExperienceUpdatedEvent extends StateEvent:
  pass

class GameLostEvent extends StateEvent:
  pass

class GameWonEvent extends StateEvent:
  pass