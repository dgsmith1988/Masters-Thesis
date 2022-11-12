clear;
close all;
%addpath("..\src");

N = 8192;
Fs = 48000;
f_c = 5000;
r = .99;
resonator = ResonatorFilter(f_c, r);
% figure;
% freqz(resonator.b, resonator.a, N, Fs);
[H, f] = freqz(resonator.b, resonator.a, N, SystemParams.audioRate);
figure;
plot(f, abs(H));
xlabel("Frquency (Hz)");
ylabel("Linear Magnitude Gain");
grid on;