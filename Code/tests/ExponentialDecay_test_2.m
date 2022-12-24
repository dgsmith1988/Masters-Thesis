%Script to test the ExponentialDecay class to make sure the overlaps occur
%correctly when the T60 is long enough compared to the firing rate of the
%ImpulseTrain that the generated IRs overlap

clear;
close all;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = .5;
numSamples = round(duration_sec*Fs);

%ImpluseTrain characteristics
%set the system to output 2 impulses over the course of this test
period_samp = numSamples/2;
f_c = Fs/period_samp;

%Set the T60 value to the be the same as the period so when the second
%pulse is fed into the IIR, the output of the system at that point should
%be 1 + .001 = 1.001
T60_samples = period_samp;
T60 = T60_samples/Fs;

%buffer to be filled during processing loop
y2 = zeros(length(T60_samples), numSamples);

%Processing objects
exponentialDecay = ExponentialDecay(period_samp, T60);

%Processing loop
for n = 1:numSamples
    y2(n) = exponentialDecay.tick(f_c);
end

stem(0:numSamples-1, y2);
title(sprintf("Exponential Decay Overlap Test - Signal should be 1.001 reached after %i samples", T60_samples));
ylim([.96, 1.005]);
xlim([T60_samples-10, T60_samples+10]);
grid on;
grid minor;
hold on;
stem(T60_samples, y2(T60_samples+1));
hold off;
