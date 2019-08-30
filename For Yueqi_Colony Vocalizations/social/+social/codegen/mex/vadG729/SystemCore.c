/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SystemCore.c
 *
 * Code generation for function 'SystemCore'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "SystemCore.h"
#include "Nondirect.h"

/* Variable Definitions */
static emlrtRSInfo t_emlrtRSI = { 1, "SystemCore",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+coder\\SystemCore.p"
};

static emlrtRSInfo u_emlrtRSI = { 1, "Nondirect",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+mixin\\+coder\\Nondirect.p"
};

static emlrtRTEInfo b_emlrtRTEI = { 1, 1, "SystemCore",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\shared\\system\\coder\\+matlab\\+system\\+coder\\SystemCore.p"
};

/* Function Declarations */
static int32_T MWDSP_Poly2Lsfr_S(real32_T lsp[], const real32_T G1[], const
  real32_T G2[], int32_T NSteps, int32_T NBisects, int32_T M1, int32_T M2,
  real32_T bptr[], int32_T P);
static int32_T MWDSP_Poly2Lsp_S(real32_T lsp[], const real32_T G1[], const
  real32_T G2[], int32_T NSteps, int32_T NBisects, int32_T M1, int32_T M2,
  real32_T bptr[]);
static real32_T MWDSP_Poly2Lsp_chebysolve_S(real32_T b[], real32_T x, const
  real32_T f[], int32_T N);
static void c_MWDSP_Poly2Lsp_computeG2andG2(real32_T G1[], real32_T G2[], const
  real32_T lpc[], int32_T orderLPC, int32_T M1);

/* Function Definitions */
static int32_T MWDSP_Poly2Lsfr_S(real32_T lsp[], const real32_T G1[], const
  real32_T G2[], int32_T NSteps, int32_T NBisects, int32_T M1, int32_T M2,
  real32_T bptr[], int32_T P)
{
  int32_T nf;
  int32_T i;
  nf = MWDSP_Poly2Lsp_S((real32_T *)&lsp[0], (real32_T *)&G1[0U], (real32_T *)
                        &G2[0U], NSteps, NBisects, M1, M2, (real32_T *)&bptr[0U]);
  for (i = 0; i < P; i++) {
    lsp[i] = muSingleScalarAcos(lsp[i]);
  }

  return nf;
}

static int32_T MWDSP_Poly2Lsp_S(real32_T lsp[], const real32_T G1[], const
  real32_T G2[], int32_T NSteps, int32_T NBisects, int32_T M1, int32_T M2,
  real32_T bptr[])
{
  int32_T nf;
  boolean_T ip;
  int32_T indx;
  real32_T j;
  real32_T delta;
  real32_T xlow;
  real32_T ylow;
  real32_T xhigh;
  real32_T yhigh;
  int32_T i;
  real32_T xmid;
  real32_T ymid;

  /* number of found frequencies */
  nf = 0;

  /* indicator for f1 or f2 */
  ip = false;
  indx = 0;
  j = 1.0F;
  delta = 2.0F / (real32_T)NSteps;
  xlow = 1.0F;
  ylow = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], 1.0F, (real32_T *)
    &G1[0U], M1);
  while ((nf < (M1 << 1)) && (indx < NSteps)) {
    j -= delta;
    indx++;
    xhigh = xlow;
    yhigh = ylow;
    xlow = j;
    if (!ip) {
      ylow = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], j, (real32_T *)
        &G1[0U], M1);
    } else {
      ylow = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], j, (real32_T *)
        &G2[0U], M2);
    }

    if (ylow * yhigh < 0.0F) {
      /* this indicates that there exists a root between xlow and xhigh
         sub-divide this interval further and find out exact root */
      for (i = 0; i < NBisects; i++) {
        xmid = (xlow + xhigh) / 2.0F;
        if (!ip) {
          ymid = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], xmid,
            (real32_T *)&G1[0U], M1);
        } else {
          ymid = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], xmid,
            (real32_T *)&G2[0U], M2);
        }

        if (ylow * ymid <= 0.0F) {
          yhigh = ymid;
          xhigh = xmid;
        } else {
          ylow = ymid;
          xlow = xmid;
        }
      }

      /* Linear interpolation
         xint = xlow - ylow*(xhigh-xlow)/(yhigh-ylow); */
      if (yhigh - ylow == 0.0F) {
      } else {
        xlow -= ylow * ((xhigh - xlow) / (yhigh - ylow));
      }

      lsp[nf] = xlow;
      nf++;
      ip = !ip;
      if (!ip) {
        ylow = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], xlow,
          (real32_T *)&G1[0U], M1);
      } else {
        ylow = MWDSP_Poly2Lsp_chebysolve_S((real32_T *)&bptr[0U], xlow,
          (real32_T *)&G2[0U], M2);
      }
    }
  }

  return nf;
}

