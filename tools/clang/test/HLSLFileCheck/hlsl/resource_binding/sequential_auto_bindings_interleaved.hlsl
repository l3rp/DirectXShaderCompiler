// RUN: %dxc /T cs_6_6 /E CSMain -fsequential-auto-bindings %s | FileCheck %s

// Regression test: auto-bound resources of different register types,
// interleaved in declaration order with a cbuffer in the middle, must be
// assigned sequential registers in that same source order (t0, s1, u2, b3,
// t4) -- not bucketed by resource type first (which would incorrectly give
// t0, s1, u2, b4, t3, since cbuffers get their final DXIL global created
// later than other resource types and can't be ordered by that).
//
// CHECK-DAG: call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind zeroinitializer, i32 0, i1 false)
// CHECK-DAG: call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind { i32 1, i32 1, i32 0, i8 3 }, i32 1, i1 false)
// CHECK-DAG: call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind { i32 2, i32 2, i32 0, i8 1 }, i32 2, i1 false)
// CHECK-DAG: call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind { i32 3, i32 3, i32 0, i8 2 }, i32 3, i1 false)
// CHECK-DAG: call %dx.types.Handle @dx.op.createHandleFromBinding(i32 217, %dx.types.ResBind { i32 4, i32 4, i32 0, i8 0 }, i32 4, i1 false)

struct CBData { float4 v; };

Texture2D<float4> texA : register(space0);          // declared 1st -> t0
SamplerState sampA : register(space0);               // declared 2nd -> s1
RWStructuredBuffer<float4> bufA : register(space0);  // declared 3rd -> u2
ConstantBuffer<CBData> cbA : register(space0);        // declared 4th -> b3
Texture2D<float4> texB : register(space0);           // declared 5th -> t4

[numthreads(8,8,1)]
void CSMain(uint3 id : SV_DispatchThreadID)
{
    bufA[id.x] = texA.SampleLevel(sampA, float2(0,0), 0) + cbA.v + texB.Load(int3(0,0,0));
}
