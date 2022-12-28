%Test the unwound CSG module using 
%   1. No slide motion 
%   2. A constant non-zero slide velocity
%   3. A time-varying slide velocity

close all;
clear;

dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
n_w = stringParams.n_w;
duration_sec = 2;
numSamples = round(Fs*duration_sec);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs;
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5;

%*********No Slide Velocity Test********
%Keep the f_c constant for now to simplify the tests
f_c = zeros(1, numSamples);

%generate the control signal based on the derivations in your notebook
L = zeros(1, numSamples);
L(1) = 1;
for n = 2:numSamples
    L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
end

%Set the initial one to be slightly greater than 1 in order to produce a
%constant velocity
L_n_1 = L(1) + L(1)-L(2);

%create/initialize the processing objects
csg_unwound = CSG_unwound(stringParams, L_n_1);
y1 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_unwound.consumeControlSignal(L(n));
    y1(n) = csg_unwound.tick();
end

figure;
plot(y1);
title("Unwound CSG Test Output - No Slide Velocity");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");
title('Unwound CSG Test Output - No Slide Velocity Spectrogram')

%*********Constant Slide Velocity Test********
%Keep the f_c constant for now to simplify the tests
f_c = 250*ones(1, numSamples);

%generate the control signal based on the derivations in your notebook
L = zeros(1, numSamples);
L(1) = 1;
for n = 2:numSamples
    L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
end

%Set the initial one to be slightly greater than 1 in order to produce a
%constant velocity
L_n_1 = L(1) + L(1)-L(2);

%create/initialize the processing objects
csg_unwound = CSG_unwound(stringParams, L_n_1);
y2 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_unwound.consumeControlSignal(L(n));
    y2(n) = csg_unwound.tick();
end

figure;
plot(y2);
title("Unwound CSG Test Output - Constant Slide Velocity");

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");
title('Unwound CSG Test Output - Constant Slide Velocity Spectrogram')

%*********Time Varying Slide Velocity Test********
%Generate the parabolic trajectory from before
%TODO: Put this into a function as many tests use it?
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

%Set the initial one to be slightly greater than 1 in order to produce a
%constant velocity
L_n_1 = L(1) + L(1)-L(2);

%create/initialize the processing objects
csg_unwound = CSG_unwound(stringParams, L_n_1);
y3 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    csg_unwound.consumeControlSignal(L(n));
    y3(n) = csg_unwound.tick();
end

figure;
plot(y3);
title("Unwound CSG Test Output - Time-Varying Slide Velocity");

figure;
spectrogram(y3, window, overlap, N, Fs, "yaxis");
title('Unwound CSG Test Output - Time-Varying Slide Velocity Spectrogram');