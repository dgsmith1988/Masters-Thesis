clear;
close all;
%addpath("..\src");

Fs = 48000;
f_c = 5000;
r = .99;
resonator = ResonatorFilter(f_c, r);
figure;
resonator.plotFrequencyResponse();
title("Resonator Frequency Response - Constructor Test");

figure;
resonator.update_f_c(250);
resonator.plotFrequencyResponse();
title("Resonator Frequency Response - update_f_c() test", 'interpreter', 'none');
grid on;
grid minor;