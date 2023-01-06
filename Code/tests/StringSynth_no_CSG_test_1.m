%Test the String Synth without a CSG and no slide motion

close all;
clear;
dbstop if error
writeAudioFlag = false;
testName = "StringSynth Test 1 - No CSG - No Slide Motion";

%System processing parameters
stringParams = SystemParams.e_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.E_string_modes.chrome;
waveshaperFunctionHandle = @tanh;
durationSec = 2;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Generate the constant control signal
L = ones(1, numSamples);

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y1 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    stringSynth.consumeControlSignal(L(n));
    y1(n) = stringSynth.tick();
end

plot(y1);
title(testName);
% soundsc(y1, Fs)
if writeAudioFlag
    audiowrite(testName + ".wav", y1, Fs);
end

% figure;
% subplot(2, 1, 1);
% stem(0:5, stringSynth.feedbackLoop.fractionalDelayLine.b);
% frameLength = 143;
% subplot(2, 1, 2);
% stem(0:numSamples-1, y1);
% grid on;
% grid minor;
% for i = 1:numSamples/frameLength
%     xlim([(i-1)*frameLength+1, i*frameLength]);
%     disp("Hit enter for next frame...");
%     pause;
% end