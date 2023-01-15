Shader "552_Shaders/MP2_Shader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _XType("XType: 0 = Cos, 1 = Sin", Integer) = 1
        _ZType("ZType: 0 = Cos, 1 = Sin", Integer) = 1
        _Offset("Y Offset", float) = 1
        _XZBlend("XZBlend", Range(0, 1)) = 1
        _XPeriod("XPeriod", float) = 1.0
        _ZPeriod("ZPeriod", float) = 1.0
        _XAmplitude("XAmplitude", float) = 1.0
        _ZAmplitude("ZAmplitude", float) = 1.0
        _ColorWeight("ColorWeight", Range(0, 1)) = 0
        _XAnimate("XAnimate (0 = no, 1 = yes)", Integer) = 1
        _ZAnimate("ZAnimate (0 = no, 1 = yes)", Integer) = 1

        /*_BitFlag("Function Flag", Integer) = 0*/
        // Bit  False   True    Hex
        // 0    X->Sin  X->Cos  Add 1
        // 1    Z->Sin  Z->Cos  Add 2
        // 2                    4
        // 3    No 2p   2p      8
        // 4    !animX  animX   16
        // 5    !animZ  animZ   32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        cull off

        Pass
        {
            CGPROGRAM
                #include "P1-DrawOriginal.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
                #include "P2-DrawAtOffset.cginc"
            ENDCG
        }
    }
}
