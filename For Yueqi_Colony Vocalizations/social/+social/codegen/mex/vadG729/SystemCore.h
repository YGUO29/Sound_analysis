/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SystemCore.h
 *
 * Code generation for function 'SystemCore'
 *
 */

#ifndef SYSTEMCORE_H
#define SYSTEMCORE_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mwmathutil.h"
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "vadG729_types.h"

/* Function Declarations */
extern void SystemCore_step(const emlrtStack *sp, dspcodegen_BiquadFilter *obj,
  const real32_T varargin_1[80], real32_T varargout_1[80]);
extern void b_SystemCore_step(const emlrtStack *sp, dspcodegen_Autocorrelator
  *obj, const real32_T varargin_1[240], real32_T varargout_1[13]);
extern void c_SystemCore_step(const emlrtStack *sp, dspcodegen_LevinsonSolver
  *obj, const real32_T varargin_1[11], real32_T varargout_1[11]);
extern void d_SystemCore_step(const emlrtStack *sp, dspcodegen_LPCToLSF *obj,
  const real32_T varargin_1[11], real32_T varargout_1[10]);
extern void e_SystemCore_step(const emlrtStack *sp, dspcodegen_LevinsonSolver_1 *
  obj, const real32_T varargin_1[3], real32_T varargout_1[2]);
extern uint32_T f_SystemCore_step(const emlrtStack *sp,
  dspcodegen_ZeroCrossingDetector *obj, const real32_T varargin_1[81]);

#endif

/* End of code generation (SystemCore.h) */
