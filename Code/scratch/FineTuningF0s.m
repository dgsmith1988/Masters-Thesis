%Search analysis parameters for f0 values which have a delay component of 0
%or .5 to create a constant phase delay

clear all;
Fs = SystemParams.audioRate;
N = 4096;
k = 0:N-1;
f0 = k*Fs/N;
DWGLength = calculateTotalDWGLength(f0, Fs);

f0_frac = f0(rem(DWGLength, 1) == .5)
f0_int = f0(mod(DWGLength, 1) == 0)
k_calc = f0_int*N/Fs