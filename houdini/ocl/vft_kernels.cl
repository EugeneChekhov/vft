#include "vft_utils.h"
#include "vft_math.h"
#include "vft_fractals.h"


// testing new formulas

// amazing surf from M3D
// does nothing
static float amazingSurf(float3 P, float size)
{
//void AmazingSurfIteration(CVector4 &z, const sFractal *fractal, sExtendedAux &aux)
//{
//    // update aux.actualScale
//    aux.actualScale =
//        fractal->mandelbox.scale + fractal->mandelboxVary4D.scaleVary * (fabs(aux.actualScale) - 1.0);

//    CVector4 c = aux.const_c;
//    z.x = fabs(z.x + fractal->transformCommon.additionConstant111.x)
//                - fabs(z.x - fractal->transformCommon.additionConstant111.x) - z.x;
//    z.y = fabs(z.y + fractal->transformCommon.additionConstant111.y)
//                - fabs(z.y - fractal->transformCommon.additionConstant111.y) - z.y;
//    // no z fold

//    double rr = z.Dot(z);
//    if (fractal->transformCommon.functionEnabledFalse) // force cylinder fold
//        rr -= z.z * z.z;

//    double sqrtMinR = sqrt(fractal->transformCommon.minR05);
//    double dividend = rr < sqrtMinR ? sqrtMinR : min(rr, 1.0);

//    // use aux.actualScale
//    double m = aux.actualScale / dividend;

//    z *= (m - 1.0) * fractal->transformCommon.scale1 + 1.0;
//    // z *= m * fractal->transformCommon.scale1 + 1.0 * (1.0 - fractal->transformCommon.scale1);
//    aux.DE = aux.DE * fabs(m) + 1.0;

//    if (fractal->transformCommon.addCpixelEnabledFalse)
//        z += CVector4(c.y, c.x, c.z, c.w) * fractal->transformCommon.constantMultiplier111;

//    z = fractal->transformCommon.rotationMatrix.RotateVector(z);
//}
    //P /= size;
    float3 z = P;
    float dr = 1.0;
    int Iterations = 10;
    //int Bailout = 6;

    float actualScale = 1.39;
    float scaleVary = 0;
    float2 fold = (float2)(1.076562, 1.05);
    float minRad = 0.18;
    float scaleInf = 1;
    float auxScale = 1;

    for (int i = 0; i < Iterations ; i++)
    {
        //update aux.actualScale
        actualScale = actualScale + scaleVary * (fabs(actualScale) - 1.0f);
    
        //CVector4 c = aux.const_c;
        z.x = fabs(z.x + fold.x) - fabs(z.x - fold.x) - z.x;
        z.y = fabs(z.y + fold.y) - fabs(z.y - fold.y) - z.y;
        // no z fold
    
        float rr = z.x*z.x + z.y*z.y + z.z*z.z;
        //if (fractal->transformCommon.functionEnabledFalse) // force cylinder fold
        //    rr -= z.z * z.z;
    
        float sqrtMinR = sqrt(minRad);
        float dividend = rr < sqrtMinR ? sqrtMinR : min(rr, 1.0f);
    
        // use aux.actualScale
        //float m = auxScale / dividend;
        float m = actualScale / dividend;
    
        z *= (m - 1.0f) * scaleInf + 1.0f;
        dr = dr * fabs(m) + 1.0;
    
        //if (fractal->transformCommon.addCpixelEnabledFalse)
        //    z += CVector4(c.y, c.x, c.z, c.w) * fractal->transformCommon.constantMultiplier111;
    
        //z = fractal->transformCommon.rotationMatrix.RotateVector(z);
        float16 rotMtx = mtxRotate( (float3)(8.414060, 3.340000, 18.125000) );
        //z = mtxPtMult(rotMtx, z);

        z += P;
    }

    //float out = 0.5 * log(r) * r/dr;
    //return out * size;
    return dr;
}

// quaternion fractals, kind of works, but not sure what to do with z.w component :)
static float quaternion(float3 P, float size)
{
//void QuaternionIteration(CVector4 &z, const sFractal *fractal, sExtendedAux &aux)
//{
//    Q_UNUSED(fractal);

//    aux.r_dz = aux.r_dz * 2.0 * aux.r;
//    double newx = z.x * z.x - z.y * z.y - z.z * z.z - z.w * z.w;
//    double newy = 2.0 * z.x * z.y;
//    double newz = 2.0 * z.x * z.z;
//    double neww = 2.0 * z.x * z.w;
//    z.x = newx;
//    z.y = newy;
//    z.z = newz;
//    z.w = neww;
//}
    P /= size;

    float4 z = (float4)(P, 1);
    float dr = 1.0;
    float r = 0.0;
    int Iterations = 50;
    int Bailout = 40;

    for (int i = 0; i < Iterations ; i++)
    {
        r = length(z);
        if (r > Bailout) break;

        dr = dr * 2.0f * r;
        float newx = z.x * z.x - z.y * z.y - z.z * z.z - z.w * z.w;
        float newy = 2.0f * z.x * z.y;
        float newz = 2.0f * z.x * z.z;
        float neww = 2.0f * z.x * z.w;
        z.x = newx;
        z.y = newy;
        z.z = newz;
        //z.w = neww;
    }

    float out = 0.5f * log(r) * r/dr;
    return out * size;
}

// quaternion3d
// kind of works, but does not exactly match M2 visual, but parameters deform it in a similar manner, I hardcoded some of the parameters into values, there are some buggy areas, missing parts, noisy normals etc.
static float quaternion3d(float3 P, float size)
{
//void Quaternion3dIteration(CVector4 &z, const sFractal *fractal, sExtendedAux &aux)
//{
//
//    aux.r_dz = aux.r_dz * 2.0 * aux.r;
//    z = CVector4(z.x * z.x - z.y * z.y - z.z * z.z, z.x * z.y, z.x * z.z, z.w);
//
//    double tempL = z.Length();
//    z *= fractal->transformCommon.constantMultiplier122;
//    // if (tempL < 1e-21) tempL = 1e-21;
//    CVector4 tempAvgScale = CVector4(z.x, z.y / 2.0, z.z / 2.0, z.w);
//    double avgScale = tempAvgScale.Length() / tempL;
//    double tempAux = aux.r_dz * avgScale;
//    aux.r_dz = aux.r_dz + (tempAux - aux.r_dz) * fractal->transformCommon.scaleA1;
//
//    if (fractal->transformCommon.rotationEnabled)
//        z = fractal->transformCommon.rotationMatrix.RotateVector(z);
//
//    z += fractal->transformCommon.additionConstant000;
//}
    P /= size;

    float4 z = (float4)(P, 1);
    float dr = 1.0;
    float r = 0.0;
    int Iterations = 250;
    int Bailout = 20;

    for (int i = 0; i < Iterations ; i++)
    {
        r = length(z);
        if (r > Bailout) break;
        
        dr = dr * 2.0 * r;
        z = (float4)(z.x * z.x - z.y * z.y - z.z * z.z, z.x * z.y, z.x * z.z, z.w);

        float tempL = r;
        z *= (float4)(1,1,1,1);

        float4 tempAvgScale = (float4)(z.x, z.y / 2.0, z.z / 2.0, z.w);
        float avgScale = length(tempAvgScale) / tempL;
        float tempAux = dr * avgScale;
        dr = dr + (tempAux - dr) * 1.0f;

        //if (fractal->transformCommon.rotationEnabled)
        //    z = fractal->transformCommon.rotationMatrix.RotateVector(z);

        z += (float4)(0,0,0,0);
    }

    //float out = 0.5f * log(r) * r/dr;
    float out = r / dr;
    return out * size;
}


// dr -> de
// r -> distance
// Bailout -> max_distance
// Iterations -> max_iterations
static float hybrid(float3 P_in, const int max_iterations, const int max_distance, const float size, const bool de_mode)
{
    P_in /= size;
    float3 Z = P_in;
    float de = 1.0;
    float distance;
    float out_de;

    for (int i = 0; i < max_iterations; i++)
    {
        distance = length(Z);
        if (distance > max_distance) break;
        
        //mandelbulbIter(&Z, &de, &P_in, (float4)(1,0,1,1), 8);
        //mandelboxIter(&Z, &de, &P_in, (float4)(0,0,6,4), 3.0);
        mandelbulbPower2Iter(&Z, &de, &P_in, (float4)(1,0.3,0.4,0.4));
        //mengerSpongeIter(&Z, &de, &P_in, (float4)(0,0,1,0));
        //bristorbrotIter(&Z, &de, &P_in, (float4)(1,0,1,0));
        //xenodreambuieIter(&Z, &de, &P_in, (float4)(1,0,1,0), 8, 0, 0);
        //coastalbrotIter(&Z, &de, &P_in, (float4)(1,0,1,0));
        //sierpinski3dIter(&Z, &de, &P_in, (float4)(0,0,0,1), 2.0, (float3)(1,1,1), (float3)(0,0,0) );
    }

    if (de_mode) out_de = 0.5 * log(distance) * distance/de;
    else out_de = distance / de;

    return out_de * size;
}


//// scene setup

static float scene( float3 P, float frame ) {
    float dist_out;

    float3 P_rep = P;

    //float3 P_rep = spaceRepFixed( P, (float3)(21), (float3)(2,3,4) );

    //float16 xform = mtxIdent();
    //xform = mtxMult( xform, mtxScale( (float3)(1/2.0,1,1) ) );
    //xform = mtxMult( xform, mtxRotate( (float3)(0,0,90) ) );
    //xform = mtxMult( xform, mtxTranslate( (float3)(0,-4,0) ) );
    //xform = mtxInvert(xform);
    //P_rep = mtxPtMult(xform, P_rep);

    float shape1 = hybrid(P_rep, 250, 100, 1.0, 1);

    dist_out = shape1; ///////////////////////////////////////
    return dist_out;
}

//// main function

kernel void marchPerspCam(
        float timeinc, float time, 
        int P_length, global float* P,
        int planeZ_length, global float* planeZ,
        int width_length, global float* width,
        int height_length, global float* height,
        int px_length, global float* px,
        int camXform_length, global float* camXform,
        int camPos_length, global float* camPos,
        int N_length, global float* N,
        int iRel_length, global float* iRel,
        int Cd_length, global float* Cd
        )
{
    // get current point id
    const int idx = get_global_id(0);

    // if current point is not valid, then end
    if ( idx >= P_length ) return;

    // read in P attrib
    const float3 pixel_P_origin = vload3(idx, P);
    float3 pixel_P_world = pixel_P_origin;

    //// transforming to near img plane

    // move to near img plane
    pixel_P_world.z = planeZ[0];

    // compute scale of near img plane
    const float16 near_plane_scale = mtxScale( (float3)(width[0]-px[0], height[0]-px[0], 1) );
    
    // read in cam world matrix
    const float16 cam_xform_world = (float16)(camXform[0],camXform[1],camXform[2],camXform[3],
                                  camXform[4],camXform[5],camXform[6],camXform[7],
                                  camXform[8],camXform[9],camXform[10],camXform[11],
                                  camXform[12],camXform[13],camXform[14],camXform[15] );

    // create a mtx to hold transformations
    float16 near_plane_xform = mtxIdent();

    // apply transformations, also produce alternative matrix with scaled near plane
    near_plane_xform = mtxMult(near_plane_xform, near_plane_scale);
    float16 near_plane_xform_scaled = mtxMult(near_plane_xform, mtxScale( (float3)(100000) ) );
    near_plane_xform = mtxMult(near_plane_xform, cam_xform_world);
    near_plane_xform_scaled = mtxMult(near_plane_xform_scaled, cam_xform_world);

    // create a scaled near plane position for more accurate ray_dir calculation
    float3 pixel_P_world_scaled = mtxPtMult(near_plane_xform_scaled, pixel_P_world);

    // transform pixels into near img plane
    pixel_P_world = mtxPtMult(near_plane_xform, pixel_P_world);

    // get camera world space position and compute ray direction vector
    const float3 cam_P_world = (float3)(camPos[0], camPos[1], camPos[2]);
    const float3 ray_dir = normalize(pixel_P_world_scaled - cam_P_world);

    //// raymarching

    // raymarch settings
    const float frame = time/timeinc + 1;
    float3 ray_P_world = pixel_P_world;
    float cam_dist = scene(cam_P_world, frame);
    float de = 0;
    int i = 0;
    float step_size = .4;
    float iso_limit_mult = 1;
    float ray_dist = planeZ[0];
    const int max_steps = 1000;
    const float max_dist = 40000;

    float iso_limit = cam_dist * 0.0001 * iso_limit_mult;  

    // raymarch
    for (i=0; i<max_steps; i++)
    {
        de = scene(ray_P_world, frame) * step_size;
        //if ( de <= iso_limit * (ray_dist/300) || ray_dist >= max_dist ) break;
        if ( de <= iso_limit || ray_dist >= max_dist ) break;
        ray_dist += de;
        ray_P_world += ray_dir * de;
    }

    // compute N
    const float e = iso_limit;
    float3 N_grad = (float3)(0);
    float3 e_offset[6] = { ray_P_world + (float3)(e,0,0),
                           ray_P_world - (float3)(e,0,0),
                           ray_P_world + (float3)(0,e,0),
                           ray_P_world - (float3)(0,e,0),
                           ray_P_world + (float3)(0,0,e),
                           ray_P_world - (float3)(0,0,e) };
    
    N_grad = (float3)( scene( e_offset[0], frame ) - scene( e_offset[1], frame ),
                       scene( e_offset[2], frame ) - scene( e_offset[3], frame ),
                       scene( e_offset[4], frame ) - scene( e_offset[5], frame ) );

    N_grad = normalize(N_grad);

    // relative amount of steps
    float i_rel = (float)(i)/(float)(max_steps);
    i_rel = 1-pow(i_rel, 1.0f/3.0f);

    // remove missed
    if ( de > iso_limit )
    {
        i_rel = -1;
    }

    // Cd for viz
    const float3 sun_dir = normalize( (float3)(0.5,1,0.2) );
    float3 Cd_out;
    //Cd_out = fabs(N_grad);
    //Cd_out *= (1 - i_rel);
    Cd_out = clamp( dot(sun_dir, N_grad), 0.0f, 1.0f) ;
    //Cd_out = dot(sun_dir, N_grad) * 0.5f + 0.5f;    
    //Cd_out = pow(Cd_out, 6.0f);
    //Cd_out = (float3)(i_rel);
    Cd_out *= i_rel;
    //Cd_out += 0.01f;

    Cd_out = clamp( Cd_out, 0.0f, 1.0f );

    // export attribs
    vstore3(ray_P_world, idx, P);
    vstore3(N_grad, idx, N);
    vstore3(Cd_out, idx, Cd);
    vstore1(i_rel, idx, iRel);
}