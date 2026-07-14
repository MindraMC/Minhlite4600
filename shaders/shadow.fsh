#version 120

// Nearest shadow sampling for the hardest possible edge shape.
const bool shadowHardwareFiltering = false;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;
const bool shadowtex0Mipmap = false;
const bool shadowtex1Mipmap = false;

void main() {
    // Depth-only shadow pass.
}
