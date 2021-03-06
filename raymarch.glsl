#define mode 1

vec4 groundIntersection(in vec3 gPos,in vec3 rPos){
    return vec4(0,1,0,rPos.y-gPos.y);
}

vec3 groundNormal(){
    return vec3(0,1,0);
}

vec4 sphereIntersection(in vec3 sPos,in vec3 rPos,float radius){
    vec3 dis=sPos-rPos;
    vec4 m;
    m.w=length(dis)-radius;
    m.xyz=normalize(rPos-sPos);
    return m;
}

vec3 sphereNormal(in vec3 sPos,in vec3 rPos){
    return normalize(rPos-sPos);
}

vec4 cubeIntersection(in vec3 cPos,in vec3 rPos,float len){
    vec3 dis=cPos-rPos;
    float x=abs(dis.x),y=abs(dis.y),z=abs(dis.z);
    vec4 m;
    if(x>=y&&x>=z){
        y=len/2.0*y/x;
        z=len/2.0*z/x;
        x=len/2.0;
        m.xyz=-vec3(sign(dis.x),0.0,0.0);
    }
    else if(y>=x&&y>=z){
        x=len/2.0*x/y;
        z=len/2.0*z/y;
        y=len/2.0;
        m.xyz=-vec3(0.0,sign(dis.y),0.0);
    }
    else{
        x=len/2.0*x/z;
        y=len/2.0*y/z;
        z=len/2.0;
        m.xyz=-vec3(0.0,0.0,sign(dis.z));
    }
    m.w=length(dis)-length(vec3(x,y,z));
    return m;
}

vec3 cubeNormal(in vec3 cPos,in vec3 rPos){
    vec3 dir=rPos-cPos;
    float x=abs(dir.x),y=abs(dir.y),z=abs(dir.z);
    if(x>=y&&x>=z) return vec3(sign(dir.x),0.0,0.0);
    else if(y>=x&&y>=z) return vec3(0.0,sign(dir.y),0.0);
    else return vec3(0.0,0.0,sign(dir.z));
}

vec4 cylinderIntersection(in vec3 cPos,in vec3 rPos,float len,float radius){
    vec3 dis=cPos-rPos;
    float x=abs(dis.x),y=abs(dis.y),z=abs(dis.z);
    float r=length(vec2(x,z));
    vec4 m;
    if(2.0*y/len>r/radius){
        x=len/2.0*x/y;
        z=len/2.0*z/y;
        y=len/2.0;
        m.xyz=-vec3(0.0,sign(dis.y),0.0);
    }
    else{
        x=radius*x/r;
        y=radius*y/r;
        z=radius*z/r;
        vec3 normal=vec3(dis.x,0.0,dis.z);
        normal=normalize(normal);
        m.xyz=-normal;
    }
    m.w=length(dis)-length(vec3(x,y,z));
    return m;
}

vec3 cylinderNormal(in vec3 cPos,in vec3 rPos,float len,float radius){
    vec3 dir=rPos-cPos;
    float x=abs(dir.x),y=abs(dir.y),z=abs(dir.z);
    float r=length(vec2(x,z));
    if(2.0*y/len>r/radius){
        return vec3(0.0,sign(dir.y),0.0);
    }
    else{
        vec3 normal=vec3(dir.x,0.0,dir.z);
        normal=normalize(normal);
        return normal;
    }
}

mat4 transform(in vec3 scale,in vec3 rotate,in vec3 translate){
    mat4 ms,mx,my,mz,mt;
    float PI=3.1415926;
    float rx=rotate.x/180.0*PI;
    float ry=rotate.y/180.0*PI;
    float rz=rotate.z/180.0*PI;
    ms=mat4(1);
    ms[0].x=1.0/scale.x;
    ms[1].y=1.0/scale.y;
    ms[2].z=1.0/scale.z;
    vec4 m00=vec4(cos(rx),sin(rx),0,0);
    vec4 m01=vec4(-sin(rx),cos(rx),0,0);
    vec4 m02=vec4(0,0,1,0);
    vec4 m03=vec4(0,0,0,1);
    vec4 m10=vec4(cos(ry),0,-sin(ry),0);
    vec4 m11=vec4(0,1,0,0);
    vec4 m12=vec4(sin(ry),0,cos(ry),0);
    vec4 m13=vec4(0,0,0,1);
    vec4 m20=vec4(1,0,0,0);
    vec4 m21=vec4(0,cos(rz),sin(rz),0);
    vec4 m22=vec4(0,-sin(rz),cos(rz),0);
    vec4 m23=vec4(0,0,0,1);
    mx[0]=m00;mx[1]=m01;mx[2]=m02;mx[3]=m03;
    my[0]=m10;my[1]=m11;my[2]=m12;my[3]=m13;
    mz[0]=m20;mz[1]=m21;mz[2]=m22;mz[3]=m23;
    mt=mat4(1);
    mt[3]=vec4(translate,1);
    return mt*mz*my*mx*ms;
    //return ms;
}

