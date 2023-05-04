clear;
%close all;
%addpath("..\src");

Fs = 48000;
f_c = 5000;
r = .99;
resonator = Resonator(f_c, r);
figure;
resonator.plotFrequencyResponse();
% title("Resonator Frequency Response - Constructor Test");
title(sprintf("f_c = %i Hz, r = %.2f", f_c, r));

figure;
resonator.update_f_c(250);
resonator.plotFrequencyResponse();
title("Resonator Frequency Response - update_f_c() test", 'interpreter', 'none');
grid on;
grid minor;