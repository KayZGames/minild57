part of client;

Matrix4 createViewMatrix(TagManager tm, Mapper<Position> pm, Mapper<Velocity> vm) {
  var e = tm.getEntity(playerTag);
  var p = pm[e];
  var v = vm[e];
  var offsetX = -v.x / 8.0;
  var viewMatrix = new Matrix4.identity();
  setOrthographicMatrix(
      viewMatrix,
      p.x - 400.0 + offsetX,
      p.x + 400 + offsetX,
      p.y - 128.0,
      p.y + 472.0,
      1,
      -1);
  return viewMatrix;
}

class SpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Velocity> vm;
  Mapper<Renderable> rm;
  TagManager tm;

  SpriteSheet sheet;

  List<Attrib> attributes = [const Attrib('aPosition', 2), const Attrib('aTexCoord', 2)];
  Float32List values;
  Uint16List indices;

  SpriteRenderingSystem(RenderingContext gl, this.sheet) : super(gl, Aspect.getAspectForAllOf([Position, Renderable]));

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
    var p = pm[entity];
    var r = rm[entity];
    var dst = sheet.sprites[r.name].dst;
    var src = sheet.sprites[r.name].src;
    double right;
    double left;
    if (r.facesRight) {
      left = src.left.toDouble() + 1.0;
      right = src.right.toDouble() - 1.0;
    } else {
      right = src.left.toDouble() + 1.0;
      left = src.right.toDouble() - 1.0;
    }
    var bottom = src.bottom.toDouble();
    var top = src.top.toDouble();

    values[index * 16] = p.x - dst.width / 2;
    values[index * 16 + 1] = p.y;
    values[index * 16 + 2] = left;
    values[index * 16 + 3] = bottom;

    values[index * 16 + 4] = p.x + dst.width / 2;
    values[index * 16 + 5] = p.y;
    values[index * 16 + 6] = right;
    values[index * 16 + 7] = bottom;

    values[index * 16 + 8] = p.x - dst.width / 2;
    values[index * 16 + 9] = p.y + dst.height;
    values[index * 16 + 10] = left;
    values[index * 16 + 11] = top;

    values[index * 16 + 12] = p.x + dst.width / 2;
    values[index * 16 + 13] = p.y + dst.height;
    values[index * 16 + 14] = right;
    values[index * 16 + 15] = top;

    indices[index * 6] = index * 4;
    indices[index * 6 + 1] = index * 4 + 2;
    indices[index * 6 + 2] = index * 4 + 3;
    indices[index * 6 + 3] = index * 4;
    indices[index * 6 + 4] = index * 4 + 3;
    indices[index * 6 + 5] = index * 4 + 1;
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
