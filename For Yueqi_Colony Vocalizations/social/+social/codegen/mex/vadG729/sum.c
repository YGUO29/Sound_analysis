/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sum.c
 *
 * Code generation for function 'sum'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "sum.h"

/* Function Definitions */
real32_T b_sum(const real32_T x[10])
{
  real32_T y;
  int32_T k;
  y = x[0];
  for (k = 0; k < 9; k++) {
    y += x[k + 1];
  }

  return y;
}

real32_T sum(const real32_T x[12])
{
  real32_T y;
  int32_T k;
  y = x[0];
  for (k = 0; k < 11; k++) {
    y += x[k + 1];
  }

  return y;
}

/* End of code generation (sum.c) */