vec3 lightColor(in vec3 ro,in vec3 rd,in vec3 normal,in vec3 lPos,float t){
    vec3 pos=ro+t*rd;
    vec3 lDir=normalize(lPos-pos);
    vec3 diff=vec3(1)*clamp(dot(normal,lDir),0.0,1.0);
    vec3 ref=normalize(-lDir-2.0*normal*dot(-lDir,normal));
    vec3 spec=vec3(1)*pow(max(0.0,dot(ref,-rd)),20.0);
    return 0.8*diff+0.2*spec;
    //return vec3(1,1,1)*clamp(dot(normal,lDir),0.0,1.0);
}

bool Union(vec4 m1,vec4 m2){
    return m1.w<m2.w;
}

vec3 rayCastSmart(in vec3 ro,in vec3 rd){
    float max=50.0;
    float t=0.01;
    float eplison=0.00001;
    vec3 oPos0=vec3(1,1,1);
    vec3 oPos1=vec3(0,0.3,0);
    vec3 oPos2=vec3(0,0,0);
    vec3 oPos3=vec3(1.2,0.8,-0.2);
    float radius=0.4;
    float len=0.6;
    vec4 res,res1,res2,res3;
    mat4 m[4],m0;
    m[0]=transform(vec3(1,1,1),vec3(30,0,20),vec3(0));
    m[1]=transform(vec3(1.0,1.0,1.0),vec3(0,0,0),vec3(0,0,0));
    m[2]=transform(vec3(1.0,1.0,1.0),vec3(0,0,0),vec3(0,0,0));
    m[3]=transform(vec3(1.0,1.0,1.0),vec3(-20,-30,-20),vec3(0,0,0));
    vec3 o,d;
    for(int i=0;i<1000;++i){
        o=(m[0]*vec4(ro,0)).xyz;
    	d=(m[0]*vec4(rd,1)).xyz;
        res=cylinderIntersection(oPos0,o+t*d,len,radius);
        o=(m[1]*vec4(ro,0)).xyz;
    	d=(m[1]*vec4(rd,1)).xyz;
        res1=sphereIntersection(oPos1,o+t*d,radius);
        o=(m[2]*vec4(ro,0)).xyz;
    	d=(m[2]*vec4(rd,1)).xyz;
        res2=groundIntersection(oPos2,o+t*d);
        o=(m[3]*vec4(ro,0)).xyz;
    	d=(m[3]*vec4(rd,1)).xyz;
        res3=cubeIntersection(oPos3,o+t*d,len);
        if(Union(res,res1)){ 
            res=res;
            m0=m[0];
        }
        else{
            m0=m[1];
            res=res1;
        }
        if(Union(res,res2)){
            res=res;
            //m0=m[2];
        }
        else{
            res=res2;
            m0=m[2];
        }
        if(Union(res,res3)){
            res=res;
            //m0=m[2];
        }
        else{
            res=res3;
            m0=m[3];
        }
        if(t>max||abs(res.w)<eplison) break;
        t+=res.w;
    }
    if(res.w<eplison){
        vec3 normal=res.xyz;
        vec3 lPos=vec3(0,3,3);
        lPos=(m0*vec4(lPos,0)).xyz;
        vec3 color=lightColor(ro,rd,normal,lPos,t);
        return color;
        //return vec3(1);
    }
    else return vec3(0.8,0.9,1);
}

vec3 rayCastNaive(in vec3 ro,in vec3 rd){
    float max=100.0;
    float t=0.0;
    float dt=0.01;
    float eplison=0.01;
    vec3 sPos=vec3(0,1,0);
    float radius=0.2;
    vec4 res=sphereIntersection(sPos,ro,radius);
    for(int i=0;i<1000;++i){
        if(t>max||res.w<eplison) break;
       	t+=dt;
        res=sphereIntersection(sPos,ro+t*rd,radius);
    }
    if(res.w<eplison) return vec3(1);
    else return vec3(0.8,0.9,1);
}

