using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Assume
//     1. This script is attached to ShadowCam
//     2. ShadowCam is a child of the light source
//     3. Initial direction of the camera is pointing in the correct direction
public class ShadowCamControl : MonoBehaviour
{
    public enum DebugShadowMap {
        eDebugOff = 0x0,
        eFilter3 = 0x40,
        eFilter5 = 0x80,
        eFilter9 = 0x100,
        eFilter15 = 0x200,
        eDebugMapDistance = 0x01,
        eDebugMapDistanceWithBias = 0x02,
        eDebugShowShadowInRed = 0x08,
        eDebugShowMapWC = 0x20,
        eDebugLightDistance = 0x04
    };

    public enum ShadowResolution {
        e128x128 = 128,
        e512x512 = 512,
        e1024x1024 = 1024,
        e2048x2048 = 2048
    };

    public Shader DepthShader = null;  // Material that computes ShadowMap or DepthMap
    public float DepthBias = 0.1f;  // 
    public float NormalBias = 0.1f;
    public DebugShadowMap DebugFlag = DebugShadowMap.eDebugOff;
    public ShadowResolution ShadowResFlag = ShadowResolution.e2048x2048;
    public float DebugDistanceScale = 0.1f;
    
    public GameObject ShowDepthTexture = null;

    Camera mShadowCam;
    RenderTexture mDepthTexture;

    void Start()
    {
        Debug.Assert(DepthShader != null);
        mDepthTexture = new RenderTexture((int)ShadowResFlag, (int)ShadowResFlag, 32, RenderTextureFormat.ARGBFloat);
                
        if (ShowDepthTexture != null)   // if this is set, display the depth texture rendered
            ShowDepthTexture.GetComponent<Renderer>().material.SetTexture("_MainTex", mDepthTexture);

        mShadowCam = GetComponent<Camera>();
        mShadowCam.SetReplacementShader(DepthShader, "RenderType");    
        mShadowCam.targetTexture = mDepthTexture;
        Shader.SetGlobalTexture("_ShadowMap", mDepthTexture);
    }

    // Update is called once per frame
    void Update()
    {   
        mDepthTexture.Release();
        mDepthTexture = new RenderTexture((int)ShadowResFlag, (int)ShadowResFlag, 32, RenderTextureFormat.ARGBFloat);
        if (ShowDepthTexture != null)   // if this is set, display the depth texture rendered
            ShowDepthTexture.GetComponent<Renderer>().material.SetTexture("_MainTex", mDepthTexture);
        mShadowCam.targetTexture = mDepthTexture;
        Shader.SetGlobalTexture("_ShadowMap", mDepthTexture);
        float ShadowRes = 1.0f / (float)ShadowResFlag;
        Shader.SetGlobalFloat("_kInvWidth", ShadowRes);
        Shader.SetGlobalFloat("_kInvHeight", ShadowRes);

        Matrix4x4 m = mShadowCam.projectionMatrix * mShadowCam.worldToCameraMatrix;
        Shader.SetGlobalMatrix("_WorldToLightNDC", m);
        Shader.SetGlobalFloat("_DepthBias", DepthBias);
        Shader.SetGlobalFloat("_NormalBias", NormalBias);
        Shader.SetGlobalFloat("_DebugDistScale", DebugDistanceScale);
        Shader.SetGlobalInteger("_MapFlag", (int) DebugFlag);

    }

    public RenderTexture GetDepthTexture() { 
        Debug.Assert(mDepthTexture != null);
        return mDepthTexture; 
    }
}
