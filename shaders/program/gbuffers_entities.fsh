#include "/lib/constants.glsl"
#include "/lib/common.glsl"

in VertexData {
    vec4 color;
    vec2 lmcoord;
    vec2 texcoord;
    vec3 localPos;
    vec3 localNormal;
} vIn;


uniform sampler2D gtexture;

#if LIGHTING_MODE == LIGHTING_MODE_VANILLA
    uniform sampler2D lightmap;
#endif

#ifdef IRIS_FEATURE_SEPARATE_HARDWARE_SAMPLERS
    uniform sampler2DShadow shadowtex1HW;
#else
    uniform sampler2D shadowtex1;
#endif

uniform vec4 entityColor;
uniform float alphaTestRef;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#include "/lib/sampling/lightmap.glsl"

#ifdef SHADOWS_ENABLED
    #include "/lib/shadows.glsl"
#endif

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 outFinal;


void main() {
	float mip = textureQueryLod(gtexture, vIn.texcoord).y;

	vec4 color = textureLod(gtexture, vIn.texcoord, mip);

//    #if defined(RENDER_OPAQUE)
        if (color.a < alphaTestRef) discard;
//    #endif

	color *= vIn.color;

    color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);

    vec3 albedo = RGBToLinear(color.rgb);

    float shadow = 1.0;
    #ifdef SHADOWS_ENABLED
        vec3 shadowPos = mul3(shadowModelView, vIn.localPos);
        shadowPos.z += 0.16;
        shadowPos = (shadowProjection * vec4(shadowPos, 1.0)).xyz;

        distort(shadowPos.xy);
        shadowPos = shadowPos * 0.5 + 0.5;

        #ifdef IRIS_FEATURE_SEPARATE_HARDWARE_SAMPLERS
            shadow = texture(shadowtex1HW, shadowPos).r;
        #else
            float shadowDepth = textureLod(shadowtex1, shadowPos.xy, 0).r;
            shadow = step(shadowPos.z, shadowDepth);
        #endif
    #endif

    #if LIGHTING_MODE == LIGHTING_MODE_CUSTOM
        // TODO
        color.rgb = albedo.rgb;
    #else
        vec2 lmcoord = vIn.lmcoord;
        vec3 localNormal = normalize(vIn.localNormal);

        lmcoord.y = min(lmcoord.y, shadow * 0.5 + 0.5);

        float sky_lit = dot(localNormal * localNormal, vec3(0.6, 0.25 * localNormal.y + 0.75, 0.8));
        lmcoord.y *= sky_lit;

        lmcoord = LightMapTex(lmcoord);
        vec3 lit = textureLod(lightmap, lmcoord, 0).rgb;
        lit = RGBToLinear(lit);

        color.rgb = albedo.rgb * lit;
    #endif

    outFinal = color;
}
