%Script to test the ExponentialDecay object and makes sure the T60
%parameter works correctly

clear;
close all;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = .5;
numSamples = round(duration_sec*Fs);

%ImpluseTrain characteristics
%set the system to output 1 impulse over the course of this first test
period_samp = numSamples; 
f_c = Fs/period_samp;

%Number of samples it takes for the signal to decay to the T60 value
T60 = [duration_sec/2, duration_sec/4, duration_sec/8];
T60_samples = [duration_sec/2, duration_sec/4, duration_sec/8]*Fs;

%buffers to be filled during processing loop
y1 = zeros(length(T60_samples), numSamples);

figure;
for k = 1:length(T60_samples)
    subplot(length(T60_samples), 1, k);
    
    %Processing objects
    exponentialDecay = ExponentialDecay(period_samp, T60(k));
    
    %Processing loop
    for n = 1:numSamples
        exponentialDecay.consumeControlSignal(f_c);
        y1(k, n) = exponentialDecay.tick();
    end
    
    stem(0:numSamples-1, y1(k, :));
%     title(sprintf("Exponential Decay T60 Test - .001 reached after %i samples", T60_samples(k)));
    title(sprintf(".001 reached after %i samples", T60_samples(k)));
    ylim([0 .002]);
    xlim([T60_samples(k)-10, T60_samples(k)+10]);
    grid on;
    grid minor;
    hold on;
    %add one as we need to have the specified number of samples pass before
    %the value reaches .001 (think about how the sampling of the continuous
    %expontential decay works)
    stem(T60_samples(k), y1(k, T60_samples(k)+1));
    hold off;
end