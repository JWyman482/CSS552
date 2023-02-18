using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowReceiver : MonoBehaviour
{
    public Transform p;


    // Start is called before the first frame update
    void Start()
    {
        Debug.Assert(p != null);
    }

    // Update is called once per frame
    void Update()
    {
        
        // dot(n^, p) - D
        Vector3 n = this.transform.up;
        float D = Vector3.Dot(n, transform.localPosition);
        if (Vector3.Dot(n, p.localPosition) - D < float.Epsilon)
            Debug.Log("Invalid");
        if (Vector3.Dot(n, p.localPosition) - D > float.Epsilon)
            Debug.Log("Somethiong else");


    }
}
