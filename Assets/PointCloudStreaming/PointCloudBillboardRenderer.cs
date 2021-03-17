using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using System.IO;

public class PointCloudBillboardRenderer : MonoBehaviour
{
    public PCConnection subscriber;

    public const int THREAD_COUNT = 256;
    public const int POINT_COUNT = 146061;

    // Mesh stores the positions and colors of every point in the cloud
    // The renderer and filter are used to display it
    Material _material;
    Mesh mesh;
    MeshRenderer meshRenderer;
    MeshFilter mf;


    // The size, positions and colors of each of the pointcloud
    public float pointSize = 1f;
    
    public Transform offset; // Put any gameobject that faciliatates adjusting the origin of the pointcloud in VR. 

    [Header("MAKE SURE THESE LISTS ARE MINIMISED OR EDITOR WILL CRASH")]
    private Vector3[] positions = new Vector3[] { new Vector3(0, 0, 0), new Vector3(0, 1, 0) };
    private Color32[] colors = new Color32[] { new Color32(255, 255, 255, 255), new Color32(255, 255, 255, 255) };

    private int bufferSize = 100096;
    private int groupCount;

    private ComputeBuffer cb_positions;
    private ComputeBuffer cb_colors;
    private ComputeBuffer cb_quad;

    void Start()
    {
        // Give all the required components to the gameObject
        _material = new Material(Shader.Find("Custom/Billboard Particles"));
        // Give all the required components to the gameObject
        meshRenderer = gameObject.AddComponent<MeshRenderer>();
        mf = gameObject.AddComponent<MeshFilter>();
        meshRenderer.material = _material;

        cb_quad = new ComputeBuffer(6, Marshal.SizeOf(typeof(Vector3)));
        cb_quad.SetData(new[]
        {
            new Vector3(-0.5f,0.5f),
            new Vector3(0.5f,0.5f),
            new Vector3(0.5f,-0.5f),
            new Vector3(-0.5f,-0.5f),
            new Vector3(0.5f,-0.5f),
            new Vector3(-0.5f,0.5f)
        });

        groupCount = Mathf.CeilToInt((float)POINT_COUNT / THREAD_COUNT);
        bufferSize = groupCount * THREAD_COUNT;

        Debug.Log(bufferSize);

        cb_positions = new ComputeBuffer(bufferSize, Marshal.SizeOf(typeof(Vector3)), ComputeBufferType.Structured);
        cb_colors = new ComputeBuffer(bufferSize, Marshal.SizeOf(typeof(Color32)), ComputeBufferType.Structured);

        _material.SetBuffer("positions", cb_positions);
        _material.SetBuffer("colors", cb_colors);
        _material.SetBuffer("quad", cb_quad);

        transform.position = offset.position;
        transform.rotation = offset.rotation;
    }

    void OnRenderObject()
    {
        _material.SetBuffer("positions", cb_positions);
        _material.SetBuffer("colors", cb_colors);
        _material.SetBuffer("quad", cb_quad);

        _material.SetPass(0);

        Graphics.DrawProceduralNow(MeshTopology.Quads, 6, POINT_COUNT);
    }

    void UpdateMesh()
    {
        positions = subscriber.GetPCL();
        colors = subscriber.GetPCLColor();
        if (positions == null)
        {   
            return;
        }

        cb_positions.SetData(positions);
        cb_colors.SetData(colors);
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = offset.position;
        transform.rotation = offset.rotation;
        _material.SetFloat("_SizeMul", pointSize);
        UpdateMesh();
    }

    void OnDestroy() 
    {
        cb_positions.Release();
        cb_colors.Release();
        cb_quad.Release();

    }
}
