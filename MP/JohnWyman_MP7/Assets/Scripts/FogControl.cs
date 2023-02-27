using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogControl : MonoBehaviour
{
    public Material FogMat = null;
    public DepthCamControl DepthCam = null;
    void Start()
    {
        Debug.Assert(FogMat != null);
        Debug.Assert(DepthCam != null);

        FogMat.SetTexture("_DepthTexture", DepthCam.GetDepthTexture());
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, FogMat);
    }
}
