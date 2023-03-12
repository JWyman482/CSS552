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
float LightNearDist[kNumLights];
float LightFarDist[kNumLights];
float SpotInnerCos[kNumLights];
float SpotOuterCos[kNumLights];
float SpotDropOff[kNumLights];


static const float eLightOff = 0.0;
static const float eDirectionalLight = 1.0;
static const float ePointLight = 2.0;
static const float eSpotLight = 3.0;

#endif // MY_LIGHTS