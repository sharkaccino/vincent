#[compute]
#version 450

layout(set = 0, binding = 0, std430) readonly buffer parameters {
  float r;
  float g;
  float b;
  float a;
  float new_pos_x;
  float new_pos_y;
  float new_size;
  float softness;
  float spacing;
} params;

// !! must be the same as stamp_pos_writer.glsl !!
layout(set = 0, binding = 1, std430) buffer workspace_mem {
  float x;
  float y;
  float size;
  float queue_x;
  float queue_y;
  float queue_size;
} last_stamp;

layout(set = 0, binding = 2, rgba32f) uniform image2D image;

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

float smootherstep(float edge0, float edge1, float x) {
  x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return x * x * x * (x * (6.0 * x - 15.0) + 10.0);
}

void main() {
  ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
  vec4 backdrop = imageLoad(image, uv);

  vec2 new_cursor_pos = vec2(params.new_pos_x, params.new_pos_y);
  vec2 last_stamp_position = vec2(last_stamp.x, last_stamp.y);
  vec2 uv_fixed = vec2(uv) + vec2(0.5, 0.5);

  float dist = distance(last_stamp_position, new_cursor_pos);
  float progressed = params.spacing;

  // allows initial stamp to be placed
  if (dist == 0.0) {
    dist += progressed * 1.1;
  }

  vec4 output_color = backdrop;

  vec2 update_last_stamp_position = last_stamp_position;
  float update_last_stamp_size = last_stamp.size;

  while (progressed < dist) {
    float mix_amount = progressed / dist;
    progressed += params.spacing;

    vec2 lerp_pos = mix(last_stamp_position, new_cursor_pos, mix_amount);
    float lerp_size = mix(last_stamp.size, params.new_size, mix_amount);

    update_last_stamp_position = lerp_pos;
    update_last_stamp_size = lerp_size;

    float radius = lerp_size / 2;
    float circle = distance(uv_fixed, lerp_pos);

    float smoothed = smootherstep(
      radius,
      radius - ((params.softness * radius) + 1.5),
      circle
    );

    vec4 stamp = vec4(
      params.r, 
      params.g, 
      params.b, 
      smoothed * params.a
    );

    if (smoothed == 0.0 || stamp.a == 0.0) continue;

    if (output_color.a == 0) {
      output_color = stamp;
    } else {
      output_color.rgb = stamp.rgb * stamp.a + output_color.rgb * output_color.a * (1.0 - stamp.a);
      output_color.a = stamp.a + output_color.a * (1.0 - stamp.a);
      output_color.rgb /= output_color.a;
    }
  }

  if (gl_WorkGroupID == vec3(0) && gl_LocalInvocationIndex == 0) {
    // these positions should come out the exact 
    // same in all workgroups, so let's avoid 
    // pointlessly writing to the buffer after
    // the first one finishes.
    last_stamp.queue_x = update_last_stamp_position.x;
    last_stamp.queue_y = update_last_stamp_position.y;
    last_stamp.queue_size = update_last_stamp_size;
  }

  if (output_color != backdrop) {
    imageStore(image, uv, output_color);
  }
}