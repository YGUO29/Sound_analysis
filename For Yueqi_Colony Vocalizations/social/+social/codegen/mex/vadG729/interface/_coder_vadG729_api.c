/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_vadG729_api.c
 *
 * Code generation for function '_coder_vadG729_api'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "_coder_vadG729_api.h"
#include "vadG729_data.h"

/* Function Declarations */
static real32_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId))[80];
static real32_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[80];
static real32_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *speech,
  const char_T *identifier))[80];
static const mxArray *emlrt_marshallOut(const real32_T u);

/* Function Definitions */
static real32_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId))[80]
{
  real32_T (*y)[80];
  y = c_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}
  static real32_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[80]
{
  real32_T (*ret)[80];
  static const int32_T dims[1] = { 80 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "single", false, 1U, dims);
  ret = (real32_T (*)[80])mxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static real32_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray *speech,
  const char_T *identifier))[80]
{
  real32_T (*y)[80];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(speech), &thisId);
  emlrtDestroyArray(&speech);
  return y;
}
  static const mxArray *emlrt_marshallOut(const real32_T u)
{
  const mxArray *y;
  const mxArray *m1;
  y = NULL;
  m1 = emlrtCreateNumericMatrix(1, 1, mxSINGLE_CLASS, mxREAL);
  *(real32_T *)mxGetData(m1) = u;
  emlrtAssign(&y, m1);
  return y;
}

void vadG729_api(const mxArray * const prhs[2], const mxArray *plhs[1])
{
  static const uint32_T VAD_cst_param[4] = { 2328051454U, 1889955647U,
    729510072U, 1710874210U };

  real32_T (*speech)[80];
  real32_T vad_flag;
  emlrtStack st = { NULL, NULL, NULL };

  st.tls = emlrtRootTLSGlobal;

  /* Check constant function inputs */
  emlrtCheckArrayChecksumR2014a(&st, "VAD_cst_param", VAD_cst_param, prhs[1],
    false);

  /* Marshall function inputs */
  speech = emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "speech");

  /* Invoke the target function */
  vad_flag = vadG729(&st, *speech);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(vad_flag);
}

/* End of code generation (_coder_vadG729_api.c) */
