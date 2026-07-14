#version 330 core

uniform sampler2D colortex0;
in vec2 texCoord;
out vec4 fragColor;

void main() {
    fragColor = texture(colortex0, texCoord);
}
