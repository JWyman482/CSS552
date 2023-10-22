using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Projector : MonoBehaviour
{
    // Assumed:
    // . This script is placed on the gameObject with the geometry
    // . This gameObject has a child with name "ProjectorCam"
    // . ProjectorCam must have a camera for computing projection
    // . This gameObject has a material with float4x4 "_WorldToProjectionNDC"
    public enum TexMode
    {
        tile,
        repeatColor,
        mirror,
        boundColor
    };

    const int uTile = 1;
    const int uRepeat = 2;
    const int uMirror = 4;
    const int uBound = 8;
    const int vTile = 16;
    const int vRepeat = 32;
    const int vMirror = 64;
    const int vBound = 128;

    Camera mTheProjector;
    Material mProjectionMat = null;
    public Vector2 Tile = new Vector2(1.0f, 1.0f);
    public Vector2 Offset = new Vector2(0.0f, 0.0f);
    public Color BoundColor;
    public TexMode Umode = TexMode.tile;
    public TexMode Vmode = TexMode.tile;
    // public bool UseEditorSetting = true;
    public bool resetValues = false;

    // Start is called before the first frame update
    void Start()
    {
        Transform child = transform.Find("ProjectorCam");
        Debug.Assert( child != null);
        mTheProjector = child.GetComponent<Camera>();
        mProjectionMat = GetComponent<Renderer>().material;

        Debug.Assert(mTheProjector != null);
        Debug.Assert(mProjectionMat != null);
    }

    // Update is called once per frame
    void Update()
    {
        Matrix4x4 m = mTheProjector.projectionMatrix * mTheProjector.worldToCameraMatrix;
        mProjectionMat.SetMatrix("_WorldToProjectionNDC", m);
        
        Vector4 tmapSettings = new Vector4(Tile.x, Tile.y, Offset.x, Offset.y);
        // mProjectionMat.SetVector("_TexMapSettings_ST", tmapSettings);
        mProjectionMat.SetVector("_TexMapSettings", tmapSettings);
        
        int TexFlag = (Umode == TexMode.tile) ? uTile : 0;
        TexFlag |= (Umode == TexMode.repeatColor) ? uRepeat : 0;
        TexFlag |= (Umode == TexMode.mirror) ? uMirror : 0;
        TexFlag |= (Umode == TexMode.boundColor) ? uBound : 0;
        TexFlag |= (Vmode == TexMode.tile) ? vTile : 0;
        TexFlag |= (Vmode == TexMode.repeatColor) ? vRepeat : 0;
        TexFlag |= (Vmode == TexMode.mirror) ? vMirror : 0;
        TexFlag |= (Vmode == TexMode.boundColor) ? vBound : 0;
        
        
        if (resetValues) {
            Tile.x = 1;
            Tile.y = 1;
            Offset.x = 0;
            Offset.y = 0;
            Umode = TexMode.tile;
            Vmode = TexMode.tile;
            resetValues = false;
        }
        

        mProjectionMat.SetInteger("_UMode", (int) Umode);
        mProjectionMat.SetInteger("_VMode", (int) Vmode);
        mProjectionMat.SetInteger("_TexFlag", (int) TexFlag);
        mProjectionMat.SetVector("_BoundColor", BoundColor);

        // if (UseEditorSetting) 
        // {
        //     TextureWrapMode UWrapMode = TextureWrapMode.Repeat;
        //     if (Umode == TexMode.tile) UWrapMode = TextureWrapMode.Repeat;
        //     if (Umode == TexMode.repeatColor) UWrapMode = TextureWrapMode.Clamp;
        //     if (Umode == TexMode.mirror) UWrapMode = TextureWrapMode.Mirror;

        //     TextureWrapMode VWrapMode = TextureWrapMode.Repeat;
        //     if (Vmode == TexMode.tile) VWrapMode = TextureWrapMode.Repeat;
        //     if (Vmode == TexMode.repeatColor) VWrapMode = TextureWrapMode.Clamp;
        //     if (Vmode == TexMode.mirror) VWrapMode = TextureWrapMode.Mirror;
            
        //     // UWrapMode = (TextureWrapMode) Umode;
        //     mProjectionMat.GetTexture("_MainTex").wrapModeU = UWrapMode;
        //     mProjectionMat.GetTexture("_MainTex").wrapModeV = VWrapMode;
        // }
    }
}
