using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageRenderer : MonoBehaviour
{
    public MeshRenderer meshRenderer;

    public PointCloudConnector subscriber;

    private Texture2D texture2D;
    private byte[] imageData;

    void Start()
    {
        texture2D = new Texture2D(1, 1);
        meshRenderer.material = new Material(Shader.Find("Standard"));
    }

    private void Update()
    {   
        imageData = subscriber.GetImgData();
        if (imageData != null)
            ProcessMessage();
    }

    private void ProcessMessage()
    {
        Debug.Log("B");
        texture2D.LoadImage(imageData);
        texture2D.Apply();
        meshRenderer.material.SetTexture("_MainTex", texture2D);
    }

}