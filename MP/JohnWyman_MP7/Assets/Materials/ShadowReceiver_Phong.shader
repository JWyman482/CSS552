Shader "552_Shaders/ShadowReceiver_Phong"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ka ("Ambient", Color) = (0.1, 0.1, 0.1, 1)   // from MyMaterial.cginc
        _Kd ("Diffuse", Color) = (0.7, 0.8, 0.6, 1)
        _Ks ("Specular", Color) = (0.1, 0.1, 0.3, 1)
        _Specularity("n", float) = 1.0

            // Global control on LightLoader
        // _ShaderMode("Mode", int) = 0
            // Bits: On (yes) or Off (no)
            //  All off: returns black
            //   0: Texture   (1)
            //   1: Ambient   (2)
            //   2: Diffuse   (4)
            //   3: Specular  (8)
            //   4: Distance Attenuation (16)
            //   5: Angular Attenuation (32)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" 
                "Queue" = "Geometry-1"    // make sure to render _BEFORE_ the rest (ProjectShadow shaders)
            }
        LOD 100
        Cull off

        Pass
        {
            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Always write a 1 into the Stencil
            Stencil {
                Ref 1
                Comp Always
                Pass Replace
            }
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
