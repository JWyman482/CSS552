using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TorchCon : MonoBehaviour
{

    public Material TorchMat = null;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        // Graphics.Blit(src, dst);  // simple copying
        Graphics.Blit(src, dst, TorchMat);
    }
}
