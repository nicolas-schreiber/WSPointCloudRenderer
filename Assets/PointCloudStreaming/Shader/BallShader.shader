//UNITY_SHADER_NO_UPGRADE 

Shader "Custom/BallBillboardShader" 
{
	Properties
	{
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _PointSize("PointSize", Range(0, 0.1)) = 0.01
	}

	SubShader
	{
	Pass
	{
        Cull Back
        Lighting Off
        Zwrite Off

        //Blend SrcAlpha OneMinusSrcAlpha
        //Blend One OneMinusSrcAlpha
        Blend One One
        //Blend OneMinusDstColor One

        LOD 200

        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

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
			float2   uv     : TEXCOORD0;
            UNITY_VERTEX_OUTPUT_STEREO 
		};


		// **************************************************************
		// Vars															*
		// **************************************************************

		float _PointSize;
		uniform sampler2D _MainTex;

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


			output.pos = mul(unity_ObjectToWorld, v.pos);
			output.col = v.col;

			return output;
		}

		// Geometry Shader -----------------------------------------------------
		[maxvertexcount(4)]
		void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
		{
            DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(p[0]);

			float4 quad[4];
			quad[0] = float4(  0.5, -0.5, 0, 0) * _PointSize;
			quad[1] = float4(  0.5,  0.5, 0, 0) * _PointSize;
			quad[2] = float4( -0.5, -0.5, 0, 0) * _PointSize;
			quad[3] = float4( -0.5,  0.5, 0, 0) * _PointSize;

			float4 v[4];
			v[0] = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, p[0].pos) + quad[0]);
			v[1] = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, p[0].pos) + quad[1]);
			v[2] = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, p[0].pos) + quad[2]);
			v[3] = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, p[0].pos) + quad[3]);

			FS_INPUT pIn;;
			pIn.col = p[0].col;
            UNITY_TRANSFER_VERTEX_OUTPUT_STEREO (p[0], pIn);

			pIn.pos = v[0];
            pIn.uv = quad[0] + 0.5f;
			triStream.Append(pIn);

			pIn.pos = v[1];
            pIn.uv = quad[1] + 0.5f;
			triStream.Append(pIn);

			pIn.pos = v[2];
            pIn.uv = quad[2] + 0.5f;
			triStream.Append(pIn);

			pIn.pos = v[3];
            pIn.uv = quad[3] + 0.5f;
			triStream.Append(pIn);
		}

		// Fragment Shader -----------------------------------------------
		float4 FS_Main(FS_INPUT input) : COLOR
		{
            UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
			return tex2D(_MainTex, input.uv) * input.col; //float4(input.col.z, input.col.y, input.col.x, input.col.w);
		}

		ENDCG
	}
	}
}
