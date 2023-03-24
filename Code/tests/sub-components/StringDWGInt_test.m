%Test the StringDWGInt class to illustrate the bandwidth limitations aspect

close all;
clear all;
dbstop if error

%String DWG Parameters
stringParams = SystemParams.e_string_params;
noiseType = "Pink";
useNoiseFile = false;
upperFret = 24;
lowerFret = 0;

%System Processing Parameters
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%******************************Ascending Test******************************
%Generate the control signal
L = generateLCurve(lowerFret, upperFret, durationSec, Fs);

%Processing objects
stringDWGInt = StringDWGInt(stringParams, L(1), noiseType, useNoiseFile);
y1 = zeros(1, numSamples);

%Processing loop
stringDWGInt.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringDWGInt.consumeControlSignal(L(n));
    %zero is passed here as the is no input to the DWG
    y1(n) = stringDWGInt.tick(0);
end

figure;
plot(y1);
title("Integer DWG - Ascending Test");

figure;
spectrogram(y1, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Integer DWG - Ascending Test')

%******************************Descending Test*****************************
%Generate the control signal
L = generateLCurve(upperFret, lowerFret, durationSec, Fs);

%Processing objects
stringDWGInt = StringDWGInt(stringParams, L(1), noiseType, useNoiseFile);
y2 = zeros(1, numSamples);

%Processing loop
stringDWGInt.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 1000) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringDWGInt.consumeControlSignal(L(n));
    %zero is passed here as the is no input to the DWG
    y2(n) = stringDWGInt.tick(0);
end

figure;
plot(y2);
title("Integer DWG - Descending Test");

figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('Integer DWG - Descending Test')