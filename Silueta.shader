// This two-pass shader renders a silhouette on top of all other geometry when occluded.
Shader "Custom/Silueta" {
	Properties {
		_MainTex("Main Texture", 2D) = "white" { }
		_SiluetaColor("Silueta Color", Color) = (0.0, 0.0, 0.0, 1.0)
	}
	
	SubShader {
		// Render queue +1 to render after all solid objects
		Tags { "Queue" = "Geometry+1" "RenderType"="Opaque" }
		
		Pass {
			// Don't write to the depth buffer for the silhouette pass
			ZWrite Off
			ZTest Always
		
			// First Pass: Silueta
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			float4 _SiluetaColor;
			
			struct vertInput {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			
			struct fragInput {
				float4 pos:SV_POSITION;
			};
			
			fragInput vert(vertInput i) {
				fragInput o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				return o;
			}  
			
			float4 frag(fragInput i) : COLOR {
				return _SiluetaColor;
			}
			
			ENDCG
		}
		
		// Second Pass: Standard
		CGPROGRAM
			
		#pragma surface surf Lambert
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		
		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutput o) {
			float4 col = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = col.rgb;
		}
		
		ENDCG
	}
	
	FallBack "Diffuse"
}
