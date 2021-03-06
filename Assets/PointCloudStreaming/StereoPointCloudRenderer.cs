using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class StereoPointCloudRenderer : MonoBehaviour
{
    public PointCloudConnector subscriber;

    // Mesh stores the positions and colours of every point in the cloud
    // The renderer and filter are used to display it
    Mesh mesh;
    MeshRenderer meshRenderer;
    MeshFilter mf;
    public Shader shader;

    // The size, positions and colours of each of the pointcloud
    public float pointSize = 1f;
    

    [Header("MAKE SURE THESE LISTS ARE MINIMISED OR EDITOR WILL CRASH")]
    private Vector3[] positions = new Vector3[] { new Vector3(0, 0, 0), new Vector3(0, 1, 0) };
    private Color32[] colours = new Color32[] { new Color32(255, 255, 255, 255), new Color32(255, 255, 255, 255) };

    public Transform offset; // Put any gameobject that faciliatates adjusting the origin of the pointcloud in VR. 

    void Start()
    {
        // Give all the required components to the gameObject
        meshRenderer = gameObject.AddComponent<MeshRenderer>();
        mf = gameObject.AddComponent<MeshFilter>();
        if(!shader) shader = Shader.Find("Custom/CubesShader");
        meshRenderer.material = new Material(shader);
        mesh = new Mesh
        {
            // Use 32 bit integer values for the mesh, allows for stupid amount of vertices (2,147,483,647 I think?)
            indexFormat = UnityEngine.Rendering.IndexFormat.UInt32
        };

        transform.position = offset.position;
        transform.rotation = offset.rotation;
    }

    void UpdateMesh()
    {   
        positions = subscriber.GetPCL();
        colours = subscriber.GetPCLColor();
        if (positions == null)
        {   
            return;
        }

        mesh.Clear();
        mesh.vertices = positions;
        mesh.colors32 = colours;

        int[] indices = new int[positions.Length];

        for (int i = 0; i < positions.Length; i++)
        {
            indices[i] = i;
        }

        mesh.SetIndices(indices, MeshTopology.Points, 0);
        mf.mesh = mesh;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = offset.position;
        transform.rotation = offset.rotation;
        float msgPointSize = subscriber.getPointSize();
        meshRenderer.material.SetFloat("_PointSize", msgPointSize < 0 ? pointSize : msgPointSize );
        UpdateMesh();
    }
}
