precision mediump float;

uniform vec2 uPlayerPos;
uniform float uTime;

varying vec2 vPosition;

float rand(vec2 co){
    return sin(dot(co.xy ,vec2(12.9898,78.233)));
}

void main() {
	float y = vPosition.y + uPlayerPos.y;
	float x1 = sin(1.7 + 0.05 * (uPlayerPos.x + 1.6 * vPosition.x)) / 1.1;
	float x2 = sin(2.5 + 0.05 * (uPlayerPos.x + 1.3 * vPosition.x)) / 1.3;
	float x3 = sin(0.05 * (uPlayerPos.x + vPosition.x)) / 1.5;
	float posMod1 = cos(uPlayerPos.x + 1.6 * vPosition.x) / 4.0;
	float posMod2 = sin(uPlayerPos.x + 1.3 * vPosition.x) / 4.5;
	float posMod3 = sin(uPlayerPos.x + vPosition.x) / 5.0;
	float height1 = rand(vec2(x1 * 0.5, x1 * 0.5)) * (0.15 + posMod1) - 0.1;
	float height2 = rand(vec2(x2 * 0.6, x2 * 0.6)) * (0.2 + posMod2) - 0.15;
	float height3 = rand(vec2(x3 * 0.8, x3 * 0.6)) * (0.25 + posMod3) - 0.25;
	if (y < height3 + 0.1 * uPlayerPos.y) {
		float something = height3/2.0 + (2.0 + y) / 4.0;
		gl_FragColor = vec4(something / 1.2, something / 1.1, something / 1.5, 1.0);
	} else if (y < height2 + 0.2 * uPlayerPos.y) {
		float something = height2/2.0 + (1.0 + y) / 1.2;
		gl_FragColor = vec4(something / 1.5, something / 1.25, something / 1.5, 1.0);
	} else if (y < height1 + 0.3 * uPlayerPos.y) {
		float something = height1/2.0 + (1.0 + y) / 0.9;
		gl_FragColor = vec4(0.2 + something/4.0, something / 8.0, something / 40.0, 1.0);
	} else {
		discard;
	}

	
}