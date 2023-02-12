#ifndef MY_MATERIAL
#define MY_MATERIAL

// In the editor: 
//      LoadMaterial script should be on each object if want to override the global values

float4 _Ka, _Kd, _Ks;  // xyz is rbg, w is the strength
float _s; // Phong shininess exponent. "n" on MaterialLoader.cs

#endif // MY_MATERIAL