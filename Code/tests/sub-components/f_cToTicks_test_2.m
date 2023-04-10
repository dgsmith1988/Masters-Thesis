clear all;
%close all

%System parameters
Fs = SystemParams.audioRate;
numSamples = 3*(Fs/2);

%Linear sweep of f_c over min to max
increment = Fs/2 / (numSamples+3);
f_c = 1:increment:Fs/2;

ticks = f_cToTicks(f_c, Fs);

f_c_quantized = Fs ./ ticks;

figure;
hold on;
plot(f_c/1000, f_c/1000, "DisplayName", "Ideal");
plot(f_c/1000, f_c_quantized/1000, "DisplayName", "Quantized");
hold off;
title("Quantization of f_c[n]");
legend("Location", "southeast");
xlabel("Input Frequency (kHz)");
ylabel("Output Frequency (kHz)");

% title("f_c quantized");
% subplot(3, 1, 3);
% plot(ticks(100:end-100));
% title("ticks");
% 
% figure;
% harmonicPaths = (1:20)'*f_c_quantized;
% plot(harmonicPaths');