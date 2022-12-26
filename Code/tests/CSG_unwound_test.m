%Test the unwound CSG module using a constant slide velocity as well as one
%following the parabolic trajctory associated with stopping and starting

close all;
% clear;

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
y1 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y1(n) = csg_unwound.tick(L(n));
end

figure;
plot(y1);
title("Unwound CSG Test Output - Constant Slide Velocity");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
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
y2 = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y2(n) = csg_unwound.tick(L(n));
end

figure;
plot(y2);
title("Unwound CSG Test Output - Time-Varying Slide Velocity");

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");  
title('Unwound CSG Test Output - Time-Varying Slide Velocity Spectrogram');