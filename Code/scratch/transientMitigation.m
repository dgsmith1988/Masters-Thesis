%Experiments using different control and audio rates to try and mitigate
%the transients from the time-varying filters

% clear;
close all;
dbstop if error

%System processing parameters
Fs_audio = SystemParams.audioRate;
Fs_control = SystemParams.audioRate;
R = Fs_audio/Fs_control;
durationSec = 3;
numSamples_control = durationSec * Fs_control;
numSamples_audio = durationSec * Fs_audio;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.e_string_params;
n_w = stringParams.n_w; %extract the parameter before we overwrite it
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.E_string_modes.chrome;
waveshaperFunctionHandle = @tanh;

%Generate the appropriate control signal
startingStringLength = fretNumberToRelativeLength(0);
endingStringLength = fretNumberToRelativeLength(1);
frequencyRatio = startingStringLength/endingStringLength;
sampleRatio = frequencyRatio^(1/numSamples_control);

L = ones(1, numSamples_control);
L(1) = startingStringLength;
for n = 2:numSamples_control
    L(n) = L(n-1)/sampleRatio;
end

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y2 = zeros(1, numSamples_audio);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
n = 1;
for k = 1:numSamples_control
    if(mod(k, 100) == 0)
        fprintf("k = %i/%i\n", k, numSamples_control);
    end
    stringSynth.consumeControlSignal(L(k))
    for l = 1:R
        y2(n) = stringSynth.tick();
        n = n + 1;
    end
end

% figure;
% subplot(2, 1, 1)
% plot(y2);
% subplot(2, 1, 2);
% plot(L);
% 
% %Spectrogram analysis parameters
% windowLength = 12*10^-3*Fs; %12 ms window
% % window = hamming(windowLength);
% window = rectwin(windowLength);
% overlap = .75*windowLength;
% N = 4096;
% y_upperLim = 5; %corresponds to 5kHz on the frequency axis
% figure;
% spectrogram(y2, window, overlap, N, Fs, "yaxis");
% % ylim([0 y_upperLim]);
% %Take a look at how the delay line lengths change to see if some sort of a
% %quantization is occuring here to create these non-smooth effects
% figure;
% % subplot(2, 1, 1);
% % stem(0:5, stringSynth.feedbackLoop.fractionalDelayLine.b);
% frameLength = 200;
% % subplot(2, 1, 2);
% stem(0:numSamples-1, y2);
% grid on; grid minor;
% % for i = 1:numSamples/frameLength
% %     xlim([(i-1)*frameLength+1, i*frameLength]);
% %     disp("Hit enter for next frame...");
% %     pause;
% % end
% 
% pitch_f0 = calculatePitchF0(L, stringParams.f0);
% DWGLength = calculateTotalDWGLength(pitch_f0, Fs);
% loopFilterDelay = stringSynth.feedbackLoop.loopFilter.phaseDelay;
% fractionalDelayInteger = stringSynth.feedbackLoop.fractionalDelayLine.integerDelay;
% [p_int, p_frac_delta] = calculateDelayLineLengths(DWGLength, loopFilterDelay, fractionalDelayInteger);
% nRange = 0:numSamples-1;
% figure;
% yyaxis left
% plot(nRange, p_int);
% ylabel("Integer Delay Component");
% yyaxis right;
% plot(nRange, p_frac_delta);
% ylabel("Fractional Delay");
% xlim([52383 90000])