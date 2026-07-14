#version 120

#extension GL_ARB_shadow : enable
#extension GL_EXT_shadow_samplers : enable

uniform sampler2D texture;
uniform sampler2DShadow shadowtex0;

varying vec2 vTexCoord;
varying vec4 vColor;
varying vec4 vShadowCoord;

const float SHADOW_BIAS = 0.00110;

float sampleShadow(vec4 shadowCoord) {
    vec3 shadowNdc = shadowCoord.xyz / max(shadowCoord.w, 0.00001);
    vec3 shadowUv = shadowNdc * 0.5 + 0.5;

    if (shadowUv.x < 0.0 || shadowUv.x > 1.0 || shadowUv.y < 0.0 || shadowUv.y > 1.0 || shadowUv.z < 0.0 || shadowUv.z > 1.0) {
        return 1.0;
    }

    return shadow2D(shadowtex0, vec3(shadowUv.xy, shadowUv.z - SHADOW_BIAS)).r;
}

void main() {
    vec4 base = texture2D(texture, vTexCoord) * vColor;
    float visibility = sampleShadow(vShadowCoord);

    float shadowAmount = 1.0 - visibility;
    float light = mix(1.0, 0.84, shadowAmount);

    // Soft glow: boost cyan/blue-rich water tones without blowing highlights.
    float blueWeight = clamp(base.b - base.r * 0.35, 0.0, 1.0);
    vec3 glowTint = vec3(0.06, 0.16, 0.24) * blueWeight;
    vec3 lit = base.rgb * light;
    vec3 color = lit + glowTint;
    // Increase water contrast around mid-tones.
    color = (color - 0.5) * 1.22 + 0.5;

    gl_FragData[0] = vec4(clamp(color, 0.0, 1.0), base.a);
}
