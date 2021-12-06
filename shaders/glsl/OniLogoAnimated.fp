// ah shit here we go again

#define overlay(a,b) (a<0.5)?(2.0*a*b):(1.0-(2.0*(1.0-a)*(1.0-b)))
const float pi = 3.14159265358979323846;

vec2 warpcoord( in vec2 uv )
{
	vec2 offset = vec2(0,0);
	offset.x = sin(pi*2.*(uv.x*4.+timer*.125))*.02;
	offset.y += timer*.25;
	offset.x = cos(pi*2.*(uv.y*2.+timer*.125))*.02;
	return fract(uv+offset);
}

vec2 warpcoord2( in vec2 uv )
{
	vec2 offset = vec2(0,0);
	offset.y = sin(pi*2.*(uv.x*8.+timer*.25))*.01;
	offset.x = cos(pi*2.*(uv.y*4.+timer*.25))*.01;
	return fract(uv+offset);
}

// based on gimp color to alpha, but simplified
vec4 blacktoalpha( in vec4 src )
{
	vec4 dst = src;
	float alpha = 0.;
	float a;
	a = clamp(dst.r,0.,1.);
	if ( a > alpha ) alpha = a;
	a = clamp(dst.g,0.,1.);
	if ( a > alpha ) alpha = a;
	a = clamp(dst.b,0.,1.);
	if ( a > alpha ) alpha = a;
	if ( alpha > 0. )
	{
		float ainv = 1./alpha;
		dst.rgb *= ainv;
	}
	dst.a *= alpha;
	return dst;
}
#ifdef NO_BILINEAR
#define BilinearSample(x,y,z,w) texture(x,y)
#else
vec4 BilinearSample( in sampler2D tex, in vec2 pos, in vec2 size, in vec2 pxsize )
{
	vec2 f = fract(pos*size);
	pos += (.5-f)*pxsize;
	vec4 p0q0 = texture(tex,pos);
	vec4 p1q0 = texture(tex,pos+vec2(pxsize.x,0));
	vec4 p0q1 = texture(tex,pos+vec2(0,pxsize.y));
	vec4 p1q1 = texture(tex,pos+vec2(pxsize.x,pxsize.y));
	vec4 pInterp_q0 = mix(p0q0,p1q0,f.x);
	vec4 pInterp_q1 = mix(p0q1,p1q1,f.x);
	return mix(pInterp_q0,pInterp_q1,f.y);
}
#endif

void SetupMaterial( inout Material mat )
{
	// store these to save some time
	vec2 size = vec2(textureSize(Layer1,0));
	vec2 pxsize = 1./size;
	// y'all ready for this multilayered madness?
	vec2 uv = vTexCoord.st;
	// base, full black
	vec4 base = vec4(0.,0.,0.,1.);
	// layer 1 red to alpha
	base.a = BilinearSample(Layer1,uv,size,pxsize).r;
	// layer 2 blend (red only) with layer 1 green mask
	vec4 tmp;
	tmp.r = BilinearSample(Layer2,warpcoord(uv),size,pxsize).r;
	tmp.gb = vec2(0.);
	tmp.a = BilinearSample(Layer1,uv,size,pxsize).g;
	base.rgb = mix(base.rgb,tmp.rgb,tmp.a);
	// overlay layer 3 with alpha
	tmp = BilinearSample(Layer3,uv,size,pxsize);
	vec4 tmp2;
	tmp2.r = overlay(base.r,tmp.r);
	tmp2.g = overlay(base.g,tmp.g);
	tmp2.b = overlay(base.b,tmp.b);
	base.rgb = mix(base.rgb,tmp2.rgb,tmp.a);
	// separate layer 4
	tmp = BilinearSample(Layer4,uv,size,pxsize);
	// overlay layer 2 green
	tmp2.r = BilinearSample(Layer2,warpcoord2(uv),size,pxsize).g;
	tmp.r = overlay(tmp.r,tmp2.r);
	tmp.g = overlay(tmp.g,tmp2.r);
	tmp.b = overlay(tmp.b,tmp2.r);
	// multiply inverse layer 1 red
	tmp.rgb *= 1.-BilinearSample(Layer1,uv,size,pxsize).r;
	// overlay layer 5
	tmp2 = BilinearSample(Layer5,uv,size,pxsize);
	tmp.r = overlay(tmp.r,tmp2.r);
	tmp.g = overlay(tmp.g,tmp2.g);
	tmp.b = overlay(tmp.b,tmp2.b);
	// black to alpha
	tmp = blacktoalpha(tmp);
	// blend on top
	base.rgb = mix(base.rgb,tmp.rgb,tmp.a);
	base.a = min(base.a+tmp.a,1.);
	// clamp
	base = clamp(base,0.,1.);
	// ding, logo's done
	mat.Base = base;
}
