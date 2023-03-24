clear all;
%close all

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Parabolic sweep for Fc
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

ticks = f_cToTicks(f_c, Fs);

f_c_quantized = Fs ./ ticks;

figure;
subplot(3, 1, 1);
plot(f_c);
title("f_c");
subplot(3, 1, 2);
plot(f_c_quantized);
title("f_c quantized");
subplot(3, 1, 3);
plot(ticks(100:end-100));
title("ticks");

figure;
harmonicPaths = (1:20)'*f_c_quantized;
plot(harmonicPaths');