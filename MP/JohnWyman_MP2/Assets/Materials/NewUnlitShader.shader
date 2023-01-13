Shader "552_Shaders/NewUnlitShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
