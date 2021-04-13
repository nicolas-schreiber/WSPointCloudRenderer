Shader "Custom/CubesFromTrisShader" 
{        
    Properties 
    {
        _PointSize("Point Size", Float) = 0.01
    }
    
    SubShader 
    {
        LOD 200
        
        Pass 
        {
            Cull Back
            // Lighting Off
            // Zwrite Off
            
			// Blend One One

			Tags
			{
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
			}
            CGPROGRAM
            
            #pragma target 5.0
            
            #include "UnityCG.cginc"
            
            #pragma vertex VS_Main
            #pragma fragment FS_Main
            #pragma geometry GS_Main
            
            #define TAM 36
            
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
            
            float     _PointSize;            
            
            // ----------------------------------------------------
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
            
            // ----------------------------------------------------
            
            [maxvertexcount(TAM)] 
            // ----------------------------------------------------
            // Using "point" type as input, not "triangle"
            void GS_Main(point GS_INPUT p[1], inout TriangleStream<FS_INPUT> triStream)
            {   
                DEFAULT_UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(p[0]);
                
                float f = _PointSize/2; //half size
                
                const float4 vc[TAM] = { 
                    float4( -f,  f,  f, 0.0f), float4(  f,  f,  f, 0.0f), float4(  f,  f, -f, 0.0f),    //Top                                 
                    float4(  f,  f, -f, 0.0f), float4( -f,  f, -f, 0.0f), float4( -f,  f,  f, 0.0f),    //Top
                    
                    float4(  f,  f, -f, 0.0f), float4(  f,  f,  f, 0.0f), float4(  f, -f,  f, 0.0f),     //Right
                    float4(  f, -f,  f, 0.0f), float4(  f, -f, -f, 0.0f), float4(  f,  f, -f, 0.0f),     //Right
                    
                    float4( -f,  f, -f, 0.0f), float4(  f,  f, -f, 0.0f), float4(  f, -f, -f, 0.0f),     //Front
                    float4(  f, -f, -f, 0.0f), float4( -f, -f, -f, 0.0f), float4( -f,  f, -f, 0.0f),     //Front
                    
                    float4( -f, -f, -f, 0.0f), float4(  f, -f, -f, 0.0f), float4(  f, -f,  f, 0.0f),    //Bottom                                         
                    float4(  f, -f,  f, 0.0f), float4( -f, -f,  f, 0.0f), float4( -f, -f, -f, 0.0f),     //Bottom
                    
                    float4( -f,  f,  f, 0.0f), float4( -f,  f, -f, 0.0f), float4( -f, -f, -f, 0.0f),    //Left
                    float4( -f, -f, -f, 0.0f), float4( -f, -f,  f, 0.0f), float4( -f,  f,  f, 0.0f),    //Left
                    
                    float4( -f,  f,  f, 0.0f), float4( -f, -f,  f, 0.0f), float4(  f, -f,  f, 0.0f),    //Back
                    float4(  f, -f,  f, 0.0f), float4(  f,  f,  f, 0.0f), float4( -f,  f,  f, 0.0f)     //Back
                };
                                
                FS_INPUT v[TAM];
                int i;
                
                // Assign new vertices positions 
                for (i=0;i<TAM;i++) { 
                    v[i].pos = UnityObjectToClipPos(p[0].pos + vc[i]); 
                    v[i].col = p[0].col;
                    UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(p[0], v[i]);
                }
                                
                // Build the cube tile by submitting triangle strip vertices
                for (i=0;i < TAM;i += 3)
                {   
                    triStream.Append(v[i+0]);
                    triStream.Append(v[i+1]);
                    triStream.Append(v[i+2]);    
                    
                    triStream.RestartStrip();
                }
            }
            
            // ----------------------------------------------------
            float4 FS_Main(FS_INPUT input) : COLOR
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                return float4(input.col.z, input.col.y, input.col.x, input.col.w);
            }
            
            ENDCG
        }
    } 
}
