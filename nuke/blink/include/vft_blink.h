/*
-----------------------------------------------------------------------------
This source file has been developed within the scope of the
Technical Director course at Filmakademie Baden-Wuerttemberg.
http://technicaldirector.de
    
Written by Juraj Tomori.
Copyright (c) 2019 Animationsinstitut of Filmakademie Baden-Wuerttemberg
-----------------------------------------------------------------------------
*/

#ifndef VFT_BLINK_FUNCS
#define VFT_BLINK_FUNCS

// constants
#define LARGE_NUMBER            10e10


// functions
static float fit(float value, float src_min, float src_max, float dst_min, float dst_max) {
    return dst_min + (dst_max - dst_min) * (value - src_min) / (src_max - src_min);
}

static float distPtLine(float2 pt, float2 line_pt_1, float2 line_pt_2)
{
    float numerator = fabs( pt.x*( line_pt_2.y - line_pt_1.y ) - pt.y*( line_pt_2.x - line_pt_1.x ) + line_pt_2.x*line_pt_1.y - line_pt_2.y * line_pt_1.x );
    float denominator = sqrt( pow( line_pt_2.y - line_pt_1.y , 2.0f) + pow( line_pt_2.x - line_pt_1.x , 2.0f) );
    return numerator / denominator;
}

static float distPtCircle(float2 pt, float2 center, float radius)
{
    return length(pt - center) - radius;
}

static float2 zoomComplexPlane(float2 pos, float zoom, float exp_zoom, float2 offset)
{
    pos /= zoom;
    pos /= exp(exp_zoom);
    pos += offset;

    return pos;
}

// complex number functions
typedef float2 complex;

static complex complex_add(complex a, complex b)
{
    return complex(a.x + b.x, a.y + b.y);
}

static complex complex_mult(complex a, complex b)
{
    return complex(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

static float complex_abs(complex a)
{
    return dot(float2(a), float2(a));
}

static complex complex_pow(complex a, int n)
{
    complex result = a;
    
    for (int i = 0; i < (n-1); i++)
    {
        result = complex_mult(result, a);
    }

    return result;
}

#endif
