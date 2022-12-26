%Scratch code to experiment with different approaches to upsampling the
%control signal L[n]

clear;
% close all;

%Overall System Parameters
Fs_audio = SystemParams.audioRate;
Fs_control = SystemParams.controlRate;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
n_w = stringParams.n_w;
duration_sec = 2;
numSamples = round(Fs_control*duration_sec);

%Determine the upsampling ratio
R = Fs_audio / Fs_control;

%%**Constant velocity test**
%Keep the f_c constant for now to simplify the tests
f_c1 = 250*ones(1, numSamples);

%generate the control signal based on the derivations in your notebook
L1_control = zeros(1, numSamples);
L1_control(1) = 1;
for n = 2:numSamples
    L1_control(n) = L1_control(n-1) - f_c1(n)/(n_w*stringLength*Fs_control);
end

L1_audio = interp(L1_control, R);

figure;
subplot(2, 1, 1);
plot(L1_control);
title("L1 at control rate");
subplot(2, 1, 2);
plot(L1_audio);
title("L1 at audio rate");

figure;
subplot(2, 1, 1);
stem(L1_control(1:R));
title("L1 at control rate");
subplot(2, 1, 2);
stem(L1_audio(1:3*R));
title("L1 at audio rate");

%%**Time-varying velocity test**
%Generate the parabolic f_c/velocity trajectory
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c2 = 1000*(-a*(x -.3).^2 + 1);

%generate the control signal based on the derivations in your notebook
L2_control = zeros(1, numSamples);
L2_control(1) = 1;
for n = 2:numSamples
    L2_control(n) = L2_control(n-1) - f_c2(n)/(n_w*stringLength*Fs_control);
end

L2_audio = interp(L2_control, R);

figure;
subplot(2, 1, 1);
plot(L2_control);
title("L2 at control rate");
subplot(2, 1, 2);
plot(L2_audio);
title("L2 at audio rate");

figure;
subplot(2, 1, 1);
stem(L2_control(1:R));
title("L2 at control rate");
subplot(2, 1, 2);
stem(L2_audio(1:3*R));
title("L2 at audio rate");