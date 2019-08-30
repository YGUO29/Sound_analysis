/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * BiquadFilter.c
 *
 * Code generation for function 'BiquadFilter'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "BiquadFilter.h"

/* Function Definitions */
dspcodegen_BiquadFilter *BiquadFilter_BiquadFilter(dspcodegen_BiquadFilter *obj)
{
  dspcodegen_BiquadFilter *b_obj;
  dspcodegen_BiquadFilter *c_obj;
  dsp_BiquadFilter_0 *d_obj;
  int32_T i;
  static const real32_T fv7[3] = { 0.927274346F, -1.85449409F, 0.927274346F };

  static const real32_T fv8[2] = { -1.90594649F, 0.911402404F };

  b_obj = obj;
  c_obj = b_obj;
  c_obj->isInitialized = 0;
  d_obj = &b_obj->cSFunObject;

  /* System object Constructor function: dsp.BiquadFilter */
  d_obj->P0_ICRTP = 0.0F;
  for (i = 0; i < 3; i++) {
    d_obj->P1_RTP1COEFF[i] = fv7[i];
  }

  for (i = 0; i < 2; i++) {
    d_obj->P2_RTP2COEFF[i] = fv8[i];
  }

  for (i = 0; i < 2; i++) {
    d_obj->P3_RTP3COEFF[i] = 1.0F - (real32_T)i;
  }

  for (i = 0; i < 2; i++) {
    d_obj->P4_RTP_COEFF3_BOOL[i] = false;
  }

  return b_obj;
}

/* End of code generation (BiquadFilter.c) */
