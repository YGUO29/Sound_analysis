/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Autocorrelator.c
 *
 * Code generation for function 'Autocorrelator'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "Autocorrelator.h"

/* Function Definitions */
dspcodegen_Autocorrelator *Autocorrelator_Autocorrelator
  (dspcodegen_Autocorrelator *obj)
{
  dspcodegen_Autocorrelator *b_obj;
  dspcodegen_Autocorrelator *c_obj;
  b_obj = obj;
  c_obj = b_obj;
  c_obj->isInitialized = 0;

  /* System object Constructor function: dsp.Autocorrelator */
  return b_obj;
}

/* End of code generation (Autocorrelator.c) */
