/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * vadG729.c
 *
 * Code generation for function 'vadG729'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "vadG729.h"
#include "BiquadFilter.h"
#include "Autocorrelator.h"
#include "LevinsonSolver.h"
#include "ZeroCrossingDetector.h"
#include "power.h"
#include "error.h"
#include "mod.h"
#include "SystemCore.h"
#include "sum.h"
#include "LPCToLSF.h"

/* Type Definitions */
#ifndef typedef_struct_T
#define typedef_struct_T

typedef struct {
  real32_T window_buffer[160];
  real32_T frm_count;
  real32_T MeanLSF[10];
  real32_T MeanSE;
  real32_T MeanSLE;
  real32_T MeanE;
  real32_T MeanSZC;
  real32_T count_sil;
  real32_T count_update;
  real32_T count_ext;
  real32_T less_count;
  real32_T flag;
  real32_T prev_markers[2];
  real32_T prev_energy;
  real32_T Prev_Min;
  real32_T Next_Min;
  real32_T Min_buffer[128];
} struct_T;

#endif                                 /*typedef_struct_T*/

/* Variable Definitions */
static dspcodegen_BiquadFilter HPF;
static boolean_T HPF_not_empty;
static dspcodegen_Autocorrelator AC;
static dspcodegen_LevinsonSolver LEV1;
static dspcodegen_LevinsonSolver_1 LEV2;
static dspcodegen_LPCToLSF LPC2LSF;
static dspcodegen_ZeroCrossingDetector ZCD;
static struct_T VAD_var_param;
static emlrtRSInfo emlrtRSI = { 17, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo b_emlrtRSI = { 21, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo c_emlrtRSI = { 28, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo d_emlrtRSI = { 31, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo e_emlrtRSI = { 36, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo f_emlrtRSI = { 39, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo g_emlrtRSI = { 70, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo h_emlrtRSI = { 81, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo i_emlrtRSI = { 84, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo j_emlrtRSI = { 85, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo k_emlrtRSI = { 88, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo l_emlrtRSI = { 95, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo m_emlrtRSI = { 99, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo n_emlrtRSI = { 102, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo o_emlrtRSI = { 106, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo p_emlrtRSI = { 113, "vadG729",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\dsp\\dspdemos\\vadG729.m" };

static emlrtRSInfo ab_emlrtRSI = { 13, "log10",
  "C:\\Program Files\\MATLAB\\R2016a\\toolbox\\eml\\lib\\matlab\\elfun\\log10.m"
};

/* Function Declarations */
static real32_T vad_decision(real32_T dSLE, real32_T dSE, real32_T SD, real32_T
  dSZC);

/* Function Definitions */
static real32_T vad_decision(real32_T dSLE, real32_T dSE, real32_T SD, real32_T
  dSZC)
{
  real32_T dec;

  /*  Active voice decision using multi-boundary decision regions in the space */
  /*  of the 4 difference measures */
  dec = 0.0F;
  if (SD > 0.00175F * dSZC + 0.00085F) {
    dec = 1.0F;
  } else if (SD > -0.00454545487F * dSZC + 0.00115909101F) {
    dec = 1.0F;
  } else if (dSE < -25.0F * dSZC + -5.0F) {
    dec = 1.0F;
  } else if (dSE < 20.0F * dSZC + -6.0F) {
    dec = 1.0F;
  } else if (dSE < -4.7F) {
    dec = 1.0F;
  } else if (dSE < 8800.0F * SD + -12.2F) {
    dec = 1.0F;
  } else if (SD > 0.0009F) {
    dec = 1.0F;
  } else if (dSLE < 25.0F * dSZC + -7.0F) {
    dec = 1.0F;
  } else if (dSLE < -29.09091F * dSZC + -4.8182F) {
    dec = 1.0F;
  } else if (dSLE < -5.3F) {
    dec = 1.0F;
  } else if (dSLE < 14000.0F * SD + -15.5F) {
    dec = 1.0F;
  } else if (dSLE > 0.928571F * dSE + 1.14285F) {
    dec = 1.0F;
  } else if (dSLE < -1.5F * dSE + -9.0F) {
    dec = 1.0F;
  } else {
    if (dSLE < 0.714285F * dSE + -2.14285707F) {
      dec = 1.0F;
    }
  }

  return dec;
}

void AC_not_empty_init(void)
{
}

void HPF_not_empty_init(void)
{
  HPF_not_empty = false;
}

void LEV1_not_empty_init(void)
{
}

void LEV2_not_empty_init(void)
{
}

void LPC2LSF_not_empty_init(void)
{
}

void VAD_var_param_not_empty_init(void)
{
}

void ZCD_not_empty_init(void)
{
}

real32_T vadG729(const emlrtStack *sp, const real32_T speech[80])
{
  real32_T fv0[80];
  int32_T ixstart;
  real32_T speech_hp[80];
  real32_T speech_buf[240];
  real32_T fv1[240];
  real32_T r[13];
  static const real32_T fv2[240] = { 0.0799999908F, 0.0800570324F, 0.0802281275F,
    0.0805132166F, 0.0809122697F, 0.0814251378F, 0.0820517316F, 0.0827918723F,
    0.0836454108F, 0.0846121088F, 0.0856917277F, 0.086884F, 0.0881886557F,
    0.0896053091F, 0.0911336616F, 0.0927733555F, 0.0945238844F, 0.0963849202F,
    0.0983559564F, 0.100436516F, 0.102626063F, 0.10492406F, 0.107329972F,
    0.109843142F, 0.112463005F, 0.115188874F, 0.118020095F, 0.120955922F,
    0.123995699F, 0.12713863F, 0.130383924F, 0.133730814F, 0.137178436F,
    0.140725955F, 0.144372448F, 0.14811708F, 0.151958868F, 0.155896887F,
    0.159930184F, 0.164057687F, 0.168278441F, 0.172591344F, 0.176995352F,
    0.181489423F, 0.186072335F, 0.190743074F, 0.195500359F, 0.200343147F,
    0.205270067F, 0.210280046F, 0.215371802F, 0.220544F, 0.225795463F,
    0.231124833F, 0.236530766F, 0.242011979F, 0.247567073F, 0.25319469F,
    0.2588934F, 0.264661878F, 0.270498574F, 0.276402116F, 0.282371044F,
    0.288403809F, 0.294499069F, 0.300655067F, 0.30687049F, 0.31314376F,
    0.319473237F, 0.325857371F, 0.332294643F, 0.338783443F, 0.345322102F,
    0.351909041F, 0.358542621F, 0.365221173F, 0.371943146F, 0.378706723F,
    0.385510325F, 0.392352223F, 0.399230719F, 0.406144172F, 0.413090795F,
    0.42006886F, 0.427076608F, 0.434112489F, 0.441174626F, 0.448261201F,
    0.455370456F, 0.46250084F, 0.469650418F, 0.47681734F, 0.483999968F,
    0.491196573F, 0.498405248F, 0.505624175F, 0.512851596F, 0.520085871F,
    0.527325F, 0.534567297F, 0.54181093F, 0.549054146F, 0.556295037F, 0.563532F,
    0.570763052F, 0.577986479F, 0.585200489F, 0.592403352F, 0.599593103F,
    0.606768191F, 0.613926709F, 0.621066868F, 0.628186882F, 0.635285079F,
    0.642359614F, 0.649408817F, 0.65643084F, 0.663424075F, 0.670386612F,
    0.677316785F, 0.684213F, 0.691073477F, 0.697896361F, 0.704680145F,
    0.711423159F, 0.718123674F, 0.724779904F, 0.731390357F, 0.737953424F,
    0.744467258F, 0.750930488F, 0.757341444F, 0.763698399F, 0.770000041F,
    0.776244521F, 0.78243047F, 0.788556278F, 0.794620454F, 0.80062145F,
    0.806557894F, 0.812428176F, 0.818231046F, 0.823964775F, 0.82962811F,
    0.835219622F, 0.840738F, 0.846181691F, 0.851549506F, 0.856840074F,
    0.862052143F, 0.867184222F, 0.872235298F, 0.877203882F, 0.88208884F,
    0.88688904F, 0.891603231F, 0.896230161F, 0.900768816F, 0.905218F,
    0.909576654F, 0.913843513F, 0.918017805F, 0.922098339F, 0.926084042F,
    0.929974139F, 0.933767438F, 0.937463105F, 0.941060245F, 0.944557846F,
    0.94795531F, 0.951251447F, 0.95444566F, 0.957537174F, 0.960525036F,
    0.963408649F, 0.966187239F, 0.968860209F, 0.971426845F, 0.97388643F,
    0.976238489F, 0.978482306F, 0.980617464F, 0.982643306F, 0.984559357F,
    0.986365199F, 0.988060415F, 0.989644468F, 0.991117F, 0.992477715F,
    0.993726194F, 0.994862199F, 0.995885372F, 0.996795535F, 0.99759239F,
    0.998275816F, 0.998845518F, 0.999301493F, 0.999643564F, 0.999871671F,
    0.999985754F, 1.0F, 0.999219298F, 0.996878445F, 0.992981076F, 0.987533331F,
    0.980543613F, 0.972022891F, 0.961984515F, 0.950444102F, 0.937419653F,
    0.922931552F, 0.907002449F, 0.88965708F, 0.870922685F, 0.850828409F,
    0.829405665F, 0.806687951F, 0.782710671F, 0.757511258F, 0.73112911F,
    0.703605354F, 0.674983F, 0.645306766F, 0.614622951F, 0.5829795F,
    0.550425708F, 0.517012596F, 0.482792258F, 0.447818F, 0.412144542F,
    0.375827551F, 0.338923752F, 0.301490873F, 0.263587236F, 0.225271955F,
    0.186604932F, 0.147646546F, 0.108457617F, 0.069099471F, 0.0296334308F };

  static const real32_T fv3[13] = { 1.0001F, 0.998890281F, 0.995568514F,
    0.990056813F, 0.982391596F, 0.972623467F, 0.960816443F, 0.947047353F,
    0.931404948F, 0.913988948F, 0.894909143F, 0.874284F, 0.852239609F };

  real32_T a[11];
  real32_T LSF[10];
  real32_T rc[2];
  real32_T mtmp;
  real32_T Ef;
  real32_T b_r[12];
  static const real32_T fv4[12] = { 0.21398823F, 0.14767693F, 0.07018812F,
    0.00980856456F, -0.020159347F, -0.0238827F, -0.0148007618F, -0.00503292168F,
    0.000121413665F, 0.0011935425F, 0.000659087207F, 0.000150157823F };

  real32_T El;
  real32_T b_LSF[10];
  real32_T fv5[10];
  real32_T SD;
  uint32_T A;
  real32_T ZC;
  real32_T Min;
  real32_T fv6[128];
  real32_T hoistedGlobal_Min_buffer[128];
  real32_T marker;
  real32_T NE;
  int32_T v_flag;
  int32_T ix;
  boolean_T exitg1;
  real32_T COEF;
  real32_T COEFZC;
  real32_T COEFSD;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;

  /*  VADG729 Implement the Voice Activity Detection Algorithm. */
  /*  Note that although G.729 VAD operates on pre-processed speech data, this */
  /*  function is a standalone version, i.e. the pre-processing (highpass */
  /*  filtering and linear predictive analysis) is also included. */
  /*  */
  /*  This function is in support of the 'G.729 Voice Activity Detection' */
  /*  example and may change in a future release */
  /*  Copyright 2015 The MathWorks, Inc. */
  /* % Algorithm Components Initialization */
  if (!HPF_not_empty) {
    /*  Create a IIR digital filter used for pre-processing */
    st.site = &emlrtRSI;
    BiquadFilter_BiquadFilter(&HPF);
    HPF_not_empty = true;

    /*  Create an autocorrelator and set its properties to compute the lags  */
    /*  in the range [0:NP]. */
    st.site = &b_emlrtRSI;
    Autocorrelator_Autocorrelator(&AC);

    /*  Create a Levinson solver which compute the reflection coefficients  */
    /*  from auto-correlation function using the Levinson-Durbin recursion.  */
    /*  The first object is configured to output polynomial coefficients and  */
    /*  the second object is configured to output reflection coefficients. */
    st.site = &c_emlrtRSI;
    LevinsonSolver_LevinsonSolver(&LEV1);
    st.site = &d_emlrtRSI;
    b_LevinsonSolver_LevinsonSolver(&LEV2);

    /*  Create a converter from linear prediction coefficients (LPC) to line  */
    /*  spectral frequencies (LSF) */
    st.site = &e_emlrtRSI;
    LPCToLSF_LPCToLSF(&st, &LPC2LSF);

    /*  Create a zero crossing detector */
    st.site = &f_emlrtRSI;
    c_ZeroCrossingDetector_ZeroCros(&ZCD);

    /*  initialize variable parameters */
    memset(&VAD_var_param.window_buffer[0], 0, 160U * sizeof(real32_T));
    VAD_var_param.frm_count = 0.0F;
    for (ixstart = 0; ixstart < 10; ixstart++) {
      VAD_var_param.MeanLSF[ixstart] = 0.0F;
    }

    VAD_var_param.MeanSE = 0.0F;
    VAD_var_param.MeanSLE = 0.0F;
    VAD_var_param.MeanE = 0.0F;
    VAD_var_param.MeanSZC = 0.0F;
    VAD_var_param.count_sil = 0.0F;
    VAD_var_param.count_update = 0.0F;
    VAD_var_param.count_ext = 0.0F;
    VAD_var_param.less_count = 0.0F;
    VAD_var_param.flag = 1.0F;
    for (ixstart = 0; ixstart < 2; ixstart++) {
      VAD_var_param.prev_markers[ixstart] = 1.0F;
    }

    VAD_var_param.prev_energy = 0.0F;
    VAD_var_param.Prev_Min = ((real32_T)rtInf);
    VAD_var_param.Next_Min = ((real32_T)rtInf);
    for (ixstart = 0; ixstart < 128; ixstart++) {
      VAD_var_param.Min_buffer[ixstart] = ((real32_T)rtInf);
    }
  }

  /* % Constants Initialization */
  VAD_var_param.frm_count++;

  /* % Pre-processing */
  /*  Filter the speech frame: this high-pass filter serves as a precaution  */
  /*  against undesired low-frequency components. */
  for (ixstart = 0; ixstart < 80; ixstart++) {
    fv0[ixstart] = 32768.0F * speech[ixstart];
  }

  st.site = &g_emlrtRSI;
  SystemCore_step(&st, &HPF, fv0, speech_hp);

  /*  Store filtered data to the pre-processed speech buffer */
  memcpy(&speech_buf[0], &VAD_var_param.window_buffer[0], 160U * sizeof(real32_T));
  memcpy(&speech_buf[160], &speech_hp[0], 80U * sizeof(real32_T));

  /*  LPC analysis */
  /*  Windowing of signal */
  /*  Autocorrelation */
  for (ixstart = 0; ixstart < 240; ixstart++) {
    fv1[ixstart] = fv2[ixstart] * speech_buf[ixstart];
  }

  st.site = &h_emlrtRSI;
  b_SystemCore_step(&st, &AC, fv1, r);
  for (ixstart = 0; ixstart < 13; ixstart++) {
    r[ixstart] *= fv3[ixstart];
  }

  /*  LSF */
  st.site = &i_emlrtRSI;
  c_SystemCore_step(&st, &LEV1, *(real32_T (*)[11])&r[0], a);
  st.site = &j_emlrtRSI;
  d_SystemCore_step(&st, &LPC2LSF, a, LSF);
  for (ixstart = 0; ixstart < 10; ixstart++) {
    LSF[ixstart] /= 6.28318548F;
  }

  /*  Reflection coefficients */
  st.site = &k_emlrtRSI;
  e_SystemCore_step(&st, &LEV2, *(real32_T (*)[3])&r[0], rc);

  /* % VAD starts here */
  /* % Parameters extraction */
  /*  Full-band energy */
  mtmp = r[0] / 240.0F;
  st.site = &l_emlrtRSI;
  if (mtmp < 0.0F) {
    b_st.site = &ab_emlrtRSI;
    error(&b_st);
  }

  Ef = 10.0F * muSingleScalarLog10(mtmp);

  /*  Low-band energy */
  for (ixstart = 0; ixstart < 12; ixstart++) {
    b_r[ixstart] = r[ixstart + 1] * fv4[ixstart];
  }

  mtmp = (r[0] * 0.24017939F + 2.0F * sum(b_r)) / 240.0F;
  st.site = &m_emlrtRSI;
  if (mtmp < 0.0F) {
    b_st.site = &ab_emlrtRSI;
    error(&b_st);
  }

  El = 10.0F * muSingleScalarLog10(mtmp);

  /*  Spectral Distorsion */
  for (ixstart = 0; ixstart < 10; ixstart++) {
    b_LSF[ixstart] = LSF[ixstart] - VAD_var_param.MeanLSF[ixstart];
  }

  st.site = &n_emlrtRSI;
  power(b_LSF, fv5);
  SD = b_sum(fv5);

  /*  Zero-crossing rate */
  st.site = &o_emlrtRSI;
  A = f_SystemCore_step(&st, &ZCD, *(real32_T (*)[81])&speech_buf[120]);
  ZC = (real32_T)A / 80.0F;

  /*  Long-term minimum energy */
  VAD_var_param.Next_Min = muSingleScalarMin(Ef, VAD_var_param.Next_Min);
  Min = muSingleScalarMin(VAD_var_param.Prev_Min, VAD_var_param.Next_Min);
  if (b_mod(VAD_var_param.frm_count, 8.0F) == 0.0F) {
    memcpy(&fv6[0], &VAD_var_param.Min_buffer[1], 127U * sizeof(real32_T));
    fv6[127] = VAD_var_param.Next_Min;
    for (ixstart = 0; ixstart < 128; ixstart++) {
      VAD_var_param.Min_buffer[ixstart] = fv6[ixstart];
      hoistedGlobal_Min_buffer[ixstart] = VAD_var_param.Min_buffer[ixstart];
    }

    st.site = &p_emlrtRSI;
    ixstart = 1;
    mtmp = hoistedGlobal_Min_buffer[0];
    if (muSingleScalarIsNaN(hoistedGlobal_Min_buffer[0])) {
      ix = 2;
      exitg1 = false;
      while ((!exitg1) && (ix < 129)) {
        ixstart = ix;
        if (!muSingleScalarIsNaN(hoistedGlobal_Min_buffer[ix - 1])) {
          mtmp = hoistedGlobal_Min_buffer[ix - 1];
          exitg1 = true;
        } else {
          ix++;
        }
      }
    }

    if (ixstart < 128) {
      while (ixstart + 1 < 129) {
        if (hoistedGlobal_Min_buffer[ixstart] < mtmp) {
          mtmp = hoistedGlobal_Min_buffer[ixstart];
        }

        ixstart++;
      }
    }

    VAD_var_param.Prev_Min = mtmp;
    VAD_var_param.Next_Min = ((real32_T)rtInf);
  }

  if (VAD_var_param.frm_count < 32.0F) {
    /*     %% Initialization of running averages if frame number is less than 32 */
    if (Ef < 21.0F) {
      VAD_var_param.less_count++;
      marker = 0.0F;
    } else {
      /*  include only the frames that have an energy Ef greater than 21 */
      marker = 1.0F;
      NE = (VAD_var_param.frm_count - 1.0F) - VAD_var_param.less_count;
      VAD_var_param.MeanE = (VAD_var_param.MeanE * NE + Ef) / (NE + 1.0F);
      VAD_var_param.MeanSZC = (VAD_var_param.MeanSZC * NE + ZC) / (NE + 1.0F);
      for (ixstart = 0; ixstart < 10; ixstart++) {
        VAD_var_param.MeanLSF[ixstart] = (VAD_var_param.MeanLSF[ixstart] * NE +
          LSF[ixstart]) / (NE + 1.0F);
      }
    }
  } else {
    /*     %% Start calculating the chararcteristic energies of background noise */
    if (VAD_var_param.frm_count == 32.0F) {
      VAD_var_param.MeanSE = VAD_var_param.MeanE - 10.0F;
      VAD_var_param.MeanSLE = VAD_var_param.MeanE - 12.0F;
    }

    /*  Difference measures between current frame parameters and running */
    /*  averages of background noise characteristics */
    /*     %% Initial VAD decision */
    if (Ef < 21.0F) {
      marker = 0.0F;
    } else {
      marker = vad_decision(VAD_var_param.MeanSLE - El, VAD_var_param.MeanSE -
                            Ef, SD, VAD_var_param.MeanSZC - ZC);
    }

    v_flag = 0;

    /*     %% Voice activity decision smoothing */
    /*  from energy considerations and neighbouring past frame decisions */
    /*  Step 1 */
    if ((VAD_var_param.prev_markers[0] == 1.0F) && (marker == 0.0F) && (Ef >
         VAD_var_param.MeanSE + 2.0F) && (Ef > 21.0F)) {
      marker = 1.0F;
      v_flag = 1;
    }

    /*  Step 2 */
    if (VAD_var_param.flag == 1.0F) {
      if ((VAD_var_param.prev_markers[1] == 1.0F) &&
          (VAD_var_param.prev_markers[0] == 1.0F) && (marker == 0.0F) &&
          (muSingleScalarAbs(Ef - VAD_var_param.prev_energy) <= 3.0F)) {
        VAD_var_param.count_ext++;
        marker = 1.0F;
        v_flag = 1;
        if (VAD_var_param.count_ext <= 4.0F) {
          VAD_var_param.flag = 1.0F;
        } else {
          VAD_var_param.count_ext = 0.0F;
          VAD_var_param.flag = 0.0F;
        }
      }
    } else {
      VAD_var_param.flag = 1.0F;
    }

    if (marker == 0.0F) {
      VAD_var_param.count_sil++;
    }

    /*  Step 3     */
    if ((marker == 1.0F) && (VAD_var_param.count_sil > 10.0F) && (Ef -
         VAD_var_param.prev_energy <= 3.0F)) {
      marker = 0.0F;
      VAD_var_param.count_sil = 0.0F;
    }

    if (marker == 1.0F) {
      VAD_var_param.count_sil = 0.0F;
    }

    /*  Step 4 */
    if ((Ef < VAD_var_param.MeanSE + 3.0F) && (VAD_var_param.frm_count > 128.0F)
        && (v_flag == 0) && (rc[1] < 0.6)) {
      marker = 0.0F;
    }

    /*     %% Update running averages only in the presence of background noise */
    if ((Ef < VAD_var_param.MeanSE + 3.0F) && (rc[1] < 0.75F) && (SD <
         0.002532959)) {
      VAD_var_param.count_update++;

      /*  Modify update speed coefficients */
      if (VAD_var_param.count_update < 20.0F) {
        COEF = 0.75F;
        COEFZC = 0.8F;
        COEFSD = 0.6F;
      } else if (VAD_var_param.count_update < 30.0F) {
        COEF = 0.95F;
        COEFZC = 0.92F;
        COEFSD = 0.65F;
      } else if (VAD_var_param.count_update < 40.0F) {
        COEF = 0.97F;
        COEFZC = 0.94F;
        COEFSD = 0.7F;
      } else if (VAD_var_param.count_update < 50.0F) {
        COEF = 0.99F;
        COEFZC = 0.96F;
        COEFSD = 0.75F;
      } else if (VAD_var_param.count_update < 60.0F) {
        COEF = 0.995F;
        COEFZC = 0.99F;
        COEFSD = 0.75F;
      } else {
        COEF = 0.995F;
        COEFZC = 0.998F;
        COEFSD = 0.75F;
      }

      /*  Update mean of parameters LSF, SE, SLE, SZC */
      VAD_var_param.MeanSE = COEF * VAD_var_param.MeanSE + (1.0F - COEF) * Ef;
      VAD_var_param.MeanSLE = COEF * VAD_var_param.MeanSLE + (1.0F - COEF) * El;
      VAD_var_param.MeanSZC = COEFZC * VAD_var_param.MeanSZC + (1.0F - COEFZC) *
        ZC;
      for (ixstart = 0; ixstart < 10; ixstart++) {
        VAD_var_param.MeanLSF[ixstart] = COEFSD * VAD_var_param.MeanLSF[ixstart]
          + (1.0F - COEFSD) * LSF[ixstart];
      }
    }

    if (((VAD_var_param.frm_count > 128.0F) && (VAD_var_param.MeanSE < Min) &&
         (SD < 0.002532959)) || (VAD_var_param.MeanSE > Min + 10.0F)) {
      VAD_var_param.MeanSE = Min;
      VAD_var_param.count_update = 0.0F;
    }
  }

  /* % Update parameters for next frame */
  VAD_var_param.prev_energy = Ef;
  mtmp = VAD_var_param.prev_markers[0];
  VAD_var_param.prev_markers[0] = marker;
  VAD_var_param.prev_markers[1] = mtmp;
  memcpy(&VAD_var_param.window_buffer[0], &speech_buf[80], 160U * sizeof
         (real32_T));

  /* % Return final decision */
  return marker;
}

/* End of code generation (vadG729.c) */
