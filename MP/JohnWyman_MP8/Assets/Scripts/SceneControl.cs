using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;  // for SceneView access, Selection

// Learn from here to allow editor showing public class
// https://forum.unity.com/threads/c-custom-class-display-in-inspector.89865/ 
[System.Serializable]
public class SceneControl : MonoBehaviour
{
    const int kUseTexture = 1;
    const int kCompAmbient = 2;
    const int kCompDiffuse = 4;
    const int kCompSpecular = 8;
    const int kCompDistAtten = 16;
    const int kCompAngularAtten = 32;
    const int kUseShadow = 64;
    const int kUseMirror = 128;
    private static int kNumLights = 4; // must be identical to the M2_Shader

    public CameraPostProcessControl.PostProcessOptions PostProcessingOrder = CameraPostProcessControl.PostProcessOptions.eOff;
    public FogControl GroundFog = new FogControl();
    public bool UseMainCamera = true;
    public bool Texture = true;
    public bool Ambient = true;
    public bool Diffuse = true;
    public bool Specular = true;
    public bool DistanceAttenuation = true;
    public bool AngularAttenuation = true;
    public LightSource[] Lights;
    LightsLoader mLgtLoader = new LightsLoader();

    public bool Shadow = true;
    public Color ShadowColor = Color.black;

    public bool UseMirror = true;

    void Start()
    {
        GroundFog.InitFogControl();
        Camera.main.gameObject.GetComponent<CameraPostProcessControl>().InitFogControl(GroundFog);
    }

    void SetLightLoader() {
        for (int i = 0; i < kNumLights; i++)
            mLgtLoader.LightSourceSetLoader(i, Lights[i]);
    }

    // Update is called once per frame
    void Update()
    {   
        GroundFog.UpdateFogControl();
        
        // This is NOT light, but per-shader shared for all
        if (UseMainCamera) 
            Shader.SetGlobalVector("_CameraPosition", (Vector4) Camera.main.transform.localPosition);
        else {
            Shader.SetGlobalVector("_CameraPosition", (Vector4) SceneView.lastActiveSceneView.camera.transform.localPosition);
        }
        
        // ShaderMode;
        int mode = (Texture) ? kUseTexture : 0;
        mode |= (Ambient) ? kCompAmbient : 0;
        mode |= (Diffuse) ? kCompDiffuse : 0;
        mode |= (Specular) ? kCompSpecular : 0;
        mode |= (DistanceAttenuation) ? kCompDistAtten : 0;
        mode |= (AngularAttenuation) ? kCompAngularAtten : 0;
        mode |= (Shadow) ? kUseShadow : 0;
        mode |= (UseMirror) ? kUseMirror : 0;
        Shader.SetGlobalInt("_ShaderMode", mode);

        SetLightLoader();
        mLgtLoader.LoadLightsToShader();

        // Shadow receiver support
        Shader.SetGlobalColor("_ShadowColor", ShadowColor);

        // accessing MainCamera
        Camera.main.gameObject.GetComponent<CameraPostProcessControl>().PostProcessOrder = PostProcessingOrder;
    }
}
