Shader "552_Shaders/ShadowCaster_Phong"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "DepthValue"="InWC"}
        LOD 100

        Pass // normal phong pass
        {
            CGPROGRAM
            #pragma vertex VertexProgram
            #pragma fragment FragmentProgram

            // 
            #include "MyInclude/MyStruct.cginc"
            #include "MyInclude/MyPhongVS.cginc"
            #include "MyInclude/MyPhongFS.cginc"
            ENDCG
        }
    }
}
