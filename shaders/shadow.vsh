#version 120

void main() {
    // Depth-only shadow pass; no texcoord/color outputs needed.
    gl_Position = ftransform();
}
