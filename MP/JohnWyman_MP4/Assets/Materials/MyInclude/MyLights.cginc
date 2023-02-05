#ifndef MY_LIGHTS
#define MY_LIGHTS

static const int kNumLights = 4;

float LightState[kNumLights];  // 0 - off, 1 - Direction, 2 - Point, 3 - Spot
float4 LightPosition[kNumLights];
float4 LightColor[kNumLights];

#endif // MY_LIGHTS