﻿#ifndef VIRTUAL_TEXTURE_FEEDBACK_INCLUDED
#define VIRTUAL_TEXTURE_FEEDBACK_INCLUDED

#include "VirtualTexture.cginc"

#include "UnityCG.cginc"
sampler2D _MainTex;
float4 _MainTex_TexelSize;


fixed4 VTFragFeedback(VTV2f i) : SV_Target
{
	float2 page = floor(i.uv * _VTFeedbackParam.x);

	float2 uv = i.uv * _VTFeedbackParam.y;
	float2 dx = ddx(uv);//uv在屏幕空间x轴上的变化率
	float2 dy = ddy(uv);//uv在屏幕空间y轴上的变化率	，变化率越大，说明模型缩小的越小，所以mipmap level越高，就是下面计算的
	int mip = clamp(int(0.5 * log2(max(dot(dx, dx), dot(dy, dy))) + 0.5 + _VTFeedbackParam.w), 0, _VTFeedbackParam.z);

	return fixed4(page / 255.0, mip / 255.0, 1);
}


fixed4 GetMaxFeedback(float2 uv, int count)
{
	fixed4 col = fixed4(1, 1, 1, 1);
	for (int y = 0; y < count; y++)
	{
		for (int x = 0; x < count; x++)
		{
			fixed4 col1 = tex2D(_MainTex, uv + float2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y));
			col = lerp(col, col1, step(col1.b, col.b));//如果col的mipmap小于新的（col1),则去col的，总之取较小的mipmap level
		}
	}
	return col;
}

#endif