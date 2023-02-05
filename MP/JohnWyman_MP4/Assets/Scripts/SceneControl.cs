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

    public bool UseTexture = false;
    public bool AddAmbient = false;
    public bool AddDiffuse = false;
    // public bool AddSpecular = false;
    // public bool AddDistanceAtten = false;
    // public bool AddAngularAtten = false;

    public LightSource[] Lights;

    LightsLoader mLgtLoader = new LightsLoader(); // initializes lightstate to 0.0f

    void Start()
    {
        Debug.Assert(Lights != null);
    }


    // Update is called once per frame
    void Update()
    {
        // Bitmask/Flags
        int flag = 0x0;
        if (UseTexture) flag |= kUseTexture;
        if (AddAmbient) flag |= kCompAmbient;
        if (AddDiffuse) flag |= kCompDiffuse;
        // if (AddSpecular) flag |= kCompSpecular;
        // if (AddDistAtten) flag |= kCompDistAtten;
        // if (AddAngularAtten) flag |= kCompAngularAtten;


        Shader.SetGlobalInteger("_ShaderMode", flag);

        // Sets per-scene information
        // Lights
        // Current Camera position
        // Mode: on what is on and off
        // Hint: Set by calling
        //    Shader.SetGlobal ...   

        for (int lgtIndex = 0; lgtIndex < Lights.Length; lgtIndex++) 
        {
            // LightSourceSetLoader takes the lightsource and grabs
            // the state/color/pos right off the source.
            // Debug.Log(Lights[lgtIndex].transform.localPosition);
            mLgtLoader.LightSourceSetLoader(lgtIndex, Lights[lgtIndex]);
        }

        mLgtLoader.LoadLightsToShader();
    }
}
