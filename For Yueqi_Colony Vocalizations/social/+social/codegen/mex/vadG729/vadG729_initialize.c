/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * vadG729_initialize.c
 *
 * Code generation for function 'vadG729_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "vadG729_initialize.h"
#include "_coder_vadG729_mex.h"
#include "vadG729_data.h"

/* Function Declarations */
static void vadG729_once(void);

/* Function Definitions */
static void vadG729_once(void)
{
  const mxArray *m0;
  static const int32_T iv0[2] = { 0, 0 };

  static const int32_T iv1[2] = { 0, 0 };

  emlrtAssignP(&b_eml_mx, NULL);
  emlrtAssignP(&eml_mx, NULL);
  VAD_var_param_not_empty_init();
  ZCD_not_empty_init();
  LPC2LSF_not_empty_init();
  LEV2_not_empty_init();
  LEV1_not_empty_init();
  AC_not_empty_init();
  HPF_not_empty_init();
  m0 = emlrtCreateNumericArray(2, iv0, mxDOUBLE_CLASS, mxREAL);
  emlrtAssignP(&b_eml_mx, m0);
  m0 = emlrtCreateCharArray(2, iv1);
  emlrtAssignP(&eml_mx, m0);
}

void vadG729_initialize(void)
{
  emlrtStack st = { NULL, NULL, NULL };

  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    vadG729_once();
  }
}

/* End of code generation (vadG729_initialize.c) */
