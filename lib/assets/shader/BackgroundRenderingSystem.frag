precision mediump float;

uniform float uPlayerY;

varying vec2 vPosition;

void main() {
	gl_FragColor = vec4(-uPlayerY + 0.3 - vPosition.y, -uPlayerY + 0.15 - vPosition.y, 0.1 + (uPlayerY + 1.0 + vPosition.y) / 2.0, 1.0);
	// gl_FragColor = vec4(vPosition.y + uPlayerY, 0.0, 0.0, 1.0);
}