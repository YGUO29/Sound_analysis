/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * power.c
 *
 * Code generation for function 'power'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "power.h"

/* Function Definitions */
void power(const real32_T a[10], real32_T y[10])
{
  int32_T k;
  for (k = 0; k < 10; k++) {
    y[k] = a[k] * a[k];
  }
}

/* End of code generation (power.c) */
