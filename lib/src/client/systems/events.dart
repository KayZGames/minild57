part of client;


class InputHandlingSystem extends GenericInputHandlingSystem {
  DustSpawningSystem dss;
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;
  Mapper<Position> pm;
  Mapper<DelayedJump> djm;
  Mapper<Controller> cm;

  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Controller, Position, Velocity]));


  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];
    var a = am[entity];
    var c = cm[entity];
    if (p.y <= 10.0 && v.y == 0.0) {
      if (jump && !djm.has(entity)) {
        entity..addComponent(new DelayedJump(0.15))
              ..changedInWorld();
        dss.spawn = true;
        dss.offsetX = v.x * 8 * world.delta;
      }
    }
    if (left) {
      a.x = 20.0 * PIXEL_PER_METER;
    }
    if (right) {
      a.x = -20.0 * PIXEL_PER_METER;
    }
    if (c.attackCooldown > 0.0) {
      c.attackCooldown -= world.delta;
    } else if (attack) {
      c.attackCooldown = Controller.maxAttackCooldown;
    }
  }

  bool get left => keyState[KeyCode.A] == true || keyState[KeyCode.LEFT] == true;
  bool get right => keyState[KeyCode.D] == true || keyState[KeyCode.RIGHT] == true;
  bool get attack => keyState[KeyCode.J] == true || keyState[KeyCode.X] == true;
  bool get jump => keyState[KeyCode.K] == true || keyState[KeyCode.C] == true;

  @override
  bool checkProcessing() => gameState.playing;
}