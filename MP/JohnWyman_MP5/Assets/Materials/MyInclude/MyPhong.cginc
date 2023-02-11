#ifndef MY_PHONG
#define MY_PHONG

int _ShaderMode;
static const int kTexture = 1;
static const int kAmbient = 2;
static const int kDiffuse = 4;
static const int kSpecular = 8;
static const int kDistanceAtten = 16;
static const int kAngularAtten = 32;

inline int FlagIsOn(int flag) {
    return ((_ShaderMode & flag) != 0);
}

static const float eLightOff = 0.0;
static const float eDirectionalLight = 1.0;
static const float ePointLight = 2.0;
static const float eSpotLight = 3.0;   // not supported in MP4

float4 DiffuseResult(float3 N, float3 L, float4 textureMapColor) {
    if (FlagIsOn(kDiffuse))
        return _Kd.w * float4(_Kd.xyz, 1) * max(0.0, dot(N, L)) * textureMapColor;
    else 
        return float4(0, 0, 0, 1);
}

float4 PhongIlluminate(float3 eyePos, float3 wpt, int lgt, float3 N, float4 textureMapColor) {
    float3 L; // light vector
    float dist; // distance to light
    if (LightState[lgt] == eDirectionalLight) {
        L = LightDirection[lgt];
    } else {
        L = LightPosition[lgt] - wpt;
        dist = length(L);
        L = L / dist;  // normalization
    }
    
    float4  diffuse = DiffuseResult(N, L, textureMapColor);
    float4 result = LightIntensity[lgt] * LightColor[lgt] * diffuse;
    return result;
}

#endif //  MY_PHONG