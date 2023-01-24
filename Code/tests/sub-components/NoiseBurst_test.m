%Script to test the NoiseBurst class and ensure correct operation

clear;
close all;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 3;
numSamples = round(duration_sec*Fs);

%Noise burst characteristics
%Set it to generate 4 pulses per second
period_samp = Fs/4;
%/8 here sounds best however this is ulitmately determined by the string
%characteristics
T60_samp = period_samp/8;
T60 = T60_samp/Fs;

%Constant Rate Test
f_c = Fs/period_samp;

%buffers to be filled during processing loop
y1 = zeros(1, numSamples);
y2 = zeros(1, numSamples);

%Processing objects
noiseBurst = NoiseBurst(period_samp, T60);

%Processing loop
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    noiseBurst.consumeControlSignal(f_c);
    y1(n) = noiseBurst.tick();
end

figure;
plot(y1);
title("Noise Burst Test - Constant Rate");

%Rate changing test
a = 1/.09;
increment = .6/numSamples;
x = 0:increment:.6-increment;
f_c = 1000*(-a*(x -.3).^2 + 1);

%Processing loop
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    noiseBurst.consumeControlSignal(f_c(n));
    y2(n) = noiseBurst.tick();
end

figure;
plot(y2);
title("Noise Burst Test - Rate Changing");