//UNITY_SHADER_NO_UPGRADE 

Shader "Custom/CubesShader" 
{
	Properties
	{
		_PointSize("PointSize", Range(0, 0.1)) = 0.01
	}

	SubShader
	{
	Pass
	{
		// Blend SrcAlpha OneMinusSrcAlpha // Traditional transparency
		Tags {"RenderType"="Opaque"}

		LOD 200

		CGPROGRAM
#pragma target 5.0
#pragma vertex VS_Main
#pragma fragment FS_Main
#pragma geometry GS_Main
#include "UnityCG.cginc" 

		// **************************************************************
		// Data structures												*
		// **************************************************************
        struct VS_INPUT
        {
            float4 pos : POSITION;
            float4 col : COLOR;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

		struct GS_INPUT
		{
			float4	pos		: POSITION;
			float4	col		: COLOR;
            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
		};

		struct FS_INPUT
		{
			float4	pos		: POSITION;
			float4  col		: COLOR;
            UNITY_VERTEX_OUTPUT_STEREO 
		};


		// **************************************************************
		// Vars															*
		// **************************************************************

		float _PointSize;

		// **************************************************************
		// Shader Programs												*
		// **************************************************************

		// Vertex Shader ------------------------------------------------
		GS_INPUT VS_Main(VS_INPUT v)
		{
			GS_INPUT output = (GS_INPUT)0;

            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_OUTPUT(GS_INPUT, output);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
            UNITY_TRANSFER_INSTANCE_ID(v, output);


			output.pos = v.pos;
			output.col = v.col;

			return output;
		}

		// Geometry Shader -----------------------------------------------------
		[maxvertexcount(24)]
		void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
		{
            DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(p[0]);

			float4 quad[24];
            // Front
			quad[0]  = float4(  0.5, -0.5,  0.5, 0) * _PointSize; 
			quad[1]  = float4(  0.5,  0.5,  0.5, 0) * _PointSize;
			quad[2]  = float4( -0.5, -0.5,  0.5, 0) * _PointSize;
			quad[3]  = float4( -0.5,  0.5,  0.5, 0) * _PointSize;

            // Back
			quad[4]  = float4( -0.5,  0.5, -0.5, 0) * _PointSize;
			quad[5]  = float4(  0.5,  0.5, -0.5, 0) * _PointSize;
			quad[6]  = float4( -0.5, -0.5, -0.5, 0) * _PointSize;
            quad[7]  = float4(  0.5, -0.5, -0.5, 0) * _PointSize;
            
            // Top
            quad[8]  = float4(  0.5,  0.5, -0.5, 0) * _PointSize;
			quad[9]  = float4( -0.5,  0.5, -0.5, 0) * _PointSize;
			quad[10] = float4(  0.5,  0.5,  0.5, 0) * _PointSize;
			quad[11] = float4( -0.5,  0.5,  0.5, 0) * _PointSize;
			
            // Bottom
            quad[15] = float4(  0.5, -0.5, -0.5, 0) * _PointSize;
			quad[14] = float4(  0.5, -0.5,  0.5, 0) * _PointSize;
			quad[13] = float4( -0.5, -0.5, -0.5, 0) * _PointSize;
			quad[12] = float4( -0.5, -0.5,  0.5, 0) * _PointSize;

            // Left
			quad[16]  = float4( 0.5, -0.5,  0.5, 0) * _PointSize;
			quad[17]  = float4( 0.5, -0.5, -0.5, 0) * _PointSize;
			quad[18]  = float4( 0.5,  0.5,  0.5, 0) * _PointSize;
            quad[19]  = float4( 0.5,  0.5, -0.5, 0) * _PointSize;
            
            // Right
			quad[20]  = float4( -0.5,  0.5,  0.5, 0) * _PointSize;
            quad[21]  = float4( -0.5,  0.5, -0.5, 0) * _PointSize;
			quad[22]  = float4( -0.5, -0.5,  0.5, 0) * _PointSize;
			quad[23]  = float4( -0.5, -0.5, -0.5, 0) * _PointSize;

			FS_INPUT pIn;;
			pIn.col = p[0].col;
            UNITY_TRANSFER_VERTEX_OUTPUT_STEREO (p[0], pIn);
            for(int i = 0; i < 24; i++) {
			    pIn.pos = UnityObjectToClipPos(p[0].pos + quad[i]);
			    triStream.Append(pIn);
				
                if((i + 1) % 4 == 0) triStream.RestartStrip();
            }
		}

		// Fragment Shader -----------------------------------------------
		float4 FS_Main(FS_INPUT input) : COLOR
		{
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
			return float4(input.col.z, input.col.y, input.col.x, input.col.w);
		}

		ENDCG
	}
	}
}
