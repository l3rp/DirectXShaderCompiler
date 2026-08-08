// RUN: %dxc /T ps_6_0 /E main %s | FileCheck %s -check-prefix=DEFAULT
// RUN: %dxc /T ps_6_0 /E main -fsequential-auto-bindings %s | FileCheck %s -check-prefix=SEQUENTIAL

// None of these resources have an explicit register assignment.
//
// By default, each register type (b/s/t/u) is auto-allocated independently,
// so the cbuffer, sampler, and texture all land on register 0 of their own
// type.
// DEFAULT-DAG: call %dx.types.Handle @dx.op.createHandle(i32 57, i8 2, i32 0, i32 0, i1 false)
// DEFAULT-DAG: call %dx.types.Handle @dx.op.createHandle(i32 57, i8 3, i32 0, i32 0, i1 false)
// DEFAULT-DAG: call %dx.types.Handle @dx.op.createHandle(i32 57, i8 0, i32 0, i32 0, i1 false)

// With -fsequential-auto-bindings, auto-generated bindings share one
// counter across register types (in cbuffer, sampler, UAV, SRV order), so
// MyBuf keeps b0, MySampler moves to s1, and MyTex moves to t2.
// SEQUENTIAL-DAG: call %dx.types.Handle @dx.op.createHandle(i32 57, i8 2, i32 0, i32 0, i1 false)
// SEQUENTIAL-DAG: call %dx.types.Handle @dx.op.createHandle(i32 57, i8 3, i32 0, i32 1, i1 false)
// SEQUENTIAL-DAG: call %dx.types.Handle @dx.op.createHandle(i32 57, i8 0, i32 0, i32 2, i1 false)

cbuffer MyBuf
{
  float4 Color;
};

SamplerState MySampler;
Texture2D MyTex;

float4 main() : SV_Target
{
  return MyTex.Sample(MySampler, float2(0, 0)) * Color;
}
