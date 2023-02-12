using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialLoader : MonoBehaviour
{
    public bool LookAtMe = false;

    public float Ka = 0.2f;
    public Color Ambient = new Color(0.1f, 0.1f, 0.1f, 1.0f);
    
    public float Kd = 0.8f;
    public Color Diffuse = new Color(0.6f, 0.8f, 0.7f, 1.0f);
    public Texture2D DiffuseTexture = null;
    
    public float Ks = 1f;
    public Color Specular = new Color(0.6f, 0.8f, 0.7f, 1.0f);
    public float n = 1;

    Material mMat = null;
    GameObject highlight;
    // Start is called before the first frame update
    void Start()
    {
        highlight = GameObject.Find("Highlight Point");
        mMat = gameObject.GetComponent<MeshRenderer>().material;
        mMat.SetTexture("_MainTex", DiffuseTexture);
    }

    Vector4 C2f(Color c, float s) {
        return new Vector4(c.r*s, c.g*s, c.b*s, c.a);
    }

    // Update is called once per frame
    void Update()
    {
        if (LookAtMe)
        {
            highlight.transform.localPosition = transform.localPosition;
            LookAtMe = !LookAtMe;
        }
        // Debug.Log("mMat=" + mMat);
        mMat.SetVector("_Ka", C2f(Ambient, Ka));
        mMat.SetVector("_Kd", C2f(Diffuse, Kd));
        mMat.SetVector("_Ks", C2f(Specular, Ks));
        mMat.SetFloat("_s", n);
    }
}
