#[compute]
#version 450

layout(set = 0, binding = 0, std430) readonly buffer parameters {
  float r;
  float g;
  float b;
  float a;
  float posX;
  float posY;
  float size;
  float softness;
} params;

layout(set = 0, binding = 1, rgba32f) uniform image2D image;

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

float smootherstep(float edge0, float edge1, float x) {
  x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);

  return x * x * x * (x * (6.0 * x - 15.0) + 10.0);
}

void main() {
  ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
  vec4 backdrop = imageLoad(image, uv);

  float circle = length(uv - vec2(params.posX, params.posY) - (params.size / 2));

  // todo: use size and softness params
  float smoothed = 1 - smootherstep(
    params.size - ((params.softness * 2 * params.size) + 1.5),
    params.size,
    circle
  );

  if (smoothed == 0) return;

  vec4 stamp = vec4(
    params.r, 
    params.g, 
    params.b, 
    smoothed * params.a
  );

  if (stamp.a == 0) return;

  vec4 output_color;

  if (backdrop.a == 0) {
    output_color = stamp;
  } else {
    output_color.rgb = stamp.rgb * stamp.a + backdrop.rgb * backdrop.a * (1.0 - stamp.a);
    output_color.a = stamp.a + backdrop.a * (1.0 - stamp.a);
    output_color.rgb /= output_color.a;
  }
  
  imageStore(image, uv, output_color);
}