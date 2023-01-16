%System processing parameters
stringParams = SystemParams.A_string_params;
stringParams.n_w = -1; %indicate that we don't use a CSG
stringParams.f0 = 4*120; %set this to a frequency which has an integer length period in samples at this Fs
stringModeFilterSpec = SystemParams.A_string_modes.chrome;
waveshaperFunctionHandle = @tanh;
durationSec = 3;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 15; %corresponds to 15kHz on the frequency axis

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

P.minf0 = stringParams.f0;
P.maxf0 = stringParams.f0;
P.sr = Fs;
% yin_out = yin(y1', Fs);
yin_out = yin(y1', P);

figure;
subplot(3, 1, 1);
plot(yin_out.f0);
title("f0 from YIN");
ylabel("Hz");
xlabel("Frame #");
subplot(3, 1, 2);
plot(abs(yin_out.f0 - stringParams.f0));
title("absolute error");
ylabel("Hz");
xlabel("Frame #");
subplot(3, 1, 3);
plot(abs((yin_out.f0 - stringParams.f0)/stringParams.f0));
title("percent error");
ylabel("Hz");
xlabel("Frame #");