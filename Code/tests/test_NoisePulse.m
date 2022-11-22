%Test the class based on the PD patch

clear;
close all;
%addpath("..\src");

%System parameters
Fs = SystemParams.audioRate;
T = 1/Fs;
N = 4096;

pulseLengths = [SystemParams.E_string_params.pulseLength, SystemParams.A_string_params.pulseLength SystemParams.D_string_params.pulseLength];
decayRates = [SystemParams.E_string_params.decayRate, SystemParams.A_string_params.decayRate, SystemParams.D_string_params.decayRate];
plotTitles = ["E-string", "A-string", "D-string"];
figure;
for i = 1:length(pulseLengths)
    pulseLength_ms = pulseLengths(i);
    pulseLength_samples = (pulseLength_ms*10^-3)*Fs;
    %num_samples = pulseLength_samples + 500;
    num_samples = pulseLength_samples;
    
    %Processing objects/variables
    noisePulse2 = NoisePulse2(pulseLength_ms, decayRates(i));
    y = zeros(1, num_samples);

    for n = 1:num_samples
        y(n) = noisePulse2.tick();
    end
    subplot(1, 3, i);
    plot(y);
    xlim([0 10000]);
    ylim([0 1]);
    title(sprintf("%s pulse, Length = %i (samp)", plotTitles(i), pulseLength_samples));
    disp("Hit enter to hear several pulses in a row...")
    pause();
    sound(.5*[y, y, y, y, y], Fs)
    disp("Hit enter to process the next string...")
    pause();
end



% sound(.5*y, Fs)

% Y = fft(y, N);
% plot(mag2db(abs(Y)));