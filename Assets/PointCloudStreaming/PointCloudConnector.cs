using System;
using System.Buffers;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

using NativeWebSocket;

using MessagePack;
using MessagePack.Formatters;

[MessagePackObject]
public class PCMessage
{
    [Key("size")]
    public int size { get; set; }

    [Key("pcl")]
    public byte[] pcl { get; set; }

    [Key("pcl_color")]
    public byte[] pcl_color { get; set; }
}

public class PointCloudConnector : MonoBehaviour
{
    WebSocket websocket;

    public string URL = "ws://localhost:8765";

    private int size;
    private Vector3[] pcl;
    private Color32[] pcl_color;

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
            var lz4Options = MessagePackSerializerOptions.Standard.WithCompression(MessagePackCompression.Lz4BlockArray);
            PCMessage pc = MessagePackSerializer.Deserialize<PCMessage>(bytes, lz4Options);

            this.size = pc.size;
            this.pcl = MemoryMarshal.Cast<byte, Vector3>(pc.pcl).ToArray();
            this.pcl_color = MemoryMarshal.Cast<byte, Color32>(pc.pcl_color).ToArray();
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

}
