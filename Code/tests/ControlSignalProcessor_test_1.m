%Test the ControlSignalProcessor with a time-varying slide velocity

close all;
clear;

%Generaly system parameters
n_w = SystemParams.E_string_params.n_w;
Fs = SystemParams.audioRate;
stringLength = SystemParams.stringLengthMeters;
duration_sec = .6;
numSamples = Fs*duration_sec;

%Equation generated by fitting a parabola to the spectrogram from the CMJ
%paper, see that as well as the Desmos calculations
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%generate the control signal based on the derivations in your notebook
L = zeros(1, numSamples);
L(1) = 1;
for n = 2:numSamples
    L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
end

%Processing objects
controlSignalProcessor = ControlSignalProcessor(n_w, L(1));

f_c_calc = zeros(1, numSamples);
%Processing loop
for n = 1:numSamples
    f_c_calc(n) = controlSignalProcessor.tick(L(n));
end
err = f_c_calc - f_c;

subplot(2, 1, 1);
plot(f_c, 'DisplayName', 'f_c');
hold on;
plot(f_c_calc, 'DisplayName', 'f_c calc');
plot(err, 'DisplayName', 'err');
hold off;
legend();
title('f_c comparison');

subplot(2, 1, 2);
plot(L, 'DisplayName', 'L[n]');
% legend();
title('L[n]');
