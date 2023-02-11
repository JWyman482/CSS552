using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialLoader : MonoBehaviour
{
    public float Ka = 0.2f;
    public Color Ambient = new Color(0.1f, 0.1f, 0.1f, 1.0f); 
    public float Kd = 0.8f;
    public Color Diffuse = new Color(0.6f, 0.8f, 0.7f, 1.0f);
    Material mMat = null;

    public Texture2D DiffuseTexture = null;

    // Start is called before the first frame update
    void Start()
    {
        mMat = gameObject.GetComponent<MeshRenderer>().material;
        mMat.SetTexture("_MainTex", DiffuseTexture);
    }

    Vector4 C2f(Color c, float s) {
        return new Vector4(c.r*s, c.g*s, c.b*s, c.a);
    }

    // Update is called once per frame
    void Update()
    {
        // Debug.Log("mMat=" + mMat);
        mMat.SetVector("_Ka", C2f(Ambient, Ka));
        mMat.SetVector("_Kd", C2f(Diffuse, Kd));
    }
}
