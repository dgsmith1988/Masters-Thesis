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

%Plot things...
t =( 0:numSamples-1)/Fs;
figure;
subplot(2, 1, 1);
hold on;
plot(t, f_c, "DisplayName", "Ideal");
plot(t, f_c_quantized, "DisplayName", "Quantized");
hold off;
title("f_c sweep");
ylim([0 1050]);
grid on;
grid minor;
ylabel("Frequency (Hz)");
xlabel("Time (sec)");
legend("Location", "south");

subplot(2, 1, 2);
harmonicPaths = (1:6)'*f_c_quantized;
plot(t, harmonicPaths');
ylim([0 6100]);
title("Harmonics");
grid on;
grid minor;
ylabel("Frequency (Hz)");
xlabel("Time (sec)");