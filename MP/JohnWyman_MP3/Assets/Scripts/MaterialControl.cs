using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialControl : MonoBehaviour
{
// must agree with Structs.cginc constants
// OC flags
    const uint OC_SHOW          = 0x01;
    const uint OC_ANIMATED      = 0x02;
    const uint OC_USE_VPOINT    = 0x04;

// WC Flags
    const uint WC_SHOW          = 0x10;
    const uint WC_ANIMATED      = 0x20;
    const uint WC_USE_OCVPOINT  = 0x40;

// EC Flags
    const uint EC_SHOW          = 0x100;
    const uint EC_ANIMATED      = 0x200;
    const uint EC_USE_OCVPOINT  = 0x400;
    const uint EC_USE_WCVPOINT  = 0x080;
    const uint EC_ONLY_Z        = 0x800;
    const uint PC_SHOW          = 0x1000;
    const uint PC_ANIMATED      = 0x2000;
    const uint PC_USE_OCVPOINT  = 0x4000;
    const uint PC_USE_WCVPOINT  = 0x8000;

    const uint SHOW_ORIGINAL = 0x100000;

    public Material mMat = null; // 
    public bool ShowOriginal = true; // to see OC vanish, need to hide original
    public Color ObjColor = Color.gray;

    [Header("Flags")]
    public OCFlags OC;
    public WCFlags WC;
    public ECFlags EC;
    public PCFlags PC;

    void Start() {
        Debug.Assert(WC.VPoint != null);

        if (mMat == null) {  // not set in the UI
            mMat = GetComponent<Renderer>().material;  
            // this will create a separate instance of material for this game object
        }
    }

    void Update() {
        // Control flag update
        mMat.SetInteger("_UserControl", (int) UpdateControlFlag());
        if (EC.OccludeObject != null)
            EC.OccludeObject.SetActive(EC.ShowOccludeObject);

        // OC
        mMat.SetFloat("_OCWeight", OC.Weight);
        mMat.SetVector("_OCVPoint", OC.OCVPoint);

        // World space control
        mMat.SetFloat("_WCWeight", WC.Weight);
        mMat.SetFloat("_WCRate", WC.Rate);
        mMat.SetVector("_WCVPoint", WC.VPoint.localPosition);

        // Eye Coordinate control
        mMat.SetFloat("_ECNear", Camera.main.nearClipPlane);
        mMat.SetFloat("_ECWeight", EC.Weight);

        // Projected Coordinate control
        mMat.SetFloat("_PCWeight", PC.Weight);
        mMat.SetVector("_PCVPoint", PC.VPoint);
    
        mMat.SetColor("_Color", ObjColor);
    }

    uint UpdateControlFlag() {
        uint f = 0x0;
        if (ShowOriginal) f |= SHOW_ORIGINAL;

        // OC Flags
        if (OC.Show) f |= OC_SHOW;
        if (OC.Animate) f |= OC_ANIMATED;
        if (OC.UseOCVPoint) f |= OC_USE_VPOINT;

        // WC Flags
        if (WC.Show) f |= WC_SHOW;
        if (WC.Animate) f |= WC_ANIMATED;
        if (WC.UseOCVPoint) f |= WC_USE_OCVPOINT;

        // EC Flags
        if (EC.Show) f |= EC_SHOW;
        if (EC.Animate) f |= EC_ANIMATED;
        if (EC.UseOCVPoint) f |= EC_USE_OCVPOINT;
        if (EC.UseWCVPoint) f |= EC_USE_WCVPOINT;
        if (EC.OnlyZ) f |= EC_ONLY_Z;

        // PC Flags
        if (PC.Show) f |= PC_SHOW;
        if (PC.Animate) f |= PC_ANIMATED;
        if (PC.UseOCVPoint) f |= PC_USE_OCVPOINT;
        if (PC.UseWCVPoint) f |= PC_USE_WCVPOINT;

        return f;
    }
};

public class Flags
{
    public float Weight = 1f;
    public bool Show = false;
    public bool Animate = false;
    public bool UseOCVPoint = false;
};

[System.Serializable]
public class OCFlags : Flags
{
    // Object Coordinate (OC) Space
    public Vector3 OCVPoint = Vector3.zero;
};

[System.Serializable]
public class WCFlags : Flags
{
    // World Coordinate (WC) Space
    public float Rate = 1f;
    public Transform VPoint = null;
};

[System.Serializable]
public class ECFlags : Flags
{
    // Eye Coordinate (EC) space
    public bool UseWCVPoint = false;
    public bool OnlyZ = false;
    public GameObject OccludeObject = null;
    public bool ShowOccludeObject = false;
    // public Camera EC_Near = null; // for keeping track of near plane  
};

[System.Serializable]
public class PCFlags : Flags
{
    // Perspective Coordinate (PC) Space
    public Vector3 VPoint = Vector3.zero;
    public bool UseWCVPoint = false;
};