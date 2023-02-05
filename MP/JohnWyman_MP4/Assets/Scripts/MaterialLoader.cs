using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialLoader : MonoBehaviour
{
    public float Ka = 0.2f;
    public Color Ambient = Color.black; 
    public float Kd = 0.2f;
    public Color Diffuse = Color.white;
    public Texture DiffuseTexture = null;

    private Material myMat;

    // Start is called before the first frame update
    void Start()
    {
        
        if (DiffuseTexture != null) Shader.SetGlobalTexture("_MyTex", DiffuseTexture);
        myMat = transform.GetComponent<Renderer>().material;
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector4 Kaa = Ambient * Ka;
        Vector4 Kdd = Diffuse * Kd;
        // Loads Ka, Kd, Ambient and Diffuse to the shader
        myMat.SetColor("_Ka", Kaa);
        myMat.SetColor("_Kd", Kdd);
        // myMat.SetFloat("_Ka", Ka);
        // myMat.SetFloat("_Kd", Kd);
        // Shader.SetGlobalFloat("_Ka", Ka);
        // Shader.SetGlobalFloat("_Kd", Kd);
        // Shader.SetGlobalVector("_Ambient", Ambient);
        // Shader.SetGlobalVector("_Diffuse", Diffuse);
        // DO NOT: load Texture to the shader per update: TOO EXPENSIVE!
    }
}
