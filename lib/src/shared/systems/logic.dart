part of shared;


class AccelerationSystem extends EntityProcessingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;

  AccelerationSystem() : super(Aspect.getAspectForAllOf([Acceleration, Velocity]));

  @override
  void processEntity(Entity entity) {
    var a = am[entity];
    var v = vm[entity];

    v.x += a.x * world.delta;
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

    p.x += v.x * world.delta;
    p.y += v.y * world.delta;

    if (p.y <= 0.0) {
      p.y = 0.0;
      v.y = 0.0;
      v.x *= 0.9;
    } else {
      var airDragMod = v.x.abs() / 1200.0;
      v.x *= (1.0 - airDragMod * airDragMod * airDragMod) * 1.02;
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

    r.frame = (r.maxFrames - 5 * world.time % r.maxFrames).toInt();
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