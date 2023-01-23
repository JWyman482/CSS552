Shader "552_Shaders/552_MP3_Shader"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    Properties
    {
       // world space 
        _UserControl("User Control", Integer) = 0  // 1 is user control 

        // Object Space
        _OCWeight("OC Weight", float) = 1
        _OCVPoint("OC Vanishing Pt", Vector) = (0, 0, 0)

        // World space control
        _WCWeight("WC Weight", float) = 1  // 
        _WCRate("WC Rate", float) = 1 // 
        _WCVPoint("Vanishing Point", Vector) = (0, 0, 0)  // WC Vanishing point

        // Eye Coordinate control
         _ECNear("Near", float) = 0.3  // Near point distance of the camera
                  // In Eye Coordinate: Center of Window is (0, 0, -Near)
        _ECWeight("EC Weight", float) = 1

        // Projected Coordinate control
        _PCWeight("PC Weight", float) = 1
        _PCVPoint("PC Vanishing Pt", Vector) = (0, 0, 0)
        

        _Color("Color", Color) = (0.8, 0.8, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull off
        Pass  // Vanishing in object coordinate space
        {
            Name "OC Pass"
            CGPROGRAM
                #include "OCPass.cginc"
            ENDCG
        }

        Pass  // Vanishing towards the world point
        {
            Name "WC Pass"
            CGPROGRAM
                #include "WCPass.cginc"
            ENDCG
        }

        Pass // Vanishing in eye space
        {
            Name "EC Pass"
            CGPROGRAM
                #include "ECPass.cginc"
            ENDCG
        }
        
        Pass  // Vanishing towards the center of window in projected coordinate
        {
            Name "PC Pass"
            CGPROGRAM
                #include "PCPass.cginc"
            ENDCG
        }

        Pass // Show original in white
        {
            Name "Base Pass"
            CGPROGRAM
                #include "BasePass.cginc"
            ENDCG
        } // Pass
    } // SubShader
}
