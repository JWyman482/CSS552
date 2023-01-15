using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Func_Encode : MonoBehaviour
{
    public bool XDirCos = false;
    public bool ZDirCos = false;
    public bool ShowSecondPass = false;
    public bool AnimateX = false;
    public bool AnimateZ = false;
    public float YOffset = 3f;
    public float XPeriod = 1f;
    public float XAmp = 1f;
    public float ZPeriod = 1f;
    public float ZAmp = 1f;
    public float XZBlend = 1f;
    public Color BaseColor;
    public float ColorWeight = 0.2f;
    public int GlobalBitFlag = 0;
    public Material GlobalMaterial = null;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        GlobalBitFlag = 0;
        if (XDirCos == true)
        {
            GlobalBitFlag += 1;
        }
        if (ZDirCos == true)
        {
            GlobalBitFlag += 2;
        }
        if (ShowSecondPass == true)
        {
            GlobalBitFlag += 8;
        }
        if (AnimateX == true)
        {
            GlobalBitFlag += 16;
        }
        if (AnimateZ == true)
        {
            GlobalBitFlag += 32;
        }
        
        if (GlobalMaterial != null)
        {
            GlobalMaterial.SetColor("_Color", BaseColor);
            GlobalMaterial.SetFloat("_Offset", YOffset);
            GlobalMaterial.SetFloat("_XPeriod", XPeriod);
            GlobalMaterial.SetFloat("_ZPeriod", ZPeriod);
            GlobalMaterial.SetFloat("_XAmplitude", XAmp);
            GlobalMaterial.SetFloat("_ZAmplitude", ZAmp);
            GlobalMaterial.SetFloat("_XZBlend", XZBlend);
            GlobalMaterial.SetFloat("_ColorWeight", ColorWeight);
            Shader.SetGlobalInteger("_BitFlag", GlobalBitFlag);
        }
    }
}
