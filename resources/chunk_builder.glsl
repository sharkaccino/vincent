#[compute]
#version 450

layout(set = 0, binding = 0, std430) readonly restrict buffer parameters {
  float chunk_x;
  float chunk_y;
  float chunk_size;
  float image_width;
  float image_height;
} params;

layout(set = 0, binding = 1, rgba16f) readonly restrict uniform image2D chunk;

layout(set = 0, binding = 2, rgba16f) writeonly restrict uniform image2D output_image;

layout(local_size_x = 32, local_size_y = 32, local_size_z = 1) in;

void main() {
  ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
  ivec2 chunk_pos = ivec2(params.chunk_x, params.chunk_y);

  // output image boundary checks
  if (uv.x > params.image_width) return;
  if (uv.y > params.image_height) return;

  // chunk boundary checks
  if (uv.x < (params.chunk_x * params.chunk_size)) return;
  if (uv.y < (params.chunk_y * params.chunk_size)) return;
  if (uv.x > (params.chunk_x * params.chunk_size) + params.chunk_size) return;
  if (uv.y > (params.chunk_y * params.chunk_size) + params.chunk_size) return;

  ivec2 chunk_uv = ivec2(uv - (params.chunk_size * chunk_pos));

  vec4 chunk_px = imageLoad(chunk, chunk_uv);
  // vec4 chunk_px = vec4(1,1,1,1);
  imageStore(output_image, uv, chunk_px);
}