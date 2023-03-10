using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// Learn from here to allow editor showing public class
// https://forum.unity.com/threads/c-custom-class-display-in-inspector.89865/ 
[System.Serializable]
public class FogControl
{
    public float FogHeight = 5f;
    public float FogDenominator = 10f;
    public float FogDensity = 1f;
    public Color FogColor = Color.white;    
    public bool ShowLinearFog = false;
    public bool FogOverBackground = true;

    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowNotInFog = 1,
        DebugShowBlend = 2
    };
    const int kShowLinearFog = 0x20;
    const int kFogOverBackground = 0x40;
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    
    public Material FogMat; //  UI will set these
    public DepthCamControl DepthCam; // 

    public FogControl()
    {
        // Debug.Assert(FogMat != null);
        // Debug.Assert(DepthCam != null);
    }

    public void InitFogControl() {
        FogMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    public void UpdateFogControl() {

        if (FogDenominator < FogHeight)
            FogDenominator = FogHeight;
        // Fog specific
        FogMat.SetFloat("_fogHeight", FogHeight);
        FogMat.SetFloat("_fogDensity", FogDensity);
        FogMat.SetColor("_fogColor", FogColor);
        FogMat.SetFloat("_fogDenom", FogDenominator);

        int f = (int) DebugFlag;
        // Debug.Log("Flag = " + f);
        f |= ShowLinearFog ? kShowLinearFog : 0;
        f |= FogOverBackground ? kFogOverBackground : 0;
        FogMat.SetInt("_flag", f);
    }
    public Material TheFogMat() { return FogMat; }
}
