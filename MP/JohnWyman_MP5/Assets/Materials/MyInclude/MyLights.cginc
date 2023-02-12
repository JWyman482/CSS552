#ifndef MY_LIGHTS
#define MY_LIGHTS

// In the editor: one and only one instance of
//      LightLoader script should be running

static const int kNumLights = 4;

float LightState[kNumLights];  // 0 - off, 1 - Direction, 2 - Point, 3 - Spot
float3 LightPosition[kNumLights];  // 
float3 LightDirection[kNumLights];
float4 LightColor[kNumLights];
float LightIntensity[kNumLights];

float LightNear[kNumLights];
float LightFar[kNumLights];
float LightInner[kNumLights];
float LightOuter[kNumLights];
float LightDropoff[kNumLights];

//float3 L = LightPosition[Spot] - wpt;
//float coneAngle = 90;
//float angleDiff = acos(dot(-L, LightDirection[Spot]));
//if (angleDiff > coneAngle) LightIntensity[Spot] = 0;

#endif // MY_LIGHTS