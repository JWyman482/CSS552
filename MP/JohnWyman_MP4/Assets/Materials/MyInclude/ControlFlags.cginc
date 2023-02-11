#ifndef CONTROL_FLAGS
#define CONTROL_FLAGS

int _ShaderMode;

inline int FlagIsOn(int flag) {
    return ((_ShaderMode & flag) != 0);
}

// Control Flags
static const int kTexture = 1;
static const int kAmbient = 2;
static const int kDiffuse = 4; // 0100
static const int kSpecular = 8;
static const int kDistanceAtten = 16;
static const int kAngularAtten = 32;

// LightState Flags
static const float eLightOff = 0.0;
static const float eDirectionalLight = 1.0;
static const float ePointLight = 2.0;
static const float eSpotLight = 3.0;   // not supported in MP4

#endif // CONTROL_FLAGS