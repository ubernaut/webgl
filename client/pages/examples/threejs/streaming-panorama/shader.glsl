varying vec2 texCoord;
varying vec2 vUv;

uniform int imageNum;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform sampler2D iChannel4;
uniform sampler2D iChannel5;
uniform sampler2D iChannel6;
uniform sampler2D iChannel7;
uniform sampler2D iChannel8;

mat2 rotate2d(float theta){
  return mat2(cos(theta), -sin(theta),
              sin(theta),  cos(theta));
}

mat2 scale(float sx, float sy){
  return mat2(1.0/sx, 0.0,
              0.0,    1.0/sy);
}

vec2 distort(vec2 uv, float k1, float k2, float k3)
{
    uv = uv * 2.0 - 1.0;	// brown conrady takes [-1:1]

    // positive values of K1 give barrel distortion, negative give pincushion
    float r2 = uv.x*uv.x + uv.y*uv.y;
    uv.x *= 1.0 + k1 * r2 + k2 * r2 * r2;

    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here

    uv = (uv * .5 + .5);	// restore -> [0:1]
    return uv;
}

vec2 distortY(vec2 uv, float k1, float k2, float k3)
{
    uv = uv * 2.0 - 1.0;	// brown conrady takes [-1:1]

    // positive values of K1 give barrel distortion, negative give pincushion
    float r2 = uv.x*uv.x + uv.y*uv.y;
    uv.y *= 1.0 + k1 * r2 + k2 * r2 * r2;

    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here

    uv = (uv * .5 + .5);	// restore -> [0:1]
    return uv;
}

vec2 distort1(vec2 uv, float a, float b, float c)
{
    uv = uv * 2.0 - 1.0;	// brown conrady takes [-1:1]

    // positive values of K1 give barrel distortion, negative give pincushion
    float r2 = uv.x*uv.x + uv.y*uv.y;
    float d = 1.0 - (a + b + c);
    uv *= (a*pow(r2, 3.0) + b*pow(r2, 2.0) + c*r2 + d)*r2;

    // tangential distortion (due to off center lens elements)
    // is not modeled in this function, but if it was, the terms would go here

    uv = (uv * .5 + .5);	// restore -> [0:1]
    return uv;
}

vec4 map(int channel, vec2 uv){
  vec4 res = vec4(0.0);
  switch (channel) {
  case 0: res = texture(iChannel0, uv); break;
  case 1: res = texture(iChannel1, uv); break;
  case 2: res = texture(iChannel2, uv); break;
  case 3: res = texture(iChannel3, uv); break;
  case 4: res = texture(iChannel4, uv); break;
  case 5: res = texture(iChannel5, uv); break;
  case 6: res = texture(iChannel6, uv); break;
  case 7: res = texture(iChannel7, uv); break;
  case 8: res = texture(iChannel8, uv); break;
  }
  return res;
}

