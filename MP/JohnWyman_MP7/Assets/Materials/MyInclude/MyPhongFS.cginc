#pragma once

float4 FragmentProgram(DataForFragmentShader input) : SV_Target
{
    // sample the texture
    float4 texColor = float4(1, 1, 1, 1);
    if (FlagIsOn(kTexture))
        texColor = tex2D(_MainTex, input.uv);

    float4 shadedResult = float4(0, 0, 0, 1);
    if (FlagIsOn(kAmbient))
        shadedResult = float4(_Ka.xyz, 1);

    for (int i = 0; i < kNumLights; i++) {
        if (LightState[i] != eLightOff)
            shadedResult += PhongIlluminate(_CameraPosition, input.worldPos, i, input.normal, texColor);
    }

    return float4(shadedResult.rgb, _ShadowWeight);
}