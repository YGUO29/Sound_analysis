/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mod.h
 *
 * Code generation for function 'mod'
 *
 */

#ifndef MOD_H
#define MOD_H

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
extern real32_T b_mod(real32_T x, real32_T y);

#ifdef __WATCOMC__

#pragma aux b_mod value [8087];

#endif
#endif

/* End of code generation (mod.h) */
