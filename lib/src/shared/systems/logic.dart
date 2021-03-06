part of shared;

class AccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;

  AccelerationSystem() : super(new Aspect.forAllOf([Acceleration, Velocity]));

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
  Mapper<Renderable> rm;

  MovementSystem() : super(new Aspect.forAllOf([Position, Velocity]));

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
        rm[entity].state = '';
      }
    }
    if (p.x < -64) {
      p.x = -64.0;
    }
  }
}

class GravitySystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;

  GravitySystem() : super(new Aspect.forAllOf([Acceleration]));

  @override
  void processEntity(Entity entity) {
    am[entity].y -= 9.81 * PIXEL_PER_METER;
  }
}

class DirectionSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Renderable> rm;

  DirectionSystem() : super(new Aspect.forAllOf([Acceleration, Renderable]));

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


class AiSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;
  Mapper<Position> pm;
  Mapper<Ai> aim;

  AiSystem()
      : super(new Aspect.forAllOf([Ai, Acceleration, Velocity, Position]));

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
      a.x = ai.acc * (v.x > 0.0 ? 1 : -1);
    }
  }
}

class DustSpawningSystem extends EntitySystem {
  TagManager tm;
  Mapper<Position> pm;

  bool spawn = false;
  double offsetX = 0.0;

  DustSpawningSystem() : super(new Aspect.empty());

  @override
  void processEntities(Iterable<Entity> entities) {
    var player = tm.getEntity(playerTag);
    var p = pm[player];
    for (int i = 0; i < 5; i++) {
      world.createAndAddEntity([
        new Renderable('dust_${random.nextInt(2)}',
            maxFrames: 4, timePerFrame: 0.05, facesRight: random.nextBool()),
        new Position(-32 + p.x + random.nextInt(64) + offsetX,
            p.y + 5 - random.nextInt(10)),
        new Lifetime(0.2)
      ]);
    }
    spawn = false;
  }

  @override
  bool checkProcessing() => spawn;
}

class LifetimeSystem extends EntityProcessingSystem {
  Mapper<Lifetime> lm;
  LifetimeSystem() : super(new Aspect.forAllOf([Lifetime]));

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
  Mapper<Renderable> rm;

  DelayedJumpSystem()
      : super(new Aspect.forAllOf([DelayedJump, Velocity, Renderable]));

  @override
  void processEntity(Entity entity) {
    var dj = djm[entity];

    dj.value -= world.delta;
    if (dj.value <= 0.0) {
      var v = vm[entity];
      var r = rm[entity];
      r.state = 'j';
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

class DeadMonsterRealityDistortionSystem extends EntityProcessingSystem {
  TagManager tm;
  Mapper<Position> pm;
  DeadMonsterRealityDistortionSystem()
      : super(new Aspect.forAllOf([DeadMonster, Position]));

  @override
  void processEntity(Entity entity) {
    var future = tm.getEntity(futureTag);

    var p = pm[entity];
    var fp = pm[future];

    if (fp.x < p.x - 150.0) {
      gameState.realityDistortion += 1.0;
      entity.deleteFromWorld();
    }
  }
}

class DeadMonsterAttackSystem extends EntityProcessingSystem {
  TagManager tm;
  Mapper<Position> pm;
  Mapper<Controller> cm;
  Mapper<Renderable> rm;
  Mapper<DeadMonster> dmm;
  var framesPerMonster = <int, int>{0: 4, 1: 4, 2: 6, 3: 1};

  DeadMonsterAttackSystem()
      : super(new Aspect.forAllOf([Position, DeadMonster]));

  @override
  void processEntity(Entity entity) {
    var player = tm.getEntity(playerTag);
    var p = pm[entity];
    var pp = pm[player];
    var r = rm[player];
    int spawn = 0;

    if (pp.y < 50.0) {
      var distance = p.x - pp.x;
      if (r.facesRight && distance > 32 && distance < 96) {
        spawn = 1;
      } else if (!r.facesRight && distance < -32 && distance > -96) {
        spawn = -1;
      }
      if (spawn != 0) {
        var monsterId = dmm[entity].id;
        if (monsterId == 3) {
          gameState.playing = false;
          gameState.beginning = true;
          r.state = '';
        }
        world.createAndAddEntity([
          new Position(p.x, 0.0),
          new Acceleration(),
          new Velocity(spawn.toDouble()),
          new Renderable('monster_${monsterId}',
              maxFrames: framesPerMonster[monsterId],
              timePerFrame: 0.8 / framesPerMonster[monsterId]),
          new Ai(
              p.x - 150 - random.nextInt(250),
              p.x + 150.0 + random.nextInt(250),
              dmm[entity].acc * PIXEL_PER_METER)
        ]);

        for (int i = 0; i < 20; i++) {
          world.createAndAddEntity([
            new Renderable('dust_${random.nextInt(2)}',
                maxFrames: 4,
                timePerFrame: 0.05,
                facesRight: random.nextBool()),
            new Position(
                -32 + p.x + random.nextInt(64), p.y + random.nextInt(64)),
            new Lifetime(0.2)
          ]);
        }
        entity.deleteFromWorld();
      }
    }
  }

  @override
  bool checkProcessing() =>
      Controller.maxAttackCooldown -
          cm[tm.getEntity(playerTag)].attackCooldown <
      0.1;
}

class AttackStopSystem extends EntityProcessingSystem {
  Mapper<Controller> cm;
  Mapper<Renderable> rm;
  AttackStopSystem() : super(new Aspect.forAllOf([Controller, Renderable]));

  @override
  void processEntity(Entity entity) {
    var c = cm[entity];
    var r = rm[entity];
    if (c.attackCooldown < 0.05 && r.state == 'a') {
      r.state = '';
    }
  }
}
