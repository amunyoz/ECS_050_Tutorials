#ifndef NUBECODE_INCLUDED
#define NUBECODE_INCLUDED

//float _MinX = 0, _MaxX = 1, _MinY = 0, _MaxY = 1, _MinZ = 0, _MaxZ = 1;

float4 sampleVol(float3 pos, UnityTexture3D _Volume, float _MinX, float _MaxX, float _MinY,
	float _MaxY, float _MinZ, float _MaxZ)
// clip the volume
{
	float x = step(pos.x, _MaxX) * step(_MinX, pos.x);
	float y = step(pos.y, _MaxY) * step(_MinY, pos.y);
	float z = step(pos.z, _MaxZ) * step(_MinZ, pos.z);
	return tex3D(_Volume, pos) * x * y * z;
}


//int _Iteration=500;
void NubeCode_float( float3 localPos, float3 rayDirection, float _Iteration,
	float stepSize,float densityScale , float3 offset,
	UnityTexture3D Volume, float fraccion,
	float _MinX, float _MaxX, float _MinY,
	float _MaxY, float _MinZ, float _MaxZ,
	float _LimitIterations,
	
	out float4 Out)
{
	float density = 0.0;
	float3 colores = 0.0;

	//***********************************************************
	float3 rayOrigin = (localPos.xyz  + offset.xyz);//**  +0.5;
	float rayLength = length(rayDirection);
	rayDirection = normalize(rayDirection);// *-0.5;//***** añadido
 
	//rayDirection = localPos;

	float4 finalColor = 0.0;
	// raíz cuadrada de 3=  1.732;
	float t = 1.732 / _Iteration; // step size for one iteration******

	//[unroll(512)] 
	//[loop]
	[unroll(512)]for (int i = _Iteration; i >0; i--) {//	for (int i = 0; i < _Iteration; i++) {

	//	if (i < _LimitIterations)break;
		float step = t * i;
		//if (step > rayLength) // do not render volume that is behind the camera
		//	break;
		float3 curPos = rayOrigin; //****  localPos + offset;
		curPos += rayDirection * step;
		//float4 color = sample(curPos);
		float4 color = sampleVol(curPos, Volume, _MinX, _MaxX, _MinY, _MaxY, _MinZ, _MaxZ);
		finalColor.rgb = color.a * color.rgb + (1 - color.a) * finalColor.rgb;
		finalColor.a = color.a + (1 - color.a) * finalColor.a;
		if (finalColor.a > 1) break;
		//*********
	}
		Out = finalColor;
	

}

#endif