part of shared;


class Position extends Component {
  double x, y;
  Position(this.x, this.y);
}

class Renderable extends Component {
  String name;
  Renderable(this.name);
}