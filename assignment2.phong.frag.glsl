#version 300 es

#define MAX_LIGHTS 16

// Fragment shaders don't have a default precision so we need
// to pick one. mediump is a good default. It means "medium precision".
precision mediump float;

// struct definitions
struct AmbientLight {
    vec3 color;
    float intensity;
};

struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
};

struct Material {
    vec3 kA;
    vec3 kD;
    vec3 kS;
    float shininess;
};

// lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// camera position
uniform vec3 u_eye;

// received from vertex stage
// TODO: Create any needed `in` variables here
// TODO: These variables correspond to the `out` variables from the vertex stage
in vec3 o_normal;
in vec3 o_position;
in mat4x4 o_u_v;

// with webgl 2, we now have to define an out that will be the color of the fragment
out vec4 o_fragColor;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {

    // TODO: Implement this method
    vec3 I = light.intensity * material.kA;

    return I * light.color;
}

// Shades a directional light and returns its contribution
vec3 shadeDirectionalLight(Material material, DirectionalLight light, vec3 normal, vec3 eye, vec3 vertex_position) {

    // TODO: Implement this method
    vec3 L = normalize(vec3(o_u_v * vec4(light.direction, 0.0)));
    float lambertTerm = dot(normal,L);

    // Diffuse
    vec3 Id = vec3(0.0, 0.0, 0.0);
    // Specular
    vec3 Is = vec3(0.0, 0.0, 0.0);

    if (lambertTerm > 0.0) {
        Id = light.intensity * material.kD * lambertTerm;

        vec3 e = vec3(o_u_v * vec4(eye, 1.0));
        vec3 view_direction = vec3(e - vertex_position);

        vec3 V = normalize(view_direction);
        vec3 R = reflect(-L, normal);
        float specular = pow(max(dot(R, V), 0.0), material.shininess);
        Is = light.intensity * material.kS * specular;
    }
    
    vec3 combine = vec3(Is + Id);
    return combine * light.color;
}

// Shades a point light and returns its contribution
vec3 shadePointLight(Material material, PointLight light, vec3 normal, vec3 eye, vec3 vertex_position) {

    // TODO: Implement this method
    vec3 u_v_light_pos = vec3(o_u_v * vec4(light.position, 1.0));
    vec3 direct_vec = u_v_light_pos - vertex_position;
    vec3 L = normalize(direct_vec);
    float lambertTerm = dot(normal,L);

     // Diffuse
    vec3 Id = vec3(0.0, 0.0, 0.0);
    // Specular
    vec3 Is = vec3(0.0, 0.0, 0.0);

    if (lambertTerm > 0.0) {
        Id = light.intensity * material.kD * lambertTerm;

        vec3 e = vec3(o_u_v * vec4(eye, 1.0));
        vec3 view_direction = vec3(e - vertex_position);

        vec3 V = normalize(view_direction);
        vec3 R = reflect(-L, normal);
        float specular = pow(max(dot(R, V), 0.0), material.shininess);
        Is = light.intensity * material.kS * specular;
    }
    
    float distance = length(direct_vec);
    float f_d = min(1.0, 1.0/(1.0 + pow(distance,2.0)));
    vec3 combine = vec3(f_d * (Is + Id));
    return combine * light.color;
}

void main() {

    // TODO: PHONG SHADING
    // TODO: Implement the fragment stage
    // TODO: Use the above methods to shade every light in the light arrays
    // TODO: Accumulate their contribution and use this total light contribution to pass to o_fragColor

    // TODO: Pass the shaded vertex color to the output
    o_fragColor = vec4(0.0, 0.0, 0.0, 1.0);

    for (int i = 0; i < u_lights_ambient.length(); i += 1) {
         o_fragColor = o_fragColor + vec4(shadeAmbientLight(u_material, u_lights_ambient[i]), 0.0);
    }

    for (int j = 0; j < u_lights_directional.length(); j += 1) {
         o_fragColor = o_fragColor + vec4(shadeDirectionalLight(u_material, u_lights_directional[j], o_normal, u_eye, o_position), 0.0);
    }

    for (int k = 0; k < u_lights_point.length(); k += 1) {
         o_fragColor = o_fragColor + vec4(shadePointLight(u_material, u_lights_point[k], o_normal, u_eye, o_position), 0.0);
    }
}
