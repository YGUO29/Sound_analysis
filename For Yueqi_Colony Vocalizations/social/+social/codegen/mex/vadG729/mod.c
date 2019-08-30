/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mod.c
 *
 * Code generation for function 'mod'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "mod.h"

/* Function Definitions */
real32_T b_mod(real32_T x, real32_T y)
{
  real32_T r;
  if (y == 0.0F) {
    r = x;
  } else if (y == muSingleScalarFloor(y)) {
    r = x - muSingleScalarFloor(x / y) * y;
  } else {
    r = x / y;
    r = (r - muSingleScalarFloor(r)) * y;
  }

  return r;
}

/* End of code generation (mod.c) */
