#[compute]
#version 450

// !! must be the same as brush.glsl !!
layout(set = 0, binding = 0, std430) buffer workspace_mem {
  float x;
  float y;
  float size;
  float queue_x;
  float queue_y;
  float queue_size;
} last_stamp;

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

void main() {
  last_stamp.x = last_stamp.queue_x;
  last_stamp.y = last_stamp.queue_y;
  last_stamp.size = last_stamp.queue_size;
}