using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

public class SceneControl : MonoBehaviour
{
    const int kUseTexture = 1;
    const int kCompAmbient = 2;
    const int kCompDiffuse = 4;
    const int kCompSpecular = 8;
    const int kCompDistAtten = 16;
    const int kCompAngularAtten = 32;
    
    private static int kNumLights = 4; // must be identical to the M2_Shader

    public LightSource[] Lights;
    LightsLoader mLgtLoader = new LightsLoader();

    float[] LightSwitchBuffer; // for sending light on/off switch to the shader
    Vector4[] LightPosBuffer; // for sending light position to the shader
    Vector4[] LightColorBuffer;

    [Header("User Controls")]
    public bool ShowTexture = true;
    
    void Start()
    {
        Debug.Assert(Lights != null);

        LightPosBuffer = new Vector4[Lights.Length];
        LightSwitchBuffer = new float[Lights.Length];
        LightColorBuffer = new Vector4[Lights.Length];
    }


    // Update is called once per frame
    void Update()
    {
        // Sets per-scene information
        // Lights
        // Current Camera position
        // Mode: on what is on and off
        // Hint: Set by calling
        //    Shader.SetGlobal ...   

        // compute the global render flag
        int flag = 0x0;
        if (ShowTexture) flag |= kUseTexture;

        // global shader update
        Shader.SetGlobalInteger("_Flag", flag);

        // On/Off Switch
        for (int i = 0; i < Lights.Length; i++)
            // copy from light source to the buffers
            LightSwitchBuffer[i] = Lights[i].LightIsOn ? 1.0f : 0.0f;
        Shader.SetGlobalFloatArray("_LightFlag", LightSwitchBuffer);

        for (int i = 0; i < Lights.Length; i++)
            LightColorBuffer[i] = Lights[i].LightColor;  // notice Color is also a Vector4
        Shader.SetGlobalVectorArray("_LightColor", LightColorBuffer);

        // Light position: show we can use the Editor Camera Position!
        for (int i = 0; i < Lights.Length; i++)
            LightPosBuffer[i] = Lights[i].transform.localPosition;

        //switch (LightPosFrom)
        //{
        //    case EnumSelectLightPosition.eMainCameraPosition:
        //        LightPosBuffer[0] = Camera.main.transform.localPosition;
        //        break;
        //    case EnumSelectLightPosition.eEditorCameraPosition:
        //        LightPosBuffer[0] = SceneView.lastActiveSceneView.camera.transform.localPosition;
        //        break;
        //        // case EnumSelectLightPosition.ePointLightPosition: no need to do anything
        //}
        Shader.SetGlobalVectorArray("_LightPosition", LightPosBuffer);

    }
}
