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

    public bool UseMainCamera = true;
    public bool Texture = true;
    public bool Ambient = true;
    public bool Diffuse = true;
    public bool Specular = true;
    public bool DistanceAttenuation = true;
    public bool AngularAttenuation = true;
    public LightSource[] Lights;
    public Transform ShadowReceiver = null;
    public Color ShadowColor = Color.gray;

    LightsLoader mLgtLoader = new LightsLoader();

    
    void Start()
    {
        Debug.Assert(ShadowReceiver != null);
    }

    void SetLightLoader() {
        for (int i = 0; i < kNumLights; i++)
            mLgtLoader.LightSourceSetLoader(i, Lights[i]);
    }

    // Update is called once per frame
    void Update()
    {   
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
        Shader.SetGlobalInt("_ShaderMode", mode);
        // Debug.Log("ShaderMode=" + mode);

        SetLightLoader();
        mLgtLoader.LoadLightsToShader();

        float D = Vector3.Dot(ShadowReceiver.localPosition, ShadowReceiver.up);

        Shader.SetGlobalColor("_ShadowColor", ShadowColor);
        Shader.SetGlobalVector("_Normal", ShadowReceiver.up);
        Shader.SetGlobalFloat("_D", D);

    }
}
