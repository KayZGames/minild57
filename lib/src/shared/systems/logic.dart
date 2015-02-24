part of shared;


class AccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;

  AccelerationSystem() : super(Aspect.getAspectForAllOf([Acceleration, Velocity]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var v = vm[entity];

    v.x = v.x * 0.9 + a.x * world.delta;
    v.y += a.y * world.delta;

    a.x = 0.0;
    a.y = 0.0;
  }
}

class MovementSystem extends EntityProcessingSystem {
  Mapper<Velocity> vm;
  Mapper<Position> pm;

  MovementSystem() : super(Aspect.getAspectForAllOf([Position, Velocity]));

  @override
  void processEntity(Entity entity) {
    var v = vm[entity];
    var p = pm[entity];

    var oldPy = p.y;
    p.x += v.x * world.delta;
    p.y += v.y * world.delta;

    if (p.y <= 0.0) {
      p.y = 0.0;
      v.y = 0.0;
      if (oldPy > 0.0) {
        world.createAndAddEntity([new Sound('jump')]);
      }
    }
  }
}

class GravitySystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;

  GravitySystem() : super(Aspect.getAspectForAllOf([Acceleration]));

  @override
  void processEntity(Entity entity) {
    am[entity].y -= 9.81 * PIXEL_PER_METER;
  }
}

class DirectionSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Renderable> rm;

  DirectionSystem() : super(Aspect.getAspectForAllOf([Acceleration, Renderable]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var r = rm[entity];

    if (a.x > 0.0) {
      r.facesRight = false;
    } else if (a.x < 0.0) {
      r.facesRight = true;
    }
  }
}

class AnimationSystem extends EntityProcessingSystem {
  Mapper<Renderable> rm;

  AnimationSystem() : super(Aspect.getAspectForAllOf([Renderable]));

  @override
  void processEntity(Entity entity) {
    var r = rm[entity];

    r.time += world.delta;
  }
}

class AiSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;
  Mapper<Position> pm;
  Mapper<Ai> aim;

  AiSystem() : super(Aspect.getAspectForAllOf([Ai, Acceleration, Velocity, Position]));


  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var v = vm[entity];
    var p = pm[entity];
    var ai = aim[entity];

    if (p.x > ai.xMax) {
      a.x = -ai.acc;
    } else if (p.x < ai.xMin) {
      a.x = ai.acc;
    } else if (v.x == 0.0) {
      a.x = ai.acc;
    } else {
      a.x = ai.acc * FastMath.signum(v.x);
    }
  }
}

class DustSpawningSystem extends EntitySystem {
  TagManager tm;
  Mapper<Position> pm;

  bool spawn = false;
  double offsetX = 0.0;

  DustSpawningSystem() : super(Aspect.getEmpty());

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    for (int i = 0; i < 5; i++) {
      world.createAndAddEntity(
          [
              new Renderable('dust_${random.nextInt(2)}', 4, 0.05, random.nextBool()),
              new Position(-32 + p.x + random.nextInt(64) + offsetX, p.y + 5 - random.nextInt(10)),
              new Lifetime(0.2)]);
    }
    spawn = false;
  }

  @override
  bool checkProcessing() => spawn;
}


class LifetimeSystem extends EntityProcessingSystem {
  Mapper<Lifetime> lm;
  LifetimeSystem() : super(Aspect.getAspectForAllOf([Lifetime]));

  @override
  void processEntity(Entity entity) {
    var l = lm[entity];
    l.value -= world.delta;
    if (l.value <= 0.0) {
      entity.deleteFromWorld();
    }
  }
}

class DelayedJumpSystem extends EntityProcessingSystem {
  Mapper<Velocity> vm;
  Mapper<DelayedJump> djm;

  DelayedJumpSystem() : super(Aspect.getAspectForAllOf([DelayedJump, Velocity]));

  @override
  void processEntity(Entity entity) {
    var dj = djm[entity];

    dj.value -= world.delta;
    if (dj.value <= 0.0) {
      var v = vm[entity];
      v.y = 6.0 * PIXEL_PER_METER;
      entity
          ..removeComponent(DelayedJump)
          ..changedInWorld();
      world.createAndAddEntity([new Sound('jump_landing')]);
    }
  }
}

class RealityDistortionSystem extends VoidEntitySystem {
  TagManager tm;

  Mapper<Position> pm;

  @override
  void processSystem() {
    var player = tm.getEntity(playerTag);
    var future = tm.getEntity(futureTag);

    var pp = pm[player];
    var fp = pm[future];

    if (fp.x < pp.x) {
      gameState.realityDistortion += world.delta;
    }
  }
}