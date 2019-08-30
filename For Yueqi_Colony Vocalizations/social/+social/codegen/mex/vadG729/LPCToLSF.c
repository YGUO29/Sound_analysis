/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * LPCToLSF.c
 *
 * Code generation for function 'LPCToLSF'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "LPCToLSF.h"

/* Variable Definitions */
static emlrtRSInfo x_emlrtRSI = { 1, "LPCToLSF",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dsp\\compiled\\+dspcodegen\\LPCToLSF.p"
};

static emlrtRTEInfo emlrtRTEI = { 1, 1, "LPCToLSF",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dsp\\compiled\\+dspcodegen\\LPCToLSF.p"
};

/* Function Definitions */
dspcodegen_LPCToLSF *LPCToLSF_LPCToLSF(const emlrtStack *sp, dspcodegen_LPCToLSF
  *obj)
{
  dspcodegen_LPCToLSF *b_obj;
  dspcodegen_LPCToLSF *c_obj;
  dsp_LPCToLSF_5 *d_obj;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  b_obj = obj;
  st.site = &x_emlrtRSI;
  c_obj = b_obj;
  c_obj->isInitialized = 0;
  st.site = &x_emlrtRSI;
  b_obj->c_NoTuningBeforeLockingCodeGenE = true;
  st.site = &x_emlrtRSI;
  d_obj = &b_obj->cSFunObject;

  /* System object Constructor function: dsp.LPCToLSF */
  d_obj->P0_NSteps = 64;
  d_obj->P1_NBisects = 4;
  st.site = &x_emlrtRSI;
  c_obj = b_obj;
  if (c_obj->c_NoTuningBeforeLockingCodeGenE) {
  } else {
    emlrtErrorWithMessageIdR2012b(&st, &emlrtRTEI,
      "MATLAB:system:noTuningBeforeLockingCodeGen", 0);
  }

  c_obj->cSFunObject.P0_NSteps = 64;
  st.site = &x_emlrtRSI;
  c_obj = b_obj;
  if (c_obj->c_NoTuningBeforeLockingCodeGenE) {
  } else {
    emlrtErrorWithMessageIdR2012b(&st, &emlrtRTEI,
      "MATLAB:system:noTuningBeforeLockingCodeGen", 0);
  }

  c_obj->cSFunObject.P1_NBisects = 4;
  b_obj->c_NoTuningBeforeLockingCodeGenE = false;
  return b_obj;
}

/* End of code generation (LPCToLSF.c) */
