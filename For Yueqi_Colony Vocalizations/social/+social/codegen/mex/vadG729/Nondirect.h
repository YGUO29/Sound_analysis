/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Nondirect.h
 *
 * Code generation for function 'Nondirect'
 *
 */

#ifndef NONDIRECT_H
#define NONDIRECT_H

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
extern void Nondirect_stepImpl(const real32_T varargin_1[11], real32_T
  varargout_1[11]);
extern void b_Nondirect_stepImpl(dspcodegen_LevinsonSolver_1 *obj, const
  real32_T varargin_1[3], real32_T varargout_1[2]);

#endif

/* End of code generation (Nondirect.h) */