vec4 map( in vec3 pos )
{
   	vec4 res=sphereIntersection(vec3(0.0,0.25,0.0),pos,0.25);
    vec4 res1=cubeIntersection(vec3(0.5,0.25,0.6),pos,0.4);
    vec4 res2=cylinderIntersection(vec3(-0.6,0.5,0.4),pos,0.8,0.3);
    vec4 res3=groundIntersection(vec3(0,0,0),pos);
    if(res.w>res1.w) res=res1;
    if(res.w>res2.w) res=res2;
    if(res.w>res3.w) res=res3;
    return res;
}

float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
    float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ )
    {
        float h = map( ro + rd*t ).w;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map(aopos).w;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 rayCastAO(in vec3 ro,in vec3 rd){
    float max=50.0;
    float t=0.01;
    float eplison=0.00001;
    vec4 res;
    vec3 color;
    for(int i=0;i<1000;++i){
        res=map(ro+t*rd);
        if(abs(res.w)<eplison||t>max) break;
        t+=res.w;
    }
    if(t<max){
    	//float m = res.y;
        float m=2.0;
        vec3 pos = ro + t*rd;
        vec3 nor = res.xyz;
        vec3 ref = reflect( rd, nor );
        
        // material        
        color = 0.45 + 0.3*sin( vec3(0.05,0.08,0.10)*(m-1.0) );
        
        if( m<1.5 )
        {
            float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
            color = 0.4 + 0.1*f*vec3(1.0);
        }

        // lighitng        
        float occ = calcAO( pos, nor );
        vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
        float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
        float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
        float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, ref.y );
        float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
        float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);
        
        dif *= softshadow( pos, lig, 0.02, 2.5 );
        dom *= softshadow( pos, ref, 0.02, 2.5 );

        vec3 brdf = vec3(0.0);
        brdf += 1.20*dif*vec3(1.00,0.90,0.60);
        brdf += 1.20*spe*vec3(1.00,0.90,0.60)*dif;
        brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
        brdf += 0.30*bac*vec3(0.25,0.25,0.25)*occ;
        brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
        brdf += 0.02;
        color = color*brdf;

        color = mix( color, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*t*t ) );

	    return vec3( clamp(color,0.0,1.0) );
    }
    return vec3(0.8,0.9,1);
}

vec3 rayCastDebug(in vec3 ro,in vec3 rd){
    float max=20.0;
    float t=0.01;
    float eplison=0.00001;
    vec4 res;
    vec3 color;
    for(int i=0;i<1000;++i){
        res=map(ro+t*rd);
        if(abs(res.w)<eplison||t>max) break;
        t+=res.w;
    }
    return vec3(1)*t/max;
}

float hash( float n ) { return fract(sin(n)*753.5453123); }

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}

float heightFun(float x,float z){
    float h=noise(vec3(cos(x/1.2),sin(x/1.3)*cos(z/1.3),cos(z/1.4)));
    return 2.0*h;
}

vec3 getNormalInHeightMap(in vec3 p ){
    float eps=0.01;
    vec3 n = vec3( heightFun(p.x-eps,p.z) - heightFun(p.x+eps,p.z),
                         2.0*eps,
                         heightFun(p.x,p.z-eps) - heightFun(p.x,p.z+eps) );
    return normalize( n );
}

vec3 rayCastHeightMap(in vec3 ro,in vec3 rd){
    float max=30.0;
    float t=0.0;
    float dt=0.01;
    ro.y+=2.0;
    for(int i=0;i<2000;++i){
        vec3 pos=ro+t*rd;
        if(pos.y<heightFun(pos.x,pos.z)){ 
            //return t/max*vec3(1);
            vec3 normal=getNormalInHeightMap(ro+t*rd);
            vec3 lightPos=vec3(2,3,4);
            vec3 color=lightColor(ro,rd,normal,lightPos,t);
            vec2 xz=vec2(pos.x,pos.z);
            xz.x-=5.0*floor(xz.x/5.0);
            xz.y-=5.0*floor(xz.y/5.0);
            color = color*texture2D( iChannel1, xz/vec2(5,5) ).xyz;
            return color;
        }
        t+=dt;
        if(t>max) break;
    }
    return vec3(0.8,0.9,1);
}

