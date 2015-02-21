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
  String name;
  bool facesRight;
  Renderable(this.name, [this.facesRight = true]);
}

class Controller extends Component {}