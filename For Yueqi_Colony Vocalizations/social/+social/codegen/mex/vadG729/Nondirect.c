/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Nondirect.c
 *
 * Code generation for function 'Nondirect'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "Nondirect.h"

/* Function Definitions */
void Nondirect_stepImpl(const real32_T varargin_1[11], real32_T varargout_1[11])
{
  boolean_T isIEven;
  real32_T rTmpP;
  int32_T offset1;
  int32_T i;
  real32_T acc;
  int32_T offset2;
  int32_T j;
  int32_T upLim;
  real32_T rTmpA;

  /* System object Outputs function: dsp.LevinsonSolver */
  if (varargin_1[0] == 0.0F) {
    varargout_1[0] = 1.0F;
    offset1 = 1;
    for (i = 0; i < 10; i++) {
      varargout_1[offset1] = 0.0F;
      offset1++;
    }
  } else {
    isIEven = false;
    rTmpP = varargin_1[0];
    for (i = 0; i < 10; i++) {
      acc = varargin_1[i + 1];
      offset1 = 1;
      offset2 = i;
      for (j = 1; j < i + 1; j++) {
        acc += varargout_1[offset1] * varargin_1[offset2];
        offset1++;
        offset2--;
      }

      acc *= -(1.0F / rTmpP);
      rTmpP *= 1.0F - acc * acc;
      upLim = i >> 1;
      offset1 = 1;
      offset2 = i;
      for (j = 1; j <= upLim; j++) {
        rTmpA = varargout_1[offset1];
        varargout_1[offset1] += acc * varargout_1[offset2];
        varargout_1[offset2] += acc * rTmpA;
        offset1++;
        offset2--;
      }

      if (isIEven) {
        offset1 = (i + 1) >> 1;
        varargout_1[offset1] += acc * varargout_1[offset1];
      }

      isIEven = !isIEven;
      varargout_1[i + 1] = acc;
    }

    varargout_1[0] = 1.0F;
  }
}

void b_Nondirect_stepImpl(dspcodegen_LevinsonSolver_1 *obj, const real32_T
  varargin_1[3], real32_T varargout_1[2])
{
  dspcodegen_LevinsonSolver_1 *b_obj;
  dsp_LevinsonSolver_3 *c_obj;
  int32_T iK;
  boolean_T isIEven;
  int32_T i;
  real32_T rTmpP;
  real32_T acc;
  int32_T offset2;
  int32_T j;
  real32_T rTmpK;
  real32_T rTmpA1;
  b_obj = obj;
  c_obj = &b_obj->cSFunObject;

  /* System object Outputs function: dsp.LevinsonSolver */
  iK = 0;
  if (varargin_1[0] == 0.0F) {
    for (i = 0; i < 2; i++) {
      varargout_1[iK] = 0.0F;
      iK++;
    }
  } else {
    isIEven = false;
    rTmpP = varargin_1[0];
    for (i = 0; i < 2; i++) {
      acc = varargin_1[i + 1];
      iK = 1;
      offset2 = i;
      j = 1;
      while (j < i + 1) {
        rTmpK = c_obj->W0_ACOEF_DWORK_IDX[iK] * varargin_1[offset2];
        acc += rTmpK;
        iK++;
        offset2--;
        j = 2;
      }

      rTmpK = acc * -(1.0F / rTmpP);
      rTmpP *= 1.0F - rTmpK * rTmpK;
      if (isIEven) {
        iK = (i + 1) >> 1;
        acc = c_obj->W0_ACOEF_DWORK_IDX[iK];
        rTmpA1 = c_obj->W0_ACOEF_DWORK_IDX[iK];
        acc += rTmpK * rTmpA1;
        c_obj->W0_ACOEF_DWORK_IDX[iK] = acc;
      }

      isIEven = !isIEven;
      c_obj->W0_ACOEF_DWORK_IDX[i + 1] = rTmpK;
      varargout_1[i] = rTmpK;
    }

    b_obj->cSFunObject.W0_ACOEF_DWORK_IDX[0] = 1.0F;
  }
}

/* End of code generation (Nondirect.c) */
