part of client;

Matrix4 createViewMatrix(TagManager tm, Mapper<Position> pm, Mapper<Velocity> vm) {
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
      1,
      -1);
  return viewMatrix;
}

abstract class WebGlSpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Velocity> vm;
  Mapper<Renderable> rm;
  TagManager tm;

  SpriteSheet sheet;

  List<Attrib> attributes = [const Attrib('aPosition', 2), const Attrib('aTexCoord', 2)];
  Float32List values;
  Uint16List indices;

  WebGlSpriteRenderingSystem(RenderingContext gl, this.sheet, Aspect aspect) : super(gl, aspect);

  @override
  void initialize() {
    super.initialize();

    var texture = gl.createTexture();
    var uTexture = gl.getUniformLocation(program, 'uTexture');

    gl
        ..useProgram(program)
        ..pixelStorei(UNPACK_FLIP_Y_WEBGL, 0)
        ..activeTexture(TEXTURE0)
        ..bindTexture(TEXTURE_2D, texture)
        ..texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR)
        ..texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE)
        ..texImage2DImage(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, sheet.image)
        ..uniform1i(uTexture, 0)
        ..uniform2f(gl.getUniformLocation(program, 'uSize'), sheet.image.width, sheet.image.height);
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = getPosition(entity);
    var r = rm[entity];
    var sprite = sheet.sprites[r.name];
    var dst = sprite.dst;
    var src = sprite.src;
    var size = sprite.sourceSize;
    double right;
    double left;
    int dstLeft;
    int dstRight;
    if (r.facesRight) {
      left = src.left.toDouble() + 1.0;
      right = src.right.toDouble() - 1.0;
      dstLeft = dst.left;
      dstRight = dst.right;
    } else {
      right = src.left.toDouble() + 1.0;
      left = src.right.toDouble() - 1.0;
      dstLeft = -dst.right;
      dstRight = -dst.left;
    }
    var bottom = src.bottom.toDouble();
    var top = src.top.toDouble();

    values[index * 16] = p.x + dstLeft;
    values[index * 16 + 1] = p.y - dst.bottom;
    values[index * 16 + 2] = left;
    values[index * 16 + 3] = bottom;

    values[index * 16 + 4] = p.x + dstRight;
    values[index * 16 + 5] = p.y - dst.bottom;
    values[index * 16 + 6] = right;
    values[index * 16 + 7] = bottom;

    values[index * 16 + 8] = p.x + dstLeft;
    values[index * 16 + 9] = p.y - dst.top;
    values[index * 16 + 10] = left;
    values[index * 16 + 11] = top;

    values[index * 16 + 12] = p.x + dstRight;
    values[index * 16 + 13] = p.y - dst.top;
    values[index * 16 + 14] = right;
    values[index * 16 + 15] = top;

    indices[index * 6] = index * 4;
    indices[index * 6 + 1] = index * 4 + 2;
    indices[index * 6 + 2] = index * 4 + 3;
    indices[index * 6 + 3] = index * 4;
    indices[index * 6 + 4] = index * 4 + 3;
    indices[index * 6 + 5] = index * 4 + 1;
  }

  Position getPosition(Entity entity) {
    return pm[entity];
  }

  @override
  void render(int length) {
    bufferElements(attributes, values, indices);

    var uViewMatrix = gl.getUniformLocation(program, 'uViewMatrix');
    gl.uniformMatrix4fv(uViewMatrix, false, createViewMatrix(tm, pm, vm).storage);

    gl.drawElements(TRIANGLES, length * 6, UNSIGNED_SHORT, 0);
  }

  @override
  void updateLength(int length) {
    values = new Float32List(length * 4 * 2 * 2);
    indices = new Uint16List(length * 6);
  }

  @override
  String get vShaderFile => 'SpriteRenderingSystem';

  @override
  String get fShaderFile => 'SpriteRenderingSystem';
}

class SpriteRenderingSystem extends WebGlSpriteRenderingSystem {
  SpriteRenderingSystem(RenderingContext gl, SpriteSheet sheet)
      : super(gl, sheet, Aspect.getAspectForAllOf([Position, Renderable]).exclude([Controller]));
}

class PlayerRenderingSystem extends WebGlSpriteRenderingSystem {
  PlayerRenderingSystem(RenderingContext gl, SpriteSheet sheet)
      : super(gl, sheet, Aspect.getAspectForAllOf([Position, Renderable, Controller]));
}

class EquipmentRenderingSystem extends WebGlSpriteRenderingSystem {
  EquipmentRenderingSystem(RenderingContext gl, SpriteSheet sheet)
      : super(gl, sheet, Aspect.getAspectForAllOf([Equipment, Renderable]));

  @override
  Position getPosition(Entity entity) {
    var player = tm.getEntity(playerTag);
    rm[entity].facesRight = rm[player].facesRight;
    return pm[player];
  }
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
    positions = new Float32List.fromList([-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]);
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
        new Float32List.fromList([(playerPos.x - playerVel.x / 8) / 400.0, playerPos.y / 300.0]));
    gl.uniform1f(gl.getUniformLocation(program, 'uTime'), world.time);
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
        new Float32List.fromList([(playerPos.x - playerVel.x / 8) / 400.0, playerPos.y / 300.0]));
    gl.uniform1f(gl.getUniformLocation(program, 'uTime'), world.time);
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
      100];


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
