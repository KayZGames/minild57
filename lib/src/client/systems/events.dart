part of client;


class InputHandlingSystem extends GenericInputHandlingSystem {
  Mapper<Acceleration> am;
  Mapper<Velocity> vm;
  Mapper<Position> pm;

  InputHandlingSystem() : super(Aspect.getAspectForAllOf([Controller, Position, Velocity]));


  @override
  void processEntity(Entity entity) {
    var p = pm[entity];
    var v = vm[entity];
    if (p.y <= 10.0 && v.y >= 0.0) {
      var a = am[entity];
      if (keyState[KeyCode.S] == true) {
        v.y = 6.0 * PIXEL_PER_METER;
      }
      if (keyState[KeyCode.A] == true) {
        a.x = 20.0 * PIXEL_PER_METER;
      }
      if (keyState[KeyCode.D] == true) {
        a.x = -20.0 * PIXEL_PER_METER;
      }
    }
  }
}