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
  int frame;
  int maxFrames;
  bool facesRight;
  Renderable(this._name, [this.frame = 0, this.maxFrames = 1, this.facesRight = true]);

  String get name => '${_name}_${frame}';
}

class Controller extends Component {}

class Ai extends Component {
  double xMin, xMax, acc;
  Ai(this.xMin, this.xMax, this.acc);
}