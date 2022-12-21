%Resonator cut off frequency trajectory reverse engineering

close all;
clear;

alpha = 50000; %taken from the PD code
F_open = SystemParams.E_string_params.f0;
Fs = SystemParams.audioRate;
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
    L(n) = alpha*F_open*L(n-1) / (L(n-1)*f_c(n) + alpha*F_open);
end

% figure;
% plot(x, f_c);
% title('f_c');
% figure;
% plot(x, L);
% title('L')

%System parameters
stringParams = SystemParams.E_string_params;
stringModeFilterSpec = SystemParams.E_string_modes.brass;
pulseLength_ms = stringParams.pulseLength;
decayRate = stringParams.decayRate;
n_w = stringParams.n_w;
L_n_1 = 1;
contactSoundGenerator = ContactSoundGenerator(stringParams, stringModeFilterSpec, @tanh, L_n_1);
controlSignalProcessor = ControlSignalProcessor(n_w, F_open, L_n_1);

y = zeros(1, numSamples);
f_c_out = zeros(1, numSamples);
sv = zeros(1, numSamples);
tp = zeros(1, numSamples);
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
%     y(n) = contactSoundGenerator.tick(L(n));
    [sv(n), f_c_out(n), tp(n)] = controlSignalProcessor.tick(L(n));
end

figure;
plot(y);
title("CSG Test Output");

figure;
plot(x, f_c, 'DisplayName', 'f_c');
hold on;
plot(x, f_c_out, 'DisplayName', 'f_c out');
plot(x, f_c_out - f_c, 'DisplayName', 'err');
hold off;
title("f_c comparison");
legend();