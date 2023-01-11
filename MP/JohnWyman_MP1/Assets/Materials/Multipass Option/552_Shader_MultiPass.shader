Shader "552_Shaders/552_Shader_Multipass"
{
    Properties
    {
        _Color("My Color", Color) = (1, 0, 0, 1)
    }

        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #include "VertexProgram_Multipass.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #include "FragmentProgram_Multipass.cginc"
            ENDCG
        }
    }
}
