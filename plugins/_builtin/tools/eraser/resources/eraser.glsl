#[compute]
#version 450

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly restrict buffer inputdata {
  float chunk_size;
  float oob;
  float old_chunk_x;
  float old_chunk_y;
  float old_x;
  float old_y;
  float old_size;
  float new_chunk_x;
  float new_chunk_y;
  float new_x;
  float new_y;
  float new_size;
  float pixel_mode;
  float softness;
  float spacing;
  float shape_mode;
} params;

layout(set = 0, binding = 1, std430) writeonly restrict buffer queuedata {
  float chunk_x;
  float chunk_y;
  float x;
  float y;
  float size;
} queue;

layout(set = 0, binding = 2, rgba16f) uniform image2D image;

float smootherstep(float edge0, float edge1, float x) {
  x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return x * x * x * (x * (6.0 * x - 15.0) + 10.0);
}

void main() {
  ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
  vec2 last_stamp_offset = vec2(
    params.old_x + (params.chunk_size * (params.old_chunk_x - params.new_chunk_x)),
    params.old_y + (params.chunk_size * (params.old_chunk_y - params.new_chunk_y)) 
  );

  // determine affected area for this execution
  vec2 point_top_left = vec2(
    floor(min(
      params.new_x - (params.new_size / 2),
      last_stamp_offset.x - (params.old_size / 2)
    )),
    floor(min(
      params.new_y - (params.new_size / 2),
      last_stamp_offset.y - (params.old_size / 2)
    ))
  );

  vec2 point_bottom_right = vec2(
    ceil(max(
      params.new_x + (params.new_size / 2),
      last_stamp_offset.x + (params.old_size / 2)
    )),
    ceil(max(
      params.new_y + (params.new_size / 2),
      last_stamp_offset.y + (params.old_size / 2)
    ))
  );

  // stop here if the current pixel is gauranteed to be unaffected
  // imageStore(image, uv, vec4(vec3(0), 1));

  if (uv.x < point_top_left.x) return;
  if (uv.y < point_top_left.y) return;
  if (uv.x > point_bottom_right.x) return;
  if (uv.y > point_bottom_right.y) return;

  // imageStore(image, uv, vec4(vec3(1), 1));

  vec4 backdrop = imageLoad(image, uv);

  vec2 new_cursor_pos = vec2(params.new_x, params.new_y);
  vec2 uv_fixed = vec2(uv) + vec2(0.5, 0.5);

  float dist = distance(last_stamp_offset, new_cursor_pos);
  float progressed = params.spacing;

  // allows initial stamp to be placed
  if (dist == 0.0) {
    dist += progressed * 1.1;
  }

  vec4 output_color = backdrop;

  vec2 update_last_stamp_position = last_stamp_offset;
  float update_last_stamp_size = params.old_size;

  // progressively create stamps between previous 
  // successful stamp position and new cursor position
  while (progressed < dist) {
    float mix_amount = progressed / dist;
    progressed += params.spacing;

    vec2 lerp_pos = mix(last_stamp_offset, new_cursor_pos, mix_amount);
    float lerp_size = mix(params.old_size, params.new_size, mix_amount);

    update_last_stamp_position = lerp_pos;
    update_last_stamp_size = lerp_size;

    if (params.oob == 1.0) continue;

    if (params.pixel_mode == 1.0) {
      if (params.new_size == 1.0) {
        if (uv != floor(lerp_pos)) continue;
        output_color.a = 0.0;
      } else {
        float radius = lerp_size / 2;
        float circle = distance(uv_fixed, lerp_pos);
        if (circle < radius) output_color.a = 0.0;
      }
    } else {
      float radius = lerp_size / 2;
      float circle = distance(uv_fixed, lerp_pos);

      float smoothed = smootherstep(
        radius,
        radius - ((params.softness * radius) + 1.5),
        circle
      );

      if (smoothed == 0.0) continue;
      output_color.a *= (1.0 - smoothed);
    }

    if (output_color.a == 0.0) {
      output_color.rgb = vec3(0);
    }
  }

  // TODO: these values only need to be written once.
  //
  // these should come out with the same result across 
  // all workgroups and all texels, so constantly 
  // writing to the uniform buffer is really unnecessary. 
  // but we also can't just run this on the first 
  // gl_LocalInvocationIndex, because the first pixel
  // is never guaranteed to be processed due to the
  // affected area checks further up.
  //
  // idk if this actually results in a noticeable 
  // performance degradation, but it might be worth
  // investigating at some point.
  queue.chunk_x = params.new_chunk_x;
  queue.chunk_y = params.new_chunk_y;
  queue.x = update_last_stamp_position.x;
  queue.y = update_last_stamp_position.y;
  queue.size = update_last_stamp_size;

  if (output_color != backdrop && params.oob == 0.0) {
    imageStore(image, uv, output_color);
  }
}