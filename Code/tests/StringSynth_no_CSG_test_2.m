% clear;
% close all;
dbstop if error
writeAudioFlag = false;
testName = "StringSynth Test 2 - No CSG - No slide to slide transition";

%System processing parameters
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.e_string_params;
n_w = stringParams.n_w; %extract the parameter before we overwrite it
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.e_string_modes.chrome;
waveshaperFunctionHandle = @tanh;

%Generate the appropriate control signal
startingStringLength = fretNumberToRelativeLength(0);
endingStringLength = fretNumberToRelativeLength(1);
frequencyRatio = startingStringLength/endingStringLength;
sampleRatio = frequencyRatio^(1/numSamples);

% L = ones(1, numSamples);
% increment = (endingStringLength - startingStringLength) / (numSamples/2-1);
% L(1:numSamples/2) = startingStringLength:increment:endingStringLength;
% L(numSamples/2 + 1:end) = endingStringLength;

% decrement = (endingStringLength - startingStringLength) / (numSamples-1);
% L = startingStringLength:decrement:endingStringLength;

L = ones(1, numSamples);
L(1) = startingStringLength;
for n = 2:numSamples
    L(n) = L(n-1)/sampleRatio;
end

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y2 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n))
    y2(n) = stringSynth.tick();
end

figure;
subplot(2, 1, 1)
plot(y2);
subplot(2, 1, 2);
plot(L);
% soundsc(y2, Fs)
if writeAudioFlag
    audiowrite(testName + ".wav", y2, Fs);
end

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
% window = hamming(windowLength);
window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5; %corresponds to 5kHz on the frequency axis
figure;
spectrogram(y2, window, overlap, N, Fs, "yaxis");
% ylim([0 y_upperLim]);
%Take a look at how the delay line lengths change to see if some sort of a
%quantization is occuring here to create these non-smooth effects
figure;
% subplot(2, 1, 1);
% stem(0:5, stringSynth.feedbackLoop.fractionalDelayLine.b);
frameLength = 200;
% subplot(2, 1, 2);
stem(0:numSamples-1, y2);
grid on; grid minor;
% for i = 1:numSamples/frameLength
%     xlim([(i-1)*frameLength+1, i*frameLength]);
%     disp("Hit enter for next frame...");
%     pause;
% end

pitch_f0 = calculatePitchF0(L, stringParams.f0);
DWGLength = calculateTotalDWGLength(pitch_f0, Fs);
loopFilterDelay = stringSynth.feedbackLoop.loopFilter.phaseDelay;
fractionalDelayInteger = stringSynth.feedbackLoop.fractionalDelayLine.integerDelay;
[p_int, p_frac_delta] = calculateDelayLineLengths(DWGLength, loopFilterDelay, fractionalDelayInteger);
nRange = 0:numSamples-1;
figure;
yyaxis left
plot(nRange, p_int);
ylabel("Integer Delay Component");
yyaxis right;
plot(nRange, p_frac_delta);
ylabel("Fractional Delay");
xlim([52383 90000])