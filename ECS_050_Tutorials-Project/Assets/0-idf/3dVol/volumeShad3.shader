Shader "Unlit/volumeShad3"  // ref https://github.com/mattatz/unity-volume-rendering/blob/master/Assets/VolumeRendering/Shaders/VolumeRendering.cginc
{
	Properties
	{
		[Header(Rendering)]
		_Volume("Volume", 3D) = "" {}
		_Iteration("Iteration", Int) = 10

		[MaterialToggle] 
		_Dissolve("Dissolve", Float) = 0

		[Header(Ranges)]
		_MinX("MinX", Range(0, 1)) = 0.0
		_MaxX("MaxX", Range(0, 1)) = 1.0
		_MinY("MinY", Range(0, 1)) = 0.0
		_MaxY("MaxY", Range(0, 1)) = 1.0
		_MinZ("MinZ", Range(0, 1)) = 0.0
		_MaxZ("MaxZ", Range(0, 1)) = 1.0
	}
		SubShader
		{
				HLSLINCLUDE
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  //com.unity.render-pipelines.universal@12.1.7
					CBUFFER_START(UnityPerMaterial)
					
					int _Iteration;
					float _Dissolve;
					float _MinX;
					float _MaxX;
					float _MinY;
					float _MaxY;
					float _MinZ;
					float _MaxZ;
					 

			
					TEXTURE3D(_Volume);
					SAMPLER(sampler_Volume);		
				CBUFFER_END

				ENDHLSL

		Tags
		{ "Queue" = "Transparent"
		  "RenderType" = "Transparent"
		}
		Cull Front
		ZWrite Off
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off

		Pass
		{
			//CGPROGRAM

			HLSLPROGRAM

			// Pragmas
			#pragma target 4.5
			#pragma exclude_renderers gles gles3 glcore
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma multi_compile _ DOTS_INSTANCING_ON
			//#pragma vertex vert
			//#pragma fragment frag

			
			#pragma vertex vert
			#pragma fragment frag

		//	#include "Packages/CustomIDF/UnityCG.cginc"
		//	#include "UnityShaderVariables.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 localPos : TEXCOORD0;
			};

//			sampler3D _Volume;
//			int _Iteration;
//			fixed _MinX, _MaxX, _MinY, _MaxY, _MinZ, _MaxZ;
//			fixed _Dissolve;


		//	[unroll(5)] // # Of iterations goes to max 5!
			float4 sample(float3 pos) // clip the volume
			{
				//fixed x = step(pos.x, _MaxX) * step(_MinX, pos.x);
				//fixed y = step(pos.y, _MaxY) * step(_MinY, pos.y);
				//fixed z = step(pos.z, _MaxZ) * step(_MinZ, pos.z);
				float x = step(pos.x, _MaxX) * step(_MinX, pos.x);
				float y = step(pos.y, _MaxY) * step(_MinY, pos.y);
				float z = step(pos.z, _MaxZ) * step(_MinZ, pos.z);
				
				return tex3Dlod(sampler_Volume, float4(pos, 0)) * x * y * z; //* cambio
				//return tex3D(sampler_Volume, pos) * x * y * z; // original
			}

			v2f vert(appdata v)
			{
				v2f o;
				//o.vertex = UnityObjectToClipPos(v.vertex);  // **************************** OJO CON ESTA LINEA *****************************
			
			 
				 o.vertex = mul(UNITY_MATRIX_MVP, float4(v.vertex));//*********** nueva
			//  o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);//*********** nueva 
			  //*********** nueva
				o.localPos = v.vertex;
				return o;
			}


//fixed4 frag(v2f i) : SV_Target
			float4 frag(v2f i) : SV_Target
			{
				//float3 rayOrigin = i.localPos + 0.5;
			float3 rayOrigin = i.localPos.xyz + 0.5 ; //***++++ tests 


			//float3 rayDir = ObjSpaceViewDir(i.localPos); //************************ ojo con esta
	//	float3 rayDir = normalize(mul ((float3x3)UNITY_MATRIX_MV, i.vertex.xyz)); //*** nueva --- 
			 float3 rayDir = normalize(mul ((float3x3)UNITY_MATRIX_MV, i.localPos.xyz)); //**NEW
    
	  // float3 rayDir = mul(unity_WorldToObject, float4(normalize(i.vectorToSurface), 1));//****NEW
	// float3 rayDir = normalize(ObjSpaceViewDir(i.localPos)); //*** nueva ---

				float rayLength = length(rayDir);
				rayDir = normalize(rayDir);

				float4 finalColor = 0.0;
				float t = 1.732 / _Iteration; // step size for one iteration

				[loop]
				for (int j = 0; j < _Iteration; ++j)
				{
					float step = t * j;
					if (step > rayLength) // do not render volume that is behind the camera
						break;
					float3 curPos = rayOrigin;
					if (_Dissolve) {
						step *= (1 + sin(_Time.z / 2))*0.5;
					}
		
					curPos += rayDir * step;
					float4 color = sample(curPos); // original

					//float4 color = float4(curPos,0); ///*** cambio


					// use back to front composition
					finalColor.rgb = color.a * color.rgb + (1-color.a) * finalColor.rgb;
					finalColor.a = color.a + (1 - color.a) * finalColor.a;
					if (finalColor.a > 1) break;
				}
				return finalColor;

			}
			//ENDCG
			ENDHLSL

		}
	}
}
