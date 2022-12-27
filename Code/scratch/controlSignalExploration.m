clear;
dbstop if error

%System processing parameters
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;
stringLength = SystemParams.stringLengthMeters;
stringParams = SystemParams.D_string_params;
n_w = stringParams.n_w; %extract the parameter before we overwrite it
stringParams.n_w = -1; %indicate that we don't use a CSG
stringModeFilterSpec = SystemParams.D_string_modes.chrome;
waveshaperFunctionHandle = @tanh;

%Generate the appropriate control signal
startingStringLength = 1;
halfStepRatio = 2^(1/12);
endingStringLength = startingStringLength / halfStepRatio;
sampleRatio = halfStepRatio(1)^(1/(numSamples/2-1));

L = ones(1, numSamples);
L(1) = startingStringLength;
for n = 2:numSamples/2-1
    L(n) = L(n-1)/sampleRatio;
end

L(numSamples/2:end) = L(numSamples/2-1) * L(numSamples/2:end);
L_smooth_2 = filter([.5 .5], 1, L);
L_smooth_4 = filter([.25 .25 .25 .25], 1, L);

figure;
plot(L, "DisplayName", "Orginal");
hold on;
plot(L_smooth_2, "DisplayName", "Two-point average");
plot(L_smooth_4, "DisplayName", "Four-point average");
hold off;
legend();
xlim([numSamples/2-10 numSamples/2+10]);
ylim([.94387 .94389]);

% f_c = 250*ones(1, numSamples);
% 
% %generate the control signal based on the derivations in your notebook
% L = zeros(1, numSamples);
% L(1) = 1;
% for n = 2:numSamples
%     L(n) = L(n-1) - f_c(n)/(n_w*stringLength*Fs);
% end

%Processing objects
stringSynth = StringSynth(stringParams, stringModeFilterSpec, waveshaperFunctionHandle, L(1));
y2 = zeros(1, numSamples);

%Processing loop
stringSynth.pluck(); %Set up the string to generate noise...
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L_smooth_4));
    end
    y2(n) = stringSynth.tick(L_smooth_4(n));
end

figure;
plot(y2);
% soundsc(y2, Fs)
audiowrite("control signal explore output.wav", y2, Fs);