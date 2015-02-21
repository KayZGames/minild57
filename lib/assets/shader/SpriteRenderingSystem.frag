precision mediump float;

uniform sampler2D uSheet;
uniform vec2 uSize;
varying vec2 vTexCoord;

void main() {
  gl_FragColor = texture2D(uSheet, vTexCoord / uSize);
}