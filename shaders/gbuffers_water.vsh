#version 120

uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 vTexCoord;
varying vec4 vColor;
varying vec4 vShadowCoord;

void main() {
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPos = gbufferModelViewInverse * viewPos;

    vTexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vColor = gl_Color;
    vShadowCoord = shadowProjection * (shadowModelView * worldPos);

    gl_Position = gl_ProjectionMatrix * viewPos;
}
