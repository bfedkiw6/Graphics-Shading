#version 300 es

#define MAX_LIGHTS 16

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


// an attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;

// camera position
uniform vec3 u_eye;

// transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// shading output
out vec4 o_color;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {
    
    // TODO: Implement this method
    vec3 I = light.intensity * material.kA;

    return I * light.color;
}

// Shades a directional light and returns its contribution
vec3 shadeDirectionalLight(Material material, DirectionalLight light, vec3 normal, vec3 eye, vec3 vertex_position) {

    // TODO: Implement this method
    vec3 L = normalize(vec3(u_v * vec4(light.direction, 0.0)));
    float lambertTerm = dot(normal,L);

    // Diffuse
    vec3 Id = vec3(0.0, 0.0, 0.0);
    // Specular
    vec3 Is = vec3(0.0, 0.0, 0.0);

    if (lambertTerm > 0.0) {
        Id = light.intensity * material.kD * lambertTerm;

        vec3 e = vec3(u_v * vec4(eye, 1.0));
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
    vec3 u_v_light_pos = vec3(u_v * vec4(light.position, 1.0));
    vec3 direct_vec = u_v_light_pos - vertex_position;
    vec3 L = normalize(direct_vec);
    float lambertTerm = dot(normal,L);

     // Diffuse
    vec3 Id = vec3(0.0, 0.0, 0.0);
    // Specular
    vec3 Is = vec3(0.0, 0.0, 0.0);

    if (lambertTerm > 0.0) {
        Id = light.intensity * material.kD * lambertTerm;

        vec3 e = vec3(u_v * vec4(eye, 1.0));
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

    // TODO: GORAUD SHADING
    // TODO: Implement the vertex stage
    // TODO: Transform positions and normals
    // NOTE: Normals are transformed differently from positions. Check the book and resources.
    // TODO: Use the above methods to shade every light in the light arrays
    // TODO: Accumulate their contribution and use this total light contribution to pass to o_color

    mat4 normalMatrix = transpose(inverse(u_v * u_m));
    vec3 normal = normalize(vec3(normalMatrix * vec4(a_normal, 0.0)));

    vec3 vertex_pos = vec3(u_v * u_m * vec4(a_position, 1.0));

    // TODO: Pass the shaded vertex color to the fragment stage
    o_color = vec4(0.0, 0.0, 0.0, 1.0);

    for (int i = 0; i < u_lights_ambient.length(); i += 1) {
         o_color = o_color + vec4(shadeAmbientLight(u_material, u_lights_ambient[i]), 0.0);
    }

    for (int j = 0; j < u_lights_directional.length(); j += 1) {
         o_color = o_color + vec4(shadeDirectionalLight(u_material, u_lights_directional[j], normal, u_eye, vertex_pos), 0.0);
    }

    for (int k = 0; k < u_lights_point.length(); k += 1) {
         o_color = o_color + vec4(shadePointLight(u_material, u_lights_point[k], normal, u_eye, vertex_pos), 0.0);
    }

     gl_Position = u_p * u_v * u_m * vec4(a_position, 1.0);
}