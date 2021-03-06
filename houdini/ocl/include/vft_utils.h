/*
-----------------------------------------------------------------------------
This source file has been developed within the scope of the
Technical Director course at Filmakademie Baden-Wuerttemberg.
http://technicaldirector.de
    
Written by Juraj Tomori.
Copyright (c) 2019 Animationsinstitut of Filmakademie Baden-Wuerttemberg
-----------------------------------------------------------------------------
*/

#ifndef VFT_UTILS
#define VFT_UTILS

// some of the functions here are ported/derived from those sources:
// http://iquilezles.org/www/
// http://woo4.me/woofractal/

////////////// helper funcs


// export float attrib
static void vstore1(float dataIn, long i, global float* dataOut)
{
    dataOut[i] = dataIn;
}


////////////// sdf operations


// polynomial smooth min
static float sminPoly( float a, float b, float k )
{
    float h = clamp( 0.5f + 0.5f * DIV((b - a), k), 0.0f, 1.0f );
    return mix( b, a, h ) - k * h * (1.0f - h);
}

// exponential smooth min
static float sminExp( float a, float b, float k )
{
    float res = EXP( -k * a ) + EXP( -k * b );
    return -DIV(LOG(res), k);
}

// union
static float sdfUnion( float a, float b )
{
    return min(a, b);
}

// smooth union
static float sdfUnionSmooth( float a, float b, float k )
{
    return sminPoly(a, b, k);
}

// subtraction
static float sdfSubtract( float b, float a )
{
    return max(-a, b);
}

// intersection
static float sdfIntersect( float a, float b )
{
    return max(a, b);
}

// blend
static float sdfBlend(float d1, float d2, float a)
{
    return (1 - a) * d1 + a * d2;
}

// infinitely repeat by a distance (c)
static float3 spaceRep( float3 p, float3 c )
{
    p = fmod(p,c) - 0.5f*c  ;
    return p;

}

// repeat by a distance (c) and by a fixed number of copies (limit)
static float3 spaceRepFixed(float3 p, float3 c, float3 limit)
{
    limit *= c-1;
    p = min(-limit, p) + limit
        + fmod(max(min(p, limit), -limit), c) - 0.5f*c
        + max(p, limit) - limit;
    return p;
}

// [M2] wrap 
static float3 wrap(float3 x, float3 a, float3 s)
{
	x -= s;
	return (float3)(x.x - a.x * floor(DIV(x.x, a.x)) + s.x, x.y - a.y * floor(DIV(x.y, a.y)) + s.y, x.z - a.z * floor(DIV(x.z, a.z)) + s.z);
}

////////////// debug


// print a mtx
static void printMtx(float16 m)
{
    int idx = get_global_id(0);
    if (idx == 0) {
        printf( "\n" );
        printf( "%2.2v4hlf\n", m.s0123 );
        printf( "%2.2v4hlf\n", m.s4567 );
        printf( "%2.2v4hlf\n", m.s89ab );
        printf( "%2.2v4hlf\n", m.scdef );
        printf( "\n" );
    }
}

// print a mtx
static void printMtxVol(float16 m)
{
    int gidx = get_global_id(0);
    int gidy = get_global_id(1);
    int gidz = get_global_id(2);
    
    if (gidx == 0 && gidy == 0 && gidz == 0) {
        printf( "\n" );
        printf( "%2.2v4hlf\n", m.s0123 );
        printf( "%2.2v4hlf\n", m.s4567 );
        printf( "%2.2v4hlf\n", m.s89ab );
        printf( "%2.2v4hlf\n", m.scdef );
        printf( "\n" );
    }
}

// print a vector
static void printVec(float3 a)
{
    int idx = get_global_id(0);
    if (idx == 0) {
        printf( "%2.2v3hlf\n", a );
    }
}

// print a float
static void printFloat(float a)
{
    int idx = get_global_id(0);
    if (idx == 0) {
        printf( "%2.15f\n", a );
    }
}

// print n new lines
static void printNewLines(int n)
{
    int idx = get_global_id(0);
    if (idx == 0) {
        for (int i = 0; i < n; i++)
            printf( "\n" );
    }
}

#endif
