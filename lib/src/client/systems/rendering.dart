part of client;

Matrix4 createViewMatrix() {
  var viewMatrix = new Matrix4.identity();
  setOrthographicMatrix(viewMatrix, 0, 800, -100, 500, 1, -1);
  return viewMatrix;
}

class SpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;
  Mapper<Renderable> rm;

  SpriteSheet sheet;

  Float32List positions;
  Float32List texCoords;

  SpriteRenderingSystem(RenderingContext gl, this.sheet) : super(gl, Aspect.getAspectForAllOf([Position, Renderable]));

  @override
  void initialize() {
    super.initialize();

    var texture = gl.createTexture();
    var uTexture = gl.getUniformLocation(program, 'uTexture');

    gl..useProgram(program)
      ..pixelStorei(UNPACK_FLIP_Y_WEBGL, 0)
      ..activeTexture(TEXTURE0)
      ..bindTexture(TEXTURE_2D, texture)
      ..texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, LINEAR)
      ..texImage2DImage(TEXTURE_2D, 0, RGB, RGB, UNSIGNED_BYTE, sheet.image)
      ..uniform1i(uTexture, 0)
      ..uniform2f(gl.getUniformLocation(program, 'uSize'), sheet.image.width, sheet.image.height);
  }

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];
    var r = rm[entity];
    var dst = sheet.sprites[r.name].dst;
    var src = sheet.sprites[r.name].src;
    var width = sheet.image.width;
    var height = sheet.image.height;

    positions[index * 8] = p.x - dst.width / 2;
    positions[index * 8 + 1] = p.y;
    positions[index * 8 + 2] = p.x + dst.width / 2;
    positions[index * 8 + 3] = p.y;
    positions[index * 8 + 4] = p.x - dst.width / 2;
    positions[index * 8 + 5] = p.y + dst.height;
    positions[index * 8 + 6] = p.x + dst.width / 2;
    positions[index * 8 + 7] = p.y + dst.height;

    var right;
    var left;
    if (r.facesRight) {
      left = src.left.toDouble();
      right = src.right.toDouble();
    } else {
      right = src.left.toDouble();
      left = src.right.toDouble();
    }
    var bottom = src.bottom.toDouble();
    var top = src.top.toDouble();
    texCoords[index * 8] = left;
    texCoords[index * 8 + 1] = bottom;
    texCoords[index * 8 + 2] = right;
    texCoords[index * 8 + 3] = bottom;
    texCoords[index * 8 + 4] = left;
    texCoords[index * 8 + 5] = top;
    texCoords[index * 8 + 6] = right;
    texCoords[index * 8 + 7] = top;
  }

  @override
  void render(int length) {
    buffer('aPosition', positions, 2);
    buffer('aTexCoord', texCoords, 2);

    var uViewMatrix = gl.getUniformLocation(program, 'uViewMatrix');
    gl.uniformMatrix4fv(uViewMatrix, false, createViewMatrix().storage);

    gl.drawArrays(RenderingContext.TRIANGLE_STRIP, 0, length * 4);
  }

  @override
  void updateLength(int length) {
    positions = new Float32List(length * 2 * 4);
    texCoords = new Float32List(length * 2 * 4);
  }

  @override
  String get vShaderFile => 'SpriteRenderingSystem';

  @override
  String get fShaderFile => 'SpriteRenderingSystem';
}
