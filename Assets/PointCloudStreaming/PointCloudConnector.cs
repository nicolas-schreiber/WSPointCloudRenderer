using System;
using System.Buffers;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

using NativeWebSocket;

using MessagePack;
using MessagePack.Formatters;
using MessagePack.Resolvers;
using PointCloudStreaming.Resolvers;

[MessagePackObject]
public class PCMessage
{
    [Key("size")]
    public int size { get; set; }

    [Key("pcl")]
    public byte[] pcl { get; set; }

    [Key("pcl_color")]
    public byte[] pcl_color { get; set; }

    [Key("point_size")]
    public float point_size { get; set; }
}

[MessagePackObject]
public class ImageMessage
{
    [Key("data")]
    public byte[] data { get; set; }
}

public class PointCloudConnector : MonoBehaviour
{
    WebSocket websocket;

    public string URL = "ws://localhost:8765";

    private int size;
    private Vector3[] pcl;
    private Color32[] pcl_color;
    private float point_size;

    public byte[] img_data;

    static bool serializerRegistered = false;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    static void Initialize()
    {
        if (!serializerRegistered)
        {
            StaticCompositeResolver.Instance.Register(
                 PointCloudStreaming.Resolvers.GeneratedResolver.Instance,
                 MessagePack.Resolvers.StandardResolver.Instance
            );

            var option = MessagePackSerializerOptions.Standard.WithResolver(StaticCompositeResolver.Instance);

            MessagePackSerializer.DefaultOptions = option;
            serializerRegistered = true;
        }
    }

    // Start is called before the first frame update
    async void Start()
    {
        websocket = new WebSocket(URL);

        websocket.OnOpen += () =>
        {
            Debug.Log("Connection open!");
        };

        websocket.OnError += (e) =>
        {
            Debug.Log("Error! " + e);
        };

        websocket.OnClose += (e) =>
        {
            Debug.Log("Connection closed!");
        };

        websocket.OnMessage += (bytes) =>
        {
            int length = (new MessagePack.MessagePackReader(bytes)).ReadMapHeader();
            if(length == 4) {
                PCMessage pc = MessagePackSerializer.Deserialize<PCMessage>(bytes);

                this.size = pc.size;
                this.pcl = MemoryMarshal.Cast<byte, Vector3>(pc.pcl).ToArray();
                this.pcl_color = MemoryMarshal.Cast<byte, Color32>(pc.pcl_color).ToArray();
                this.point_size = pc.point_size;
            } else if (length == 1) {
                ImageMessage img = MessagePackSerializer.Deserialize<ImageMessage>(bytes);

                this.img_data = img.data;
            } else {
                Debug.Log("Message type not recognized");
            }
        };

        await websocket.Connect();
    }

    void Update()
    {
#if !UNITY_WEBGL || UNITY_EDITOR
        websocket.DispatchMessageQueue();
#endif
    }

    async void SendWebSocketMessage()
    {
        if (websocket.State == WebSocketState.Open)
        {
            // Sending bytes
            await websocket.Send(new byte[] { 10, 20, 30 });

            // Sending plain text
            await websocket.SendText("plain text message");
        }
    }

    private async void OnApplicationQuit()
    {
        await websocket.Close();
    }

    public Vector3[] GetPCL()
    {
        return pcl;
    }

    public Color32[] GetPCLColor()
    {
        return pcl_color;
    }

    public int GetSize()
    {
        return size;
    }

    public float getPointSize()
    {
        return point_size;
    }

    public byte[] GetImgData()
    {
        return img_data;
    }

#if UNITY_EDITOR
    [UnityEditor.InitializeOnLoadMethod]
    static void EditorInitialize()
    {
        Initialize();
    }
#endif

}
