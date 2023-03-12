using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TorchControl : MonoBehaviour
{  
    public float TorchRadius = 5.0f;
    public float TorchFar = 10f;
    public float TorchFarIntensity = 0.3f;
    

    // for debug support
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowClear = 1,
        DebugShowBlend = 2
    };
    static int kShowReverseEffect = 0x20;
    public DebugShowFlag DebugFlag = DebugShowFlag.DebugOff;
    
    public Material TorchMat = null;
    public DepthCamControl DepthCam = null;
    public bool ShowInvertedEffect = false;
    
    void Start()
    {
        Debug.Assert(TorchMat != null);
        Debug.Assert(DepthCam != null);

        TorchMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());

        float invW = 1.0f/(float)Camera.main.pixelWidth;
        float invH = 1.0f/(float)Camera.main.pixelHeight;
        TorchMat.SetFloat("_invWidth", invW);
        TorchMat.SetFloat("_invHeight", invH);
    }

    void Update() {
        TorchMat.SetVector("_torchPosition", transform.localPosition);
        TorchMat.SetFloat("_torchRadius", TorchRadius);
        TorchMat.SetFloat("_torchFar", TorchFar);
        TorchMat.SetFloat("_torchFarIntensity", TorchFarIntensity);

        int f = (int) DebugFlag;
        if (ShowInvertedEffect)
            f |= kShowReverseEffect;
        TorchMat.SetInt("_torchFlag", f);
    }

    public Material TheTorchMat() { return TorchMat; }
}