static real32_T MWDSP_Poly2Lsp_chebysolve_S(real32_T b[], real32_T x, const
  real32_T f[], int32_T N)
{
  int32_T k;
  b[N] = 0.0F;
  b[N - 1] = 1.0F;
  for (k = N - 2; k >= 0; k--) {
    b[k] = (2.0F * x * b[k + 1] - b[k + 2]) + f[(N - k) - 1];
  }

  return (x * b[0U] - b[1U]) + f[N] / 2.0F;
}

static void c_MWDSP_Poly2Lsp_computeG2andG2(real32_T G1[], real32_T G2[], const
  real32_T lpc[], int32_T orderLPC, int32_T M1)
{
  int32_T i;

  /* Formulate G1 and G2 polynomials, and deconvolve known roots: */
  /* lpc[0]=1 */
  G1[0U] = 1.0F;
  G2[0U] = 1.0F;
  for (i = 1; i <= M1; i++) {
    G1[i] = (-G1[i - 1] + lpc[i]) + lpc[(orderLPC - i) + 1];
    G2[i] = (G2[i - 1] + lpc[i]) - lpc[(orderLPC - i) + 1];
  }
}

void SystemCore_step(const emlrtStack *sp, dspcodegen_BiquadFilter *obj, const
                     real32_T varargin_1[80], real32_T varargout_1[80])
{
  dspcodegen_BiquadFilter *b_obj;
  dsp_BiquadFilter_0 *c_obj;
  int32_T ioIdx;
  int32_T i;
  real32_T d_obj;
  real32_T stageOut;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized != 2) {
  } else {
    emlrtErrorWithMessageIdR2012b(sp, &b_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &t_emlrtRSI;
    b_obj = obj;
    b_st.site = &t_emlrtRSI;
    if (b_obj->isInitialized == 0) {
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &b_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    b_obj->isInitialized = 1;
    b_st.site = &t_emlrtRSI;

    /* System object Initialization function: dsp.BiquadFilter */
    d_obj = b_obj->cSFunObject.P0_ICRTP;
    for (ioIdx = 0; ioIdx < 2; ioIdx++) {
      b_obj->cSFunObject.W0_FILT_STATES[ioIdx] = d_obj;
    }
  }

  st.site = &t_emlrtRSI;
  b_obj = obj;
  b_st.site = &u_emlrtRSI;
  c_obj = &b_obj->cSFunObject;

  /* System object Outputs function: dsp.BiquadFilter */
  ioIdx = 0;
  for (i = 0; i < 80; i++) {
    d_obj = c_obj->W0_FILT_STATES[0];
    d_obj += c_obj->P1_RTP1COEFF[0] * varargin_1[ioIdx];
    stageOut = d_obj;
    d_obj = c_obj->W0_FILT_STATES[1];
    d_obj += c_obj->P1_RTP1COEFF[1] * varargin_1[ioIdx];
    d_obj -= c_obj->P2_RTP2COEFF[0] * stageOut;
    c_obj->W0_FILT_STATES[0] = d_obj;
    d_obj = c_obj->P1_RTP1COEFF[2] * varargin_1[ioIdx];
    d_obj -= c_obj->P2_RTP2COEFF[1] * stageOut;
    c_obj->W0_FILT_STATES[1] = d_obj;
    varargout_1[ioIdx] = stageOut;
    ioIdx++;
  }
}

void b_SystemCore_step(const emlrtStack *sp, dspcodegen_Autocorrelator *obj,
  const real32_T varargin_1[240], real32_T varargout_1[13])
{
  dspcodegen_Autocorrelator *b_obj;
  int32_T idxout;
  int32_T i;
  real32_T accTmp;
  int32_T idx1;
  int32_T idx2;
  int32_T klen;
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized != 2) {
  } else {
    emlrtErrorWithMessageIdR2012b(sp, &b_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &t_emlrtRSI;
    b_obj = obj;
    b_st.site = &t_emlrtRSI;
    if (b_obj->isInitialized == 0) {
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &b_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    b_obj->isInitialized = 1;
  }

  /* System object Outputs function: dsp.Autocorrelator */
  idxout = 0;
  for (i = 0; i < 13; i++) {
    accTmp = 0.0F;
    idx1 = 0;
    idx2 = i;
    klen = 240 - i;
    for (k = 0; k < klen; k++) {
      accTmp += varargin_1[idx1] * varargin_1[idx2];
      idx1++;
      idx2++;
    }

    varargout_1[idxout] = accTmp;
    idxout++;
  }
}

void c_SystemCore_step(const emlrtStack *sp, dspcodegen_LevinsonSolver *obj,
  const real32_T varargin_1[11], real32_T varargout_1[11])
{
  dspcodegen_LevinsonSolver *b_obj;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized != 2) {
  } else {
    emlrtErrorWithMessageIdR2012b(sp, &b_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &t_emlrtRSI;
    b_obj = obj;
    b_st.site = &t_emlrtRSI;
    if (b_obj->isInitialized == 0) {
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &b_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    b_obj->isInitialized = 1;
  }

  Nondirect_stepImpl(varargin_1, varargout_1);
}

void d_SystemCore_step(const emlrtStack *sp, dspcodegen_LPCToLSF *obj, const
  real32_T varargin_1[11], real32_T varargout_1[10])
{
  dspcodegen_LPCToLSF *b_obj;
  real32_T U0[11];
  int32_T i;
  int32_T nf;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized != 2) {
  } else {
    emlrtErrorWithMessageIdR2012b(sp, &b_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &t_emlrtRSI;
    b_obj = obj;
    b_st.site = &t_emlrtRSI;
    if (b_obj->isInitialized == 0) {
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &b_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    b_obj->isInitialized = 1;
    b_obj->c_NoTuningBeforeLockingCodeGenE = true;
  }

  st.site = &t_emlrtRSI;
  b_obj = obj;
  b_st.site = &u_emlrtRSI;
  for (i = 0; i < 11; i++) {
    U0[i] = varargin_1[i];
  }

  /* System object Outputs function: dsp.LPCToLSF */
  c_MWDSP_Poly2Lsp_computeG2andG2((real32_T *)&b_obj->cSFunObject.W0_G1[0U],
    (real32_T *)&b_obj->cSFunObject.W1_G2[0U], (real32_T *)&U0[0], 10, 5);

  /* Compute LSP vectors */
  nf = MWDSP_Poly2Lsfr_S((real32_T *)&varargout_1[0], (real32_T *)
    &b_obj->cSFunObject.W0_G1[0U], (real32_T *)&b_obj->cSFunObject.W1_G2[0U], 64,
    4, 5, 5, (real32_T *)&b_obj->cSFunObject.W2_Cheby[0U], 10);

  /* Output is LSP */
  for (i = nf; i < 10; i++) {
    varargout_1[nf] = 3.14159274F;
    nf++;
  }
}

void e_SystemCore_step(const emlrtStack *sp, dspcodegen_LevinsonSolver_1 *obj,
  const real32_T varargin_1[3], real32_T varargout_1[2])
{
  dspcodegen_LevinsonSolver_1 *b_obj;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized != 2) {
  } else {
    emlrtErrorWithMessageIdR2012b(sp, &b_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &t_emlrtRSI;
    b_obj = obj;
    b_st.site = &t_emlrtRSI;
    if (b_obj->isInitialized == 0) {
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &b_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    b_obj->isInitialized = 1;
  }

  st.site = &t_emlrtRSI;
  b_Nondirect_stepImpl(obj, varargin_1, varargout_1);
}

uint32_T f_SystemCore_step(const emlrtStack *sp, dspcodegen_ZeroCrossingDetector
  *obj, const real32_T varargin_1[81])
{
  uint32_T varargout_1;
  dspcodegen_ZeroCrossingDetector *b_obj;
  dsp_ZeroCrossingDetector_6 *c_obj;
  int32_T idx;
  int32_T i;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (obj->isInitialized != 2) {
  } else {
    emlrtErrorWithMessageIdR2012b(sp, &b_emlrtRTEI,
      "MATLAB:system:methodCalledWhenReleasedCodegen", 3, 4, 4, "step");
  }

  if (obj->isInitialized != 1) {
    st.site = &t_emlrtRSI;
    b_obj = obj;
    b_st.site = &t_emlrtRSI;
    if (b_obj->isInitialized == 0) {
    } else {
      emlrtErrorWithMessageIdR2012b(&b_st, &b_emlrtRTEI,
        "MATLAB:system:methodCalledWhenLockedReleasedCodegen", 3, 4, 5, "setup");
    }

    b_obj->isInitialized = 1;
    b_st.site = &t_emlrtRSI;

    /* System object Initialization function: dsp.ZeroCrossingDetector */
    b_obj->cSFunObject.W0_InputBuffer = 0.0F;
  }

  st.site = &t_emlrtRSI;
  b_obj = obj;
  b_st.site = &u_emlrtRSI;
  c_obj = &b_obj->cSFunObject;

  /* System object Outputs function: dsp.ZeroCrossingDetector */
  idx = 0;
  varargout_1 = 0U;
  for (i = 0; i < 81; i++) {
    if (((c_obj->W0_InputBuffer < 0.0F) && (varargin_1[idx] > 0.0F)) ||
        ((c_obj->W0_InputBuffer > 0.0F) && (varargin_1[idx] < 0.0F))) {
      varargout_1++;
    }

    if (varargin_1[idx] != 0.0F) {
      c_obj->W0_InputBuffer = varargin_1[idx];
    }

    idx++;
  }

  return varargout_1;
}

/* End of code generation (SystemCore.c) */
