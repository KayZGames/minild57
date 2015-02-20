part of client;


class SpriteRenderingSystem extends WebGlRenderingSystem {
  Mapper<Position> pm;

  Float32List aPosition;

  SpriteRenderingSystem(RenderingContext gl) : super(gl, Aspect.getAspectForAllOf([Position]));

  @override
  void processEntity(int index, Entity entity) {
    var p = pm[entity];

    aPosition[index * 8] = p.x - 0.2;
    aPosition[index * 8 + 1] = p.y - 0.2;
    aPosition[index * 8 + 2] = p.x + 0.2;
    aPosition[index * 8 + 3] = p.y - 0.2;
    aPosition[index * 8 + 4] = p.x - 0.2;
    aPosition[index * 8 + 5] = p.y + 0.2;
    aPosition[index * 8 + 6] = p.x + 0.2;
    aPosition[index * 8 + 7] = p.y + 0.2;
  }

  @override
  void render(int length) {
    buffer('aPosition', aPosition, 2);

    gl.drawArrays(RenderingContext.TRIANGLE_STRIP, 0, length * 4);
  }

  @override
  void updateLength(int length) {
    aPosition = new Float32List(length * 2 * 4);
  }

  @override
  String get vShaderFile => 'SpriteRenderingSystem';

  @override
  String get fShaderFile => 'SpriteRenderingSystem';
}
