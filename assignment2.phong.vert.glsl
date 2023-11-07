#version 300 es

// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// output to fragment stage
// TODO: Create any needed `out` variables here
out vec3 o_normal;
out vec3 o_position;
out mat4x4 o_u_v;

void main() {

    // TODO: PHONG SHADING
    // TODO: Implement the vertex stage
    // TODO: Transform positions and normals
    // NOTE: Normals are transformed differently from positions. Check the book and resources.
    // TODO: Create new `out` variables above outside of main() to store any results

    o_position = vec3(u_v * u_m * vec4(a_position, 1.0));

    mat4 normalMatrix = transpose(inverse(u_v * u_m));
    o_normal = normalize(vec3(normalMatrix * vec4(a_normal, 0.0)));

    o_u_v = u_v;

    gl_Position = u_p * u_v * u_m * vec4(a_position, 1.0);
}
