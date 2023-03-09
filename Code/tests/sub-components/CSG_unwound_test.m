%Test the unwound CSG module using 
%   1. No slide motion 
%   2. A constant non-zero slide velocity
%   3. A time-varying slide velocity

close all;
clear all;
dbstop if error;

%System parameters
Fs = SystemParams.audioRate;
stringParams = SystemParams.B_string_params;
duration_sec = 2;
numSamples = round(Fs*duration_sec);

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs;
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = Fs/2000;

%*********No Slide Speed Test********
slideSpeed = zeros(1, numSamples);

%create/initialize the processing objects
csg_unwound = CSG_unwound();
y1 = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_unwound.consumeControlSignal(slideSpeed(n));
    y1(n) = csg_unwound.tick();
end

figure;
plot(y1);
title("Unwound CSG Test Output - No Slide Velocity");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");
% title('Unwound CSG Test Output - No Slide Velocity');

%*********Constant Slide Speed Test********
slideSpeed = .5*ones(1, numSamples);

%create/initialize the processing objects
csg_unwound = CSG_unwound();
y2 = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_unwound.consumeControlSignal(slideSpeed(n));
    y2(n) = csg_unwound.tick();
end

figure;
plot(y2);
title("Unwound CSG Test Output - Constant Slide Velocity");

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");
% title('Unwound CSG Test Output - Constant Slide Velocity');

%*********Time Varying Slide Velocity Test********
%Generate the parabolic trajectory from before
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
slideSpeed = (-a*(x -.3).^2 + 1);

%create/initialize the processing objects
csg_unwound = CSG_unwound();
y3 = zeros(1, numSamples);

%Processing loop
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    csg_unwound.consumeControlSignal(slideSpeed(n));
    y3(n) = csg_unwound.tick();
end

figure;
plot(y3);
title("Unwound CSG Test Output - Time-Varying Slide Velocity");

figure;
spectrogram(y3, window, overlap, N, Fs, "yaxis");
% title('Unwound CSG Test Output - Time-Varying Slide Velocity');