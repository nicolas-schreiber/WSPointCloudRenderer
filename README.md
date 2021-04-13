# HL2 Teleop (WS PointCloud Streamer) for Hololens using Unity

This package contains the general code for streaming pointclouds from a Websocket Server, I am currently also adding displaying an video stream.

## How to:
* Open this package using Unity.
* Install NativeWebsocket via UPM: https://github.com/endel/NativeWebSocket
* Install MsgPack via unitypackage: https://github.com/neuecc/MessagePack-CSharp

## Files:
### PointCloudStreaming/PointCloudConnector.cs
This File connects to a WS Server, expecting PointCloud Messages (or soon Image Messages). Just add it to an game object and fill in the required information. 

### PointCloudStreaming/StereoPointCloudRenderer.cs
* This file attempts to display the PointCloud from a PointCloudConnector.
* Fill in the required information. <br/> (The unity point size is only used if the pointsize of the message is smaller than 0)
* Choose a Shader from the `Shader` folder. (I recommend `CubesFromQuads.shader`)

### WebSocketTest: 
Example files showing necessary format for Unity.

## Charuco or Aruco based Positioning of PointCloud
You can simply use this repository (where I added Charuco detection), to detect the fiducial in the camera view. As modified object you can simply use the PointCloud of the HL2 Teleop Unity package.