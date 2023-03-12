using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraPostProcessControl : MonoBehaviour
{
    FogControl TheFog = null;
    public Material TorchMat = null;
    public enum PostProcessOptions {
        eOff,
        eFogOnly,
        eTorchOnly,
        eFogFirst,
        eTorchFirst
    };
    public PostProcessOptions PostProcessOrder = PostProcessOptions.eOff;
    RenderTexture mTempRT = null;

    // Start is called before the first frame update
    void Start()
    {
        // Debug.Assert(TheFog != null);
        // SceneControl will set this!
        Debug.Assert(TorchMat != null);
    }

    public void InitFogControl(FogControl c) {
        TheFog = c; 
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst) {
        if (mTempRT == null)
            mTempRT = new RenderTexture(src.descriptor);

        switch (PostProcessOrder) {
            case PostProcessOptions.eOff:
                Graphics.Blit(src, dst);  // simple copying
                break;
            case PostProcessOptions.eFogOnly:
                Graphics.Blit(src, dst, TheFog.TheFogMat());
                break;
            case PostProcessOptions.eTorchOnly:
                Graphics.Blit(src, dst, TorchMat);
                break;
            case PostProcessOptions.eFogFirst:
                Graphics.Blit(src, mTempRT, TheFog.TheFogMat());
                Graphics.Blit(mTempRT, dst, TorchMat);
                break;
            case PostProcessOptions.eTorchFirst:
                Graphics.Blit(src, mTempRT, TorchMat);
                Graphics.Blit(mTempRT, dst, TheFog.TheFogMat());
                break;
        }
    }
}
