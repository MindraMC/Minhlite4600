#version 120

#extension GL_ARB_shadow : enable
#extension GL_EXT_shadow_samplers : enable

uniform sampler2D texture;
uniform sampler2DShadow shadowtex0;

varying vec2 vTexCoord;
varying vec4 vColor;
varying vec4 vShadowCoord;

const float SHADOW_BIAS_BASE = 0.0010;
const float SHADOW_TEXEL = 1.0 / 16384.0;

float cmpShadow(vec2 uv, float depth, float bias) {
    return shadow2D(shadowtex0, vec3(uv, depth - bias)).r;
}

float sampleShadow(vec4 shadowCoord) {
    vec3 ndc = shadowCoord.xyz / max(shadowCoord.w, 0.00001);
    vec3 suv = ndc * 0.5 + 0.5;

    if (suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0 || suv.z < 0.0 || suv.z > 1.0) {
        return 1.0;
    }

    float slope = max(abs(dFdx(suv.z)), abs(dFdy(suv.z)));
    float rpdb = (abs(dFdx(suv.x)) + abs(dFdy(suv.y))) * 2.0;
    float bias = SHADOW_BIAS_BASE + slope * 12.0 + rpdb + SHADOW_TEXEL * 3.0;

    // Soft 5-tap shadow blur.
    float hard = cmpShadow(suv.xy, suv.z, bias);
    float c  = hard * 0.40;
    float s1 = cmpShadow(suv.xy + vec2( SHADOW_TEXEL, 0.0),       suv.z, bias) * 0.15;
    float s2 = cmpShadow(suv.xy + vec2(-SHADOW_TEXEL, 0.0),       suv.z, bias) * 0.15;
    float s3 = cmpShadow(suv.xy + vec2(0.0,  SHADOW_TEXEL),       suv.z, bias) * 0.15;
    float s4 = cmpShadow(suv.xy + vec2(0.0, -SHADOW_TEXEL),       suv.z, bias) * 0.15;
    return c + s1 + s2 + s3 + s4;
}

void main() {
    vec4 albedo = texture2D(texture, vTexCoord) * vColor;
    float visibility = sampleShadow(vShadowCoord);

    float shadowAmount = 1.0 - visibility;
    float light = mix(1.0, 0.76, shadowAmount);

    // Preserve entity damage flash (red tint) so hit feedback stays visible.
    float redOver = max(vColor.r - max(vColor.g, vColor.b), 0.0);
    float hurtMask = smoothstep(0.10, 0.45, redOver);
    light = mix(light, 1.0, hurtMask);

    gl_FragData[0] = vec4(albedo.rgb * light, albedo.a);
}
