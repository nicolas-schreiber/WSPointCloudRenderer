
Shader "Custom/PointsOnlyShader"
{
	Properties
	{
		_PointSize("Point Size", Float) = 1
	}

	SubShader
	{
		Pass
		{

			LOD 200

			CGPROGRAM
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct VertexInput
			{
				float4 v : POSITION;
				float4 color: COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID //Insert
			};

			struct VertexOutput
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
				float size : PSIZE;
				UNITY_VERTEX_OUTPUT_STEREO //Insert
			};

			uniform float _PointSize = 1;

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;

				UNITY_SETUP_INSTANCE_ID(v); //Insert
				UNITY_INITIALIZE_OUTPUT(VertexOutput, o); //Insert
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

				o.pos = UnityObjectToClipPos(v.v);
				o.size = _PointSize;
				o.col = v.color;

				return o;
			}

			UNITY_DECLARE_SCREENSPACE_TEXTURE(_MainTex); //Insert

			float4 frag(VertexOutput o) : COLOR
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(o); //Insert
				UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, o.col);

				return o.col;
			}

			ENDCG
		}
	}
}
