%Script to test the NoisePulseTrain class and ensure correct operation

clear;
close all;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Noise pulse characteristics
%set it to generate 4 pulses per second
period_samp = Fs/4; 
%/8 here sounds best however this is ulitmately determined by the string
%characteristics
T60_samp = period_samp/8; 

%Constant Rate Test
f_c = Fs/period_samp;

%buffers to be filled during processing loop
y1 = zeros(1, numSamples);
y2 = zeros(1, numSamples);

%Processing objects
noisePulseTrain = NoisePulseTrain(period_samp, T60_samp);

%Processing loop
for n = 1:numSamples
    y1(n) = noisePulseTrain.tick(f_c);
end

figure;
plot(y1);
title("Noise Pulse Train Test - Constant Rate");

%Rate changing test
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%Processing loop
for n = 1:numSamples
    y2(n) = noisePulseTrain.tick(f_c(n));
end

figure;
plot(y2);
title("Noise Pulse Train Test - Rate Changing");