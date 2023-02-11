using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialLoader : MonoBehaviour
{
    public float AmbientIntensityKa = 0.2f;
    public Color AmbientColor = new Color(0.1f, 0.1f, 0.1f, 1.0f);
    public float DiffuseIntensityKd = 0.8f;
    public Color DiffuseColor = new Color(0.6f, 0.8f, 0.7f, 1f);
    public Texture DiffuseTexture = null;
    public float n = 1f;


    private Material mat;
    // Start is called before the first frame update
    void Start()
    {
        mat = transform.GetComponent<Renderer>().material;

        if (DiffuseTexture != null)
        {
            mat.SetTexture("_MyTex", DiffuseTexture);
        }
    }

    // Update is called once per frame
    void Update()
    {
        // Loads Ka, Kd, Ambient and Diffuse to the shader
        Color Ka = AmbientIntensityKa * AmbientColor;
        Color Kd = DiffuseIntensityKd * DiffuseColor;

        mat.SetColor("_Ka", Ka);
        mat.SetColor("_Kd", Kd);

        // DO NOT: load Texture to the shader per update: TOO EXPENSIVE!
    }
}