void main(){
  float vfov = 2.0;
  vec2 uv = vec2(vUv);
  int channel = 99;
  float lighten = 1.0;

  float distortA = -0.085;
  float distortB = 0.000;
  float distortC = 0.00;
  float vshift = 0.05;

  if (imageNum == 0) {
    if (vUv.x <= 0.27) {
      channel = 0;
      uv.x = 1.0 - (uv.x - 0.012) * 4.0;
      uv.y += vshift;
      uv = distort(uv, distortA, distortB, distortC);
      uv.y -= vshift;
      // uv *= rotate2d(radians(0.2));
      // lighten = 1.2;
    }
  }

  if (imageNum == 3) {
    if (vUv.x <= 2.0 * 0.27 && vUv.x > 0.25) {
      channel = 3;
      uv.x = 1.0 - (uv.x - 0.27) * 4.05;
      uv.y += vshift;
      uv = distort(uv, distortA, distortB, distortC);
      uv.y -= vshift;
      // uv *= rotate2d(radians(0.5));
      // uv.y += 0.01;
      lighten = 1.1;
    }
  }

  if (imageNum == 2) {
    if (vUv.x <= 3.0 * 0.28 && vUv.x > 0.5) {
      channel = 2;
      uv.x = 1.0 - (uv.x - 0.5225) * 4.05;
      uv.y += vshift;
      uv = distort(uv, distortA, distortB, distortC);
      uv.y -= vshift;
      // uv *= rotate2d(radians(0.5));
      // uv.y += 0.03;
      lighten = 1.0;
    }
  }
  //
  if (imageNum == 1) {
    if (vUv.x <= 4.2 * 0.27 && vUv.x > 0.75) {
      channel = 1;
      uv.x = 1.0 - (uv.x - 0.751) * 4.05;
      uv.y += vshift;
      uv = distort(uv, distortA, distortB, distortC);
      uv.y -= vshift;
      // uv *= rotate2d(radians(-0.2));
      uv.y += 0.008;
    }
  }

  // if (vUv.x <= 0.)

  // if (vUv.x <= 0.164) {
  //   channel = 0;
  //   uv.x = 1.0 - uv.x * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   // uv *= scale(1.33, 1.0);
  //   uv *= rotate2d(radians(0.4));
  //   // lighten = 1.3;
  //   // uv.x += 0.09;
  //
  // } else if (vUv.x <= 0.25) {
  //   channel = 7;
  //   uv.x = 1.0 - (uv.x - 0.125) * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv *= scale(1.33, 1.0);
  //   uv *= rotate2d(radians(0.5));
  //   // uv.x += 0.125;
  //
  // } else if (vUv.x <= 0.375) {
  //   channel = 6;
  //   uv.x = 1.0 - (uv.x - 0.25) * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv *= scale(1.33, 1.0);
  //   uv *= rotate2d(radians(-0.1));
  //   // uv.y += 0.03;
  //   // uv.x += 0.12;
  //
  // } else if (vUv.x <= 0.5) {
  //   channel = 5;
  //   uv.x = 1.0 - (uv.x - 0.375) * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv *= scale(1.33, 1.0);
  //   uv *= rotate2d(radians(-0.1));
  //   // uv.x += 0.09;
  //   // uv.y += 0.01;
  //
  // } else if (vUv.x <= 0.656) {
  //   channel = 4;
  //   uv.x = 1.0 - (uv.x - 0.5) * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv *= scale(1.33, 1.0);
  //   uv *= rotate2d(radians(0.7));
  //   // uv.x += 0.08;
  //   // lighten = 0.0;
  //
  // } else if (vUv.x <= 0.8208) {
  //   channel = 3;
  //   uv.x = 1.0 - (uv.x - 0.656) * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv *= scale(1.313, 1.0);
  //   uv.x += 0.3133 / 2.0;
  //   uv *= rotate2d(radians(0.5));
  //   uv.x += -0.2/360.0 * 8.0;
  //   uv.y -= 0.3/360.0 * 16.0;
  //   lighten *= 1.2;
  //
  // } else if (vUv.x <= 0.875) {
  //   channel = 2;
  //   uv.x = 1.0 - (uv.x - 0.75) * 8.0;
  //   uv.y -= 0.2;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv.y += 0.2;
  //   uv *= rotate2d(radians(0.5));
  //   uv *= scale(1.313, 1.0);
  //   uv.x += 0.3133 / 2.0;
  //   uv.x += 0.1/360.0 * 8.0;
  //   // uv.y += 0.01;
  //   lighten *= 1.2;
  //
  // } else {
  //   channel = 1;
  //   uv.x = 1.0 - (uv.x - 0.875) * 8.0;
  //   uv = distort(uv, distortA, distortB, distortC);
  //   uv *= scale(1.3133, 1.0);
  //   uv.x += 0.3133 / 2.0;
  //   uv *= rotate2d(radians(0.2));
  //   uv.x += -0.8/360.0 * 8.0;
  //   // uv.y += 0.3;
  //   lighten = 1.1;
  // }

  float blendFactor = 24.0;
  // Set the color to black instead of allowing the texture to repeat
  if (uv.y < 0.0 || uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0) {
    gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    // Linear blend the edges
    if (channel != 99) {
      gl_FragColor = map(channel, uv) * lighten;
      if (uv.x > 0.85 && vUv.x > 0.15 && vUv.x < 0.85) {
        gl_FragColor.a = min(1.0, (1.0 - uv.x) * blendFactor);
      } else {
        gl_FragColor.a = min(1.0, uv.x * blendFactor);
      }
    }
  }

  // if (channel == 2) {
  //   if ((uv.x > 0.35 && uv.x < 0.45) || (uv.x > 0.55 && uv.x < 0.65)) {
  //     if (uv.y > 0.95) {
  //       gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  //     }
  //   }
  // }

  // float overlap = 0.1;
  // if (channel == 1) {
  //   if (uv.x > 0.8) {
  //     gl_FragColor = map(2, vec2(1.0 - uv.x, uv.y));
  //   }
  // }
  // if (channel == 2) {
  //   if (uv.x < overlap) {
  //     vec2 uv1 = vec2(uv);
  //     // uv1.x = 1.0 - (((1.0 - overlap) + uv1.x) - 0.875) * 8.0;
  //     uv1 *= rotate2d(-0.005);
  //     uv1 *= scale(1.35, 1.0);
  //     uv1.x += 0.09;
  //     uv1.y += 0.01;
      // gl_FragColor = vec4(0.0);
      // gl_FragColor += (uv.x/overlap) * map(channel, uv) * lighten;
  //     // gl_FragColor += (uv1.x/overlap) * map(1, uv1);
  //     gl_FragColor += (1.0 - (uv1.x/overlap)) * map(1, vec2((1.0 - overlap) + uv1.x, uv1.y));
    // }
    // if (uv.x < 0.15) {
    //   gl_FragColor = vec4(1.0, 0.0, 0.0, 0.0);
    // }
  // }

  // if (channel == 2) {
  //   vec2 uv2 = vUv;
  //   uv2.x = 1.0 - (uv2.x - 0.75) * 8.0;
  //   if (uv2.x > (1.0 - overlap)) {
  //     gl_FragColor = vec4(1.0);
  //     gl_FragColor = vec4(0.0);
  //     gl_FragColor += ((1.0 - uv2.x)/overlap) * map(channel, uv) * lighten;
  //   }
  // }
  // if (channel == 3) {
  //   vec2 uv3 = vUv;
  //   uv3.x = 1.0 - (uv3.x - 0.625) * 8.0;
  //   vec2 uv2 = uv3;
  //   // uv2.x = 1.0 - (uv2.x - 0.75) * 8.0;
  //   uv2 *= rotate2d(-0.05);
  //   uv2 *= scale(1.35, 0.9);
  //   uv2.x -= 0.095;
  //   uv2.y += -0.015;
  //   if (uv3.x < overlap) {
  //     gl_FragColor = vec4(0.0);
  //     // gl_FragColor += (uv3.x/overlap) * map(channel, uv) * lighten;
  //     gl_FragColor += (1.0 - (uv3.x/overlap)) * map(2, vec2((1.0 - overlap) + uv2.x, uv2.y)) * 1.2;
  //   }
  // }

  // Chop a little off the top and bottom for a clean edge
  // if (vUv.y < 0.025 || vUv.y > 0.9) {
  //   gl_FragColor = vec4(0.0);
  // }

  // uv = vUv;
  // uv.x = 1.0 - uv.x;
  // gl_FragColor = map(8, uv);
}
