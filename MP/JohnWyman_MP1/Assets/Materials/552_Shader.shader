Shader "552_Shaders/552_Shader"
{
    Properties
    {
        _Color("My Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #include "VertexProgram.cginc"
            #include "FragmentProgram.cginc"
            ENDCG
        }
    }
}
