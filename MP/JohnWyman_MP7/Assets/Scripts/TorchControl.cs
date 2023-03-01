using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TorchControl : MonoBehaviour
{
    public float TorchFar = 30.0f;
    public float TorchRadius = 10.0f;  // all within this range are in focus
    public float TorchFarIntensity = 0.2f;

    // for debug support
    public enum DebugShowFlag {
        DebugOff = 0,
        DebugShowInFocus = 1,
        DebugShowFocus_NF = 2,
    };
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
        //TorchMat.SetFloat("_inFocusN", FocalDistant-Aperture);
        //TorchMat.SetFloat("_inFocusF", FocalDistant+Aperture);
        TorchMat.SetFloat("_TorchRadius", TorchRadius);
        TorchMat.SetFloat("_TorchFar", TorchFar);
        TorchMat.SetVector("_TorchPosition", transform.localPosition);

        int f = (int) DebugFlag;
        TorchMat.SetInt("_torchFlag", f);
    }

}
