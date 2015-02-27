precision mediump float;

uniform float uFutureX;
uniform vec2 uPlayer;
uniform float uTime;

varying vec2 vPosition;

float rand(vec2 co){
    return sin(dot(co.xy ,vec2(12.9898,78.233)));
}

void main() {
	float weight = (sin(uTime / 2.0) + 1.0) / 2.0;
	float random1 = rand(vec2(vPosition.x + uPlayer.x, 0.0)) * rand(vec2(vPosition.y + uPlayer.y, 0.0)) * 0.125 * weight;
	float random2 = rand(vec2(vPosition.y + uPlayer.y, uTime / 10.0)) * rand(vec2(uFutureX, vPosition.x + uPlayer.x)) * 0.125 * (1.0 - weight);
	float posX = vPosition.x + random1 + random2;
	float borderX = uFutureX - uPlayer.x;
	if (posX > borderX) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, (posX - borderX) * (3.0 - random1 + random2));
	} else if (posX + 0.1 > borderX) {
		gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0 - 15.0 * (borderX - posX));
	} else {
		discard;
	}
}