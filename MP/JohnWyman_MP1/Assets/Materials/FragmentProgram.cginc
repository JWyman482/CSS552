#pragma fragment frag

#include "UnityCG.cginc"

struct OutputFromFragmentShader // Vertex processor to Fragment processor - output
{
    float4 color : SV_Target;
};

OutputFromFragmentShader frag(DataForFragmentShader i) // Fragment processor. Was a fixed4  fixed4 is 16 bit. SV_Target is default target - display.
{
    OutputFromFragmentShader o;
    o.color = i.color;
    return o;
}