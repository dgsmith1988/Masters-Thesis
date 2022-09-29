clear;
close all;

N = 8192;
Fs = 48000;
f_c = 5000;
r = .99;
resonator = ResonatorFilter(f_c, r, Fs);
% figure;
% freqz(resonator.b, resonator.a, N, Fs);
[H, f] = freqz(resonator.b, resonator.a, N, Fs);
figure;
plot(f, H);
xlabel("Frquency (Hz)");
ylabel("Linear Magnitude Gain");
grid on;