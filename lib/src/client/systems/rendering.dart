part of client;

Matrix4 createViewMatrix(
    TagManager tm, Mapper<Position> pm, Mapper<Velocity> vm) {
  var e = tm.getEntity(playerTag);
  var p = pm[e];
  var v = vm[e];
  var offsetX = -v.x / 8.0;
  var viewMatrix = new Matrix4.identity();
  var nextDouble = random.nextDouble();
  setOrthographicMatrix(
      viewMatrix,
      p.x - 400.0 + offsetX + nextDouble * gameState.realityDistortion,
      p.x + 400 + offsetX - nextDouble * gameState.realityDistortion,
      p.y - 128.0 + nextDouble * gameState.realityDistortion,
      p.y + 472.0 - nextDouble * gameState.realityDistortion,
      1.0,
      -1.0);
  return viewMatrix;
}

class SpriteRenderingSystem extends WebGlSpriteRenderingSystem {
  Mapper<Velocity> vm;

  SpriteRenderingSystem(RenderingContext gl, SpriteSheet sheet)
      : super(gl, sheet,
            new Aspect.forAllOf([Position])..exclude([Controller]));

  @override
  Matrix4 create2dViewProjectionMatrix() => createViewMatrix(tm, pm, vm);
}

class PlayerRenderingSystem extends WebGlSpriteRenderingSystem {
  Mapper<Velocity> vm;

  PlayerRenderingSystem(RenderingContext gl, SpriteSheet sheet)
      : super(
            gl, sheet, new Aspect.forAllOf([Position, Controller]));

  @override
  Matrix4 create2dViewProjectionMatrix() => createViewMatrix(tm, pm, vm);
}

class EquipmentRenderingSystem extends WebGlSpriteRenderingSystem {
  Mapper<Velocity> vm;

  EquipmentRenderingSystem(RenderingContext gl, SpriteSheet sheet)
      : super(gl, sheet, new Aspect.forAllOf([Equipment]));

  @override
  Position getPosition(Entity entity) {
    var player = tm.getEntity(playerTag);
    rm[entity].facesRight = rm[player].facesRight;
    rm[entity].state = rm[player].state;
    return pm[player];
  }

  @override
  Matrix4 create2dViewProjectionMatrix() => createViewMatrix(tm, pm, vm);
}

abstract class VoidFullScreenRenderingSystem extends VoidWebGlRenderingSystem {
  TagManager tm;
  Mapper<Position> pm;
  Mapper<Velocity> vm;

  Float32List positions;

  VoidFullScreenRenderingSystem(RenderingContext gl) : super(gl);

  @override
  void initialize() {
    super.initialize();
    positions =
        new Float32List.fromList([-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]);
  }

  @override
  void render() {
    updateCustomVars();

    buffer('aPosition', positions, 2, usage: STATIC_DRAW);
    gl.drawArrays(TRIANGLE_STRIP, 0, 4);
  }

  void updateCustomVars();
}

class BackgroundRenderingSystem extends VoidFullScreenRenderingSystem {
  BackgroundRenderingSystem(RenderingContext gl) : super(gl);

  @override
  void updateCustomVars() {
    var y = pm[tm.getEntity(playerTag)].y / 300;
    gl.uniform1f(gl.getUniformLocation(program, 'uPlayerY'), y);
  }

  @override
  String get vShaderFile => 'BackgroundRenderingSystem';

  @override
  String get fShaderFile => 'BackgroundRenderingSystem';
}

class FutureRenderingSystem extends VoidFullScreenRenderingSystem {
  FutureRenderingSystem(RenderingContext gl) : super(gl);

  @override
  void updateCustomVars() {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    var playerVel = vm[player];
    var futureX = pm[tm.getEntity(futureTag)].x;

    gl.uniform1f(gl.getUniformLocation(program, 'uFutureX'), futureX / 400.0);
    gl.uniform2fv(
        gl.getUniformLocation(program, 'uPlayer'),
        new Float32List.fromList(
            [(playerPos.x - playerVel.x / 8) / 400.0, playerPos.y / 300.0]));
    gl.uniform1f(gl.getUniformLocation(program, 'uTime'), time);
  }

