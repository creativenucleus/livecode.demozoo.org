#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texSessions;
uniform sampler2D texSessionsShort;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float time = fGlobalTime;
float fft = texture(texFFTIntegrated, 0.2).r;
const float E = 0.001;
const float F = 100;
const int STEPS = 64;

vec3 glow = vec3(0.);

float box(vec3 p, vec3 b){
  vec3 d = abs(p)-b;
  return length(max(d, 0.0) + min(max(d.x, max(d.y, d.z)), 0.0));
}
float sphere(vec3 p, float r){
  return length(p)-r;
}

void rot(inout vec2 p, float a){
  p = cos(a)*p + sin(a)* vec2(p.y, -p.x);
}

float scene(vec3 p){
  
  vec3 pp = p;
  float safe = sphere(p, 2.0);
  
  for(int i = 0; i < 7; ++i){
    pp = abs(pp) - vec3(5.0);
    rot(pp.xy, fft+time*0.1);
    rot(pp.xz, fft*2.0);
    rot(pp.yz, fft);
  }
  
  float b = box(pp, vec3(0.05, 0.05, F));
  float lr = box(pp, vec3(F, 1.0, 1.0));
  
  vec3 g = vec3(0.5, 0.1, 0.9) * 0.05 / (abs(lr) + 0.05);
  g += vec3(0.6, 0.2, 0.1) * 0.01 / (abs(b) + 0.05);
  g *= 0.5;
  
  glow += g;
  
  return max(b, -safe);
}

float march(vec3 ro, vec3 rd){
  vec3 p = ro;
  float t = E;
  
  for(int i = 0; i < STEPS; ++i){
    float d = scene(p);
    t += d;
    
    if(d < E || t > F){
      break;
    }
    
    p = ro + rd * t;
  }
  
  return t;
}

void main(void)
{
	vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
	vec2 q = uv - 0.5;
	q /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  vec3 ro = vec3 (0.0, 0.0, 0.0);
  vec3 rt = vec3(0.0, 0.0, -1.0);
  
  vec3 z = normalize(rt-ro);
  vec3 x = normalize(cross(z, vec3(0., 1., 0.)));
  vec3 y = normalize(cross(x, z));
  
  vec3 rd = normalize(mat3(x,y,z) * vec3(q, 1.0/radians(60.0)));
  
  float t = march(ro, rd);
  
  vec3 col = vec3(0.0);
  if(t < F){
    col = vec3(0.5);
  }
  col += glow;
  
  
  vec3 sessions = texture(texSessions, vec2(uv.x, -uv.y)).rgb;
  //sessions += vec3(0.2, 0.1, 0.2);
  //sessions += glow;
  
  sessions = 1.0-sessions;
  
  col *= sessions;
  
  col = smoothstep(-0.1, 1.0, col);
  
  vec3 prev = texture(texPreviousFrame, uv).rgb;
  
  col += prev * 0.8;
  
  col *= 0.5;
  
  

	out_color = vec4(col, 1.0);
}