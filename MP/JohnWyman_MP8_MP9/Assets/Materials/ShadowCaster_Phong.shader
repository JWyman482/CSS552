Shader "552_Shaders/ShadowCaster_Phong"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
        Tags { "RenderType"="Opaque" "DepthValue"="InWC"}
        LOD 100
        Cull Back

        Pass // light0: point light shadow pass
        {
            Blend SrcAlpha DstAlpha, Zero One
                                    // do not let src alpha affect how shadow is received

            // https://docs.unity3d.com/Manual/SL-Stencil.html
            // Compare with 1, if equal, increase (to avoid writing again)
            Stencil {
                Ref 1
                Comp Equal
                // Pass IncrSat
            }
    
            CGPROGRAM
            #include "ShadowCasters/PointLight0_Caster.cginc"
            ENDCG
        }

        Pass // light1: directional light shadow pass
        {
            Blend SrcAlpha DstAlpha, Zero One

            Stencil {
                Ref 1  // Pass one may have written to this already
                Comp Equal
                // Pass IncrSat
            }
            CGPROGRAM
            #include "ShadowCasters/DirLight1_Caster.cginc"
            ENDCG
        }

        Pass // light2: spotlight  shadow pass
        {
            Blend SrcAlpha OneMinusSrcAlpha, Zero One

            Stencil {
                Ref 1  // Previous two passes may have written on this
                Comp Equal
                // Pass IncrSat
            }
            CGPROGRAM
            #include "ShadowCasters/SpotLight2_Caster.cginc"
            ENDCG
        }

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
