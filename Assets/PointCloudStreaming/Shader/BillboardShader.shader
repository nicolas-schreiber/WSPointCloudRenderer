Shader "Custom/Billboard Particles"
{
	Properties
	{
		_SizeMul("Size Multiplier", Float) = 1
	}

		SubShader
		{
			Pass
			{
			// 	Cull Back
			// 	Lighting Off
			// 	Zwrite Off

			// //Blend SrcAlpha OneMinusSrcAlpha
			// //Blend One OneMinusSrcAlpha
			// Blend One One
			// //Blend OneMinusDstColor One

			LOD 200

			Tags
			{
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
			}

			CGPROGRAM

			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			float _SizeMul;
			
			StructuredBuffer<float3> positions;
            StructuredBuffer<uint> colors;
			StructuredBuffer<float3> quad;

			struct v2f
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float4 col : COLOR;
			};

			v2f vert(uint id : SV_VertexID, uint inst : SV_InstanceID)
			{
				v2f o;

				float3 q = quad[id] * _SizeMul;
				float4 p = float4(positions[inst], 1.0f);
				
				o.pos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, p) + float4(q, 0.0f));

				o.uv = q + 0.5f;

				uint col32 = colors[inst];
                uint a = (col32 >> 24) & 0xff; // 0x[AA]bbggrr
                uint r = (col32 >> 16) & 0xff; // 0xaa[BB]ggrr
                uint g = (col32 >> 8) & 0xff;  // 0xaabb[GG]rr
                uint b = (col32 >> 0) & 0xff;  // 0xaabbgg[RR] 
				o.col = float4(r, g, b, 255) / 255.0;

				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				return i.col;
			}

			ENDCG
		}
		}
}