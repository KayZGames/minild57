part of shared;

class Velocity extends Component {
  double x, y;
  Velocity([this.x = 0.0, this.y = 0.0]);
}

class Acceleration extends Component {
  double x, y;
  Acceleration([this.x = 0.0, this.y = 0.0]);
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
