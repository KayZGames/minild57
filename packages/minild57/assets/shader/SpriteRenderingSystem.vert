attribute vec4 aPosition;

uniform mat4 uViewMatrix;

attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
  gl_Position = uViewMatrix * aPosition;
  vTexCoord = aTexCoord;
}