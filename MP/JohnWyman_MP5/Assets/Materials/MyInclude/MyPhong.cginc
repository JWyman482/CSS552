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
        float3 S = LightDirection[lgt];
        
        if (FlagIsOn(kAngularAtten))
        {
            // Not efficient, but makes it easier to read
            float alpha = acos(dot(L, S));
            float theta = radians(LightInner[lgt]);
            float phi = radians(LightOuter[lgt]);
            
            if (alpha < theta)
                LightInt = 1.0f;
            else if (alpha > phi)
                LightInt = 0.0f;
            else
                LightInt = smoothstep(0.0f, 1.0f, pow((cos(alpha) - cos(phi)) / (cos(theta) - cos(phi)), LightDropoff[lgt]));
        }
        
        if (FlagIsOn(kDistanceAtten))
        {
            float n = dist - LightNear[lgt];
            float d = LightFar[lgt] - LightNear[lgt];
            
            if (dist < LightNear[lgt])
                LightInt = 1.0f;
            else if (dist > LightFar[lgt])
                LightInt = 0.0f;
            else
                smoothstep(0.0f, 1.0f, 1.0f - (n * n) / (d * d));
                //smoothstep(0.0f, 1.0f, 1.0f - (LightNear[lgt] * LightNear[lgt]) / (dist * dist));
        }
    }
    
    if (LightState[lgt] == ePointLight)
    {
        if (FlagIsOn(kDistanceAtten))
        {
            float n = dist - LightNear[lgt];
            float d = LightFar[lgt] - LightNear[lgt];
            
            if (dist < LightNear[lgt])
                LightInt = 1.0f;
            else if (dist > LightFar[lgt])
                LightInt = 0.0f;
            else
                smoothstep(0.0f, 1.0f, 1.0f - (n * n) / (d * d));
                //smoothstep(0.0f, 1.0f, 1.0f - (LightNear[lgt] * LightNear[lgt]) / (dist * dist));
        }
    }
    
    float4 diffuse = DiffuseResult(N, L, textureMapColor);
    float4 specular = SecularResult(N, L, textureMapColor, eyePos, wpt);
    float4 result = LightInt * LightColor[lgt] * (diffuse + specular);
    
    return result;
}

#endif //  MY_PHONG