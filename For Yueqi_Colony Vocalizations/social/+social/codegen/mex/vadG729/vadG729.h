/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * vadG729.h
 *
 * Code generation for function 'vadG729'
 *
 */

#ifndef VADG729_H
#define VADG729_H

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
extern void AC_not_empty_init(void);
extern void HPF_not_empty_init(void);
extern void LEV1_not_empty_init(void);
extern void LEV2_not_empty_init(void);
extern void LPC2LSF_not_empty_init(void);
extern void VAD_var_param_not_empty_init(void);
extern void ZCD_not_empty_init(void);
extern real32_T vadG729(const emlrtStack *sp, const real32_T speech[80]);

#ifdef __WATCOMC__

#pragma aux vadG729 value [8087];

#endif
#endif

/* End of code generation (vadG729.h) */
