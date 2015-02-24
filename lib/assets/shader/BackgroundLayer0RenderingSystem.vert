attribute vec4 aPosition;

varying vec2 vPosition;

void main() {
  gl_Position = aPosition;
  vPosition = aPosition.xy;
}