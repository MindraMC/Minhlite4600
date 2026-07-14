#version 120

uniform sampler2D texture;

varying vec2 vTexCoord;
varying vec4 vColor;

void main() {
    // Full-bright emissive eyes (spider/enderman eye-like passes).
    vec4 c = texture2D(texture, vTexCoord) * vColor;
    vec3 boosted = c.rgb * 1.6;
    gl_FragData[0] = vec4(clamp(boosted, 0.0, 1.0), c.a);
}
