@echo off
set MATLAB=C:\PROGRA~1\MATLAB\R2016a
set MATLAB_ARCH=win64
set MATLAB_BIN="C:\Program Files\MATLAB\R2016a\bin"
set ENTRYPOINT=mexFunction
set OUTDIR=.\
set LIB_NAME=vadG729_mex
set MEX_NAME=vadG729_mex
set MEX_EXT=.mexw64
call setEnv.bat
echo # Make settings for vadG729 > vadG729_mex.mki
echo COMPILER=%COMPILER%>> vadG729_mex.mki
echo COMPFLAGS=%COMPFLAGS%>> vadG729_mex.mki
echo OPTIMFLAGS=%OPTIMFLAGS%>> vadG729_mex.mki
echo DEBUGFLAGS=%DEBUGFLAGS%>> vadG729_mex.mki
echo LINKER=%LINKER%>> vadG729_mex.mki
echo LINKFLAGS=%LINKFLAGS%>> vadG729_mex.mki
echo LINKOPTIMFLAGS=%LINKOPTIMFLAGS%>> vadG729_mex.mki
echo LINKDEBUGFLAGS=%LINKDEBUGFLAGS%>> vadG729_mex.mki
echo MATLAB_ARCH=%MATLAB_ARCH%>> vadG729_mex.mki
echo BORLAND=%BORLAND%>> vadG729_mex.mki
echo OMPFLAGS= >> vadG729_mex.mki
echo OMPLINKFLAGS= >> vadG729_mex.mki
echo EMC_COMPILER=msvc140>> vadG729_mex.mki
echo EMC_CONFIG=optim>> vadG729_mex.mki
"C:\Program Files\MATLAB\R2016a\bin\win64\gmake" -B -f vadG729_mex.mk
