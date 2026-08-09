// RUN: not %dxc /T ps_6_0 /E main -fsequential-auto-bindings -flegacy-resource-reservation %s 2>&1 | FileCheck %s

// CHECK: -fsequential-auto-bindings cannot be used together with -flegacy-resource-reservation

Texture2D MyTex;
float4 main() : SV_Target
{
  return MyTex.Load((uint3)0);
}
