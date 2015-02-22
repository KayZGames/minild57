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
  int maxFrames;
  double timePerFrame;
  double time;
  bool facesRight;
  Renderable(this._name, [this.maxFrames = 1, this.timePerFrame = 0.2, this.facesRight = true, this.time = 0.0]);

  String get name => '${_name}_${maxFrames - (time / timePerFrame % maxFrames).toInt() - 1}';
}

class Controller extends Component {}

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