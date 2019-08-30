/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * vadG729_types.h
 *
 * Code generation for function 'vadG729'
 *
 */

#ifndef VADG729_TYPES_H
#define VADG729_TYPES_H

/* Include files */
#include "rtwtypes.h"

/* Type Definitions */
#ifndef struct_dsp_Autocorrelator_1
#define struct_dsp_Autocorrelator_1

struct dsp_Autocorrelator_1
{
  int32_T S0_isInitialized;
};

#endif                                 /*struct_dsp_Autocorrelator_1*/

#ifndef typedef_dsp_Autocorrelator_1
#define typedef_dsp_Autocorrelator_1

typedef struct dsp_Autocorrelator_1 dsp_Autocorrelator_1;

#endif                                 /*typedef_dsp_Autocorrelator_1*/

#ifndef struct_dsp_BiquadFilter_0
#define struct_dsp_BiquadFilter_0

struct dsp_BiquadFilter_0
{
  int32_T S0_isInitialized;
  real32_T W0_FILT_STATES[2];
  int32_T W1_PreviousNumChannels;
  real32_T P0_ICRTP;
  real32_T P1_RTP1COEFF[3];
  real32_T P2_RTP2COEFF[2];
  real32_T P3_RTP3COEFF[2];
  boolean_T P4_RTP_COEFF3_BOOL[2];
};

#endif                                 /*struct_dsp_BiquadFilter_0*/

#ifndef typedef_dsp_BiquadFilter_0
#define typedef_dsp_BiquadFilter_0

typedef struct dsp_BiquadFilter_0 dsp_BiquadFilter_0;

#endif                                 /*typedef_dsp_BiquadFilter_0*/

#ifndef struct_dsp_LPCToLSF_5
#define struct_dsp_LPCToLSF_5

struct dsp_LPCToLSF_5
{
  int32_T S0_isInitialized;
  real32_T W0_G1[6];
  real32_T W1_G2[6];
  real32_T W2_Cheby[6];
  int32_T P0_NSteps;
  int32_T P1_NBisects;
};

#endif                                 /*struct_dsp_LPCToLSF_5*/

#ifndef typedef_dsp_LPCToLSF_5
#define typedef_dsp_LPCToLSF_5

typedef struct dsp_LPCToLSF_5 dsp_LPCToLSF_5;

#endif                                 /*typedef_dsp_LPCToLSF_5*/

#ifndef struct_dsp_LevinsonSolver_2
#define struct_dsp_LevinsonSolver_2

struct dsp_LevinsonSolver_2
{
  int32_T S0_isInitialized;
};

#endif                                 /*struct_dsp_LevinsonSolver_2*/

#ifndef typedef_dsp_LevinsonSolver_2
#define typedef_dsp_LevinsonSolver_2

typedef struct dsp_LevinsonSolver_2 dsp_LevinsonSolver_2;

#endif                                 /*typedef_dsp_LevinsonSolver_2*/

#ifndef struct_dsp_LevinsonSolver_3
#define struct_dsp_LevinsonSolver_3

struct dsp_LevinsonSolver_3
{
  int32_T S0_isInitialized;
  real32_T W0_ACOEF_DWORK_IDX[3];
};

#endif                                 /*struct_dsp_LevinsonSolver_3*/

#ifndef typedef_dsp_LevinsonSolver_3
#define typedef_dsp_LevinsonSolver_3

typedef struct dsp_LevinsonSolver_3 dsp_LevinsonSolver_3;

#endif                                 /*typedef_dsp_LevinsonSolver_3*/

#ifndef struct_dsp_ZeroCrossingDetector_6
#define struct_dsp_ZeroCrossingDetector_6

struct dsp_ZeroCrossingDetector_6
{
  int32_T S0_isInitialized;
  real32_T W0_InputBuffer;
};

#endif                                 /*struct_dsp_ZeroCrossingDetector_6*/

#ifndef typedef_dsp_ZeroCrossingDetector_6
#define typedef_dsp_ZeroCrossingDetector_6

typedef struct dsp_ZeroCrossingDetector_6 dsp_ZeroCrossingDetector_6;

#endif                                 /*typedef_dsp_ZeroCrossingDetector_6*/

#ifndef typedef_dspcodegen_Autocorrelator
#define typedef_dspcodegen_Autocorrelator

typedef struct {
  int32_T isInitialized;
  dsp_Autocorrelator_1 cSFunObject;
} dspcodegen_Autocorrelator;

#endif                                 /*typedef_dspcodegen_Autocorrelator*/

#ifndef typedef_dspcodegen_BiquadFilter
#define typedef_dspcodegen_BiquadFilter

typedef struct {
  int32_T isInitialized;
  dsp_BiquadFilter_0 cSFunObject;
} dspcodegen_BiquadFilter;

#endif                                 /*typedef_dspcodegen_BiquadFilter*/

#ifndef typedef_dspcodegen_LPCToLSF
#define typedef_dspcodegen_LPCToLSF

typedef struct {
  int32_T isInitialized;
  dsp_LPCToLSF_5 cSFunObject;
  boolean_T c_NoTuningBeforeLockingCodeGenE;
} dspcodegen_LPCToLSF;

#endif                                 /*typedef_dspcodegen_LPCToLSF*/

#ifndef typedef_dspcodegen_LevinsonSolver
#define typedef_dspcodegen_LevinsonSolver

typedef struct {
  int32_T isInitialized;
  dsp_LevinsonSolver_2 cSFunObject;
} dspcodegen_LevinsonSolver;

#endif                                 /*typedef_dspcodegen_LevinsonSolver*/

#ifndef typedef_dspcodegen_LevinsonSolver_1
#define typedef_dspcodegen_LevinsonSolver_1

typedef struct {
  int32_T isInitialized;
  dsp_LevinsonSolver_3 cSFunObject;
} dspcodegen_LevinsonSolver_1;

#endif                                 /*typedef_dspcodegen_LevinsonSolver_1*/

#ifndef typedef_dspcodegen_ZeroCrossingDetector
#define typedef_dspcodegen_ZeroCrossingDetector

typedef struct {
  int32_T isInitialized;
  dsp_ZeroCrossingDetector_6 cSFunObject;
} dspcodegen_ZeroCrossingDetector;

#endif                                 /*typedef_dspcodegen_ZeroCrossingDetector*/
#endif

/* End of code generation (vadG729_types.h) */
