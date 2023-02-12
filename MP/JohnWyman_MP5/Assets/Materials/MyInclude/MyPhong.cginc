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
static const float eSpotLight = 3.0;

float4 DiffuseResult(float3 N, float3 L, float4 textureMapColor) {
    if (FlagIsOn(kDiffuse))
        return _Kd.w * float4(_Kd.xyz, 1) * max(0.0, dot(N, L)) * textureMapColor;
    else 
        return float4(0, 0, 0, 1);
}

float4 SecularResult(float3 N, float3 L, float4 textureMapColor, float3 eyepos, float3 wpt)
{
    if (FlagIsOn(kSpecular))
    {
        float3 V = normalize(eyepos - wpt);
        float3 R = reflect(-L, N);
        return _Ks.w * float4(_Ks.xyz, 1) * pow(max(0.0, dot(V, R)), _s) * textureMapColor;
    }
    else
        return float4(0, 0, 0, 1);
}

float4 PhongIlluminate(float3 eyePos, float3 wpt, int lgt, float3 N, float4 textureMapColor) {
    float3 L; // light vector
    float dist; // distance to light
    float LightInt = LightIntensity[lgt];
    
    if (LightState[lgt] == eDirectionalLight) {
        L = LightDirection[lgt];
    } else {
        L = LightPosition[lgt] - wpt;
        dist = length(L);
        L = L / dist;  // normalization
    }
    
    // Spot Light Calc
    if (LightState[lgt] == eSpotLight)
    {
        // L = vector, not normalized, from wpt to Light
        float3 S = LightDirection[lgt];
        float3 Lneg = -1 * L;
        if (FlagIsOn(kAngularAtten))
        {
        
            float angularDifference = degrees(acos(dot(L, S)));
            
            if (angularDifference > LightOuter[lgt])
                LightInt = 0.0f;
        }
        
        if (FlagIsOn(kDistanceAtten))
        {
            
        }
    }
    
    float4 diffuse = DiffuseResult(N, L, textureMapColor);
    float4 specular = SecularResult(N, L, textureMapColor, eyePos, wpt);
    float4 result = LightInt * LightColor[lgt] * (diffuse + specular);
    
    return result;
}

#endif //  MY_PHONG