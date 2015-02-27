part of shared;


class Position extends Component {
  double x, y;
  Position(this.x, this.y);
}

class Velocity extends Component {
  double x, y;
  Velocity([this.x = 0.0, this.y = 0.0]);
}

class Acceleration extends Component {
  double x, y;
  Acceleration([this.x = 0.0, this.y = 0.0]);
}

class Renderable extends Component {
  String _name;
  String _state;
  int maxFrames;
  double timePerFrame;
  double time;
  bool facesRight;
  Renderable(this._name, [this.maxFrames = 1, this.timePerFrame = 0.2, this.facesRight = true, this.time = 0.0, this._state = '']);

  String get name => '${_name}_$state${maxFrames - (time / timePerFrame % maxFrames).toInt() - 1}';
  String get state => _state;
  void set state(String value) {
    if (value != _state) {
      time = 0.0;
      if (value == 'a') {
        maxFrames = 2;
      } else {
        maxFrames = 1;
      }
    }
    _state = value;
  }
}

class Controller extends Component {
  static const double maxAttackCooldown = 0.4;
  double attackCooldown;
  Controller([this.attackCooldown = 0.0]);
}

class Ai extends Component {
  double xMin, xMax, acc;
  Ai(this.xMin, this.xMax, this.acc);
}

class Lifetime extends Component {
  double value;
  Lifetime(this.value);
}

class DelayedJump extends Component {
  double value;
  DelayedJump(this.value);
}

class Equipment extends Component {}

class DeadMonster extends Component {
  int id;
  double acc;
  DeadMonster(this.id, [this.acc = 10.0]);
}