using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

public class LightsLoader
{
    const int kNumLights = 4;
    
    float[] mLightState;
    Vector4[]  mLightPosition;
    Vector4[]  mLightDirection;
    Vector4[] mLightColor;
    float[] mLightIntensity;

    float[] mLightNear;
    float[] mLightFar;
    float[] mLightInner;
    float[] mLightOuter;
    float[] mLightDropoff;
    
    public LightsLoader()
    {
        mLightState = new float [kNumLights];
        mLightPosition = new Vector4[kNumLights];
        mLightDirection = new Vector4[kNumLights];
        mLightColor = new Vector4[kNumLights];
        mLightIntensity = new float[kNumLights];

        mLightNear = new float[kNumLights];
        mLightFar = new float[kNumLights]; 
        mLightInner = new float[kNumLights]; 
        mLightOuter = new float[kNumLights];
        mLightDropoff = new float[kNumLights];

        for (int i = 0; i < kNumLights; i++) {
            mLightState[i] = 0.0f;  // this is off
            mLightPosition[i] =  Vector4.zero;
            mLightDirection[i] = Vector4.zero;
            mLightColor[i] = Vector4.zero;
            mLightIntensity[i] = 1.0f;

            mLightNear[i] = 0.0f;
            mLightFar[i] = 0.0f;
            mLightInner[i] = 0.0f;
            mLightOuter[i] = 0.0f;
            mLightDropoff[i] = 0.0f;
        }
    }

    // Update is called once per frame
    public void LoadLightsToShader()
    {
        Shader.SetGlobalFloatArray("LightState", mLightState);
        Shader.SetGlobalVectorArray("LightPosition", mLightPosition);
        Shader.SetGlobalVectorArray("LightDirection", mLightDirection);
        Shader.SetGlobalVectorArray("LightColor", mLightColor);
        Shader.SetGlobalFloatArray("LightIntensity", mLightIntensity);

        Shader.SetGlobalFloatArray("LightNear", mLightNear);
        Shader.SetGlobalFloatArray("LightFar", mLightFar);
        Shader.SetGlobalFloatArray("LightInner", mLightInner);
        Shader.SetGlobalFloatArray("LightOuter", mLightOuter);
        Shader.SetGlobalFloatArray("LightDropoff", mLightDropoff);
    }

    public void LightSourceSetLoader(int index, LightSource s) {
        if (s.LightIsOn)
            mLightState[index] = (float) s.LightState;
        else
            mLightState[index] = 0.0f;

        mLightPosition[index] = s.transform.localPosition;
        mLightDirection[index] = s.transform.up;
        mLightColor[index] = s.LightColor;
        mLightIntensity[index] = s.Intensity;

        mLightNear[index] = s.Near;
        mLightFar[index] = s.Far;
        mLightInner[index] = s.SpotInner;
        mLightOuter[index] = s.SpotOuter;
        mLightDropoff[index] = s.SpotDropOff;
    }
}