  @override
  String get vShaderFile => 'FutureRenderingSystem';

  @override
  String get fShaderFile => 'FutureRenderingSystem';
}

class BackgroundLayer0RenderingSystem extends VoidFullScreenRenderingSystem {
  BackgroundLayer0RenderingSystem(RenderingContext gl) : super(gl);

  @override
  void updateCustomVars() {
    var player = tm.getEntity(playerTag);
    var playerPos = pm[player];
    var playerVel = vm[player];

    gl.uniform2fv(
        gl.getUniformLocation(program, 'uPlayerPos'),
        new Float32List.fromList(
            [(playerPos.x - playerVel.x / 8) / 400.0, playerPos.y / 300.0]));
    gl.uniform1f(gl.getUniformLocation(program, 'uTime'), time);
  }

  @override
  String get vShaderFile => 'BackgroundLayer0RenderingSystem';

  @override
  String get fShaderFile => 'BackgroundLayer0RenderingSystem';
}

class HudRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;

  HudRenderingSystem(this.ctx);

  @override
  void processSystem() {
    var text = 'R E A L I T Y   D I S T O R T I O N';
    var width = ctx.measureText(text).width;
    ctx
      ..strokeStyle = 'white'
      ..fillStyle = 'red'
      ..fillRect(50, 40, gameState.realityDistortion * 60, 20)
      ..strokeRect(50, 40, 700, 20)
      ..fillStyle = 'cyan'
      ..fillText(text, 400 - width / 2, 42);
  }
}

class EndingScreenRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  double time = 0.0;
  double startY = -700.0;

  List texts = [
    'Congratulations!',
    90,
    '',
    200,
    '',
    200,
    'You have killed all the monsters in the world.',
    30,
    '',
    30,
    'But you made a mistake. You killed Her.',
    30,
    'Without Her there can be no life.',
    30,
    'The world is doomed.',
    30,
    'You will be remembered as the Destroyer of Worlds.',
    30,
    'Because it was you, who killed the Goat of Life.',
    30,
    '',
    30,
    'It will never be possible to undo this mistake.',
    30,
    '',
    200,
    '',
    200,
    '',
    200,
    'The End',
    100
  ];

  EndingScreenRenderingSystem(this.ctx);

  @override
  void processSystem() {
    var ratio = time / 30;
    ctx
      ..save()
      ..globalAlpha = (1 - ratio * ratio * ratio * ratio)
      ..fillStyle = 'black'
      ..clearRect(0, 0, 800, 600)
      ..fillRect(0, 0, 800, 600)
      ..fillStyle = 'white';
    for (int i = 0; i < texts.length; i += 2) {
      var text = texts[i] as String;
      var height = texts[i + 1] as int;
      ctx.font = '${height}px Verdana';
      var width = ctx.measureText(text).width;
      ctx.fillText(text, 400 - width / 2, startY + i * 20 + time * 40);
    }
    ctx.restore();

    time += world.delta;
    if (time >= 30) {
      gameState.playing = true;
    }
  }

  @override
  bool checkProcessing() => time < 30;
}

class BeginningScreenRenderingSystem extends VoidEntitySystem {
  CanvasRenderingContext2D ctx;
  double time = 0.0;

  BeginningScreenRenderingSystem(this.ctx);

  @override
  void processSystem() {
    var ratio = time / 10;
    var text = 'Press Start';
    ctx
      ..save()
      ..globalAlpha = ratio * ratio * ratio * ratio
      ..fillStyle = 'black'
      ..clearRect(0, 0, 800, 600)
      ..fillRect(0, 0, 800, 600)
      ..fillStyle = 'white';
    ctx.font = '50px Verdana';
    var width = ctx.measureText(text).width;
    ctx.fillText(text, 400 - width / 2, 275);
    ctx.restore();

    time += world.delta;
  }

  @override
  bool checkProcessing() => gameState.beginning;
}