vec4 cubeFractalIntersection(in vec3 cPos,in vec3 rPos,float len,int level){
    float half_len=len/2.0;
    float Len=len;
    vec3 pos=cPos;
    if(rPos.x>cPos.x+half_len||rPos.x<cPos.x-half_len) return vec4(0);
    if(rPos.y>cPos.y+half_len||rPos.y<cPos.y-half_len) return vec4(0);
    if(rPos.z>cPos.z+half_len||rPos.z<cPos.z-half_len) return vec4(0);
    for(int l=0;l<2;++l){
        float u=0.0,v=0.0,w=0.0;
        if(rPos.x<pos.x+Len/6.0&&rPos.x>pos.x-Len/6.0) u=0.0;
        else if(rPos.x>=pos.x+Len/6.0) u=1.0;
        else u=-1.0;
    	if(rPos.y<pos.y+Len/6.0&&rPos.y>pos.y-Len/6.0) v=0.0;
        else if(rPos.y>=pos.y+Len/6.0) v=1.0;
        else v=-1.0;
        if(rPos.z<pos.z+Len/6.0&&rPos.z>pos.z-Len/6.0) w=0.0;
        else if(rPos.z>=pos.z+Len/6.0) w=1.0;
        else w=-1.0;
        float sum=abs(u)+abs(v)+abs(w);
        if(sum<=1.0) return vec4(0);
        Len/=3.0;
        pos.x+=Len*u;
        pos.y+=Len*v;
        pos.z+=Len*w;
    }
    vec4 m;
    m.xyz=pos;
    m.w=Len;
    return m;
    //vec4 m=cubeIntersection(pos,rPos,Len);
    //m.w=1.0;
    //return m;
    //return vec4(1);
}

vec3 rayCastFractal(in vec3 ro,in vec3 rd){
    float max=50.0;
    float t=0.0;
    float dt=0.01;
    float eplison=0.00001;
    int level=3;
    float len=1.0;
    vec4 res;
    for(int i=0;i<1000;++i){
        res=cubeFractalIntersection(vec3(0),ro+t*rd,len,3);
        //if(t>max) break;
        if(t>max||res.w!=0.0) break;
        t+=dt;
    }
    vec4 m=res;
    if(m.w!=0.0){
        t=0.0;
        vec3 o=m.xyz;
        for(int i=0;i<1000;++i){
            res=cubeIntersection(o,ro+t*rd,m.w);
 	       	if(t>max||abs(res.w)<eplison) break;
    	    t+=res.w;
    	}
        if(res.w<eplison){
        	vec3 normal=res.xyz;
	        vec3 lPos=vec3(0,3,3);
        	vec3 color=lightColor(ro,rd,normal,lPos,t);
	        return color;
	    }
    }
    return vec3(0.8,0.9,1);
}

vec3 render(in vec3 ro, in vec3 rd) {
    // TODO
    #if mode==1
    	vec3 res=rayCastSmart(ro,rd);
    #endif
    #if mode==2
    	vec3 res=rayCastNaive(ro,rd);
    #endif
    #if mode==3
    	vec3 res=rayCastHeightMap(ro,rd);
    #endif
    #if mode==4
    	vec3 res=rayCastFractal(ro,rd);
    #endif
    #if mode==5
    	vec3 res=rayCastAO(ro,rd);
    #endif
    #if mode==6
    	vec3 res=rayCastDebug(ro,rd);
    #endif
    return res;  // camera ray direction debug view
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
    // Starter code from iq's Raymarching Primitives
    // https://www.shadertoy.com/view/Xds3zN

    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    return mat3(cu, cv, cw);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Starter code from iq's Raymarching Primitives
    // https://www.shadertoy.com/view/Xds3zN

    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x / iResolution.y;
    vec2 mo = iMouse.xy / iResolution.xy;

    float time = 15.0 + iGlobalTime;

    // camera
    vec3 ro = vec3(
            -0.5 + 3.5 * cos(0.1 * time + 6.0 * mo.x),
            1.0 + 2.0 * mo.y,
            0.5 + 3.5 * sin(0.1 * time + 6.0 * mo.x));
    vec3 ta = vec3(-0.5, -0.4, 0.5);
    //ro=vec3(0,10,0);
    //ta=vec3(1,0,0);

    // camera-to-world transformation
    mat3 ca = setCamera(ro, ta, 0.0);

    // ray direction
    vec3 rd = ca * normalize(vec3(p.xy, 2.0));
    // render
    vec3 col = render(ro, rd);

    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
} 