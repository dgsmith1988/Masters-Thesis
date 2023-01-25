%This tests the internal processing and functions of the StringDWG to
%make sure the values are objects are updated correctly. The parameter
%functions were tested in the HelperFunctions_test_1.m script. The test goes
%through a linear sweep of the range of L and extracts the corresponding
%calculated parameters from the internal object state at each sample.
%These extracted parameters are compared to the theoretical values.

clear all;
close all;
dbstop if error

%Basic system parameters
Fs = SystemParams.audioRate;
duration_sec = 2;
numSamples = round(duration_sec * Fs);
stringParams = SystemParams.D_string_params;
max_L = SystemParams.maxRelativeStringLength;
min_L = SystemParams.minRelativeStringLength;
openString_f0 = stringParams.f0;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000;

%*****************************Test code starts*****************************

%Create the processing object
stringDWG = StringDWG(stringParams, max_L, "Pink", true);

%Generate the control signal
decrement = (min_L - max_L) / (numSamples-1);
L = max_L:decrement:min_L;

%Geneate the theoretical values
loopFilterDelay = stringDWG.loopFilter.phaseDelay;
lagrangeOrder = stringDWG.interpolatedDelayLine.N;

pitch_f0_target = calculatePitchF0(L, openString_f0);
DWGLength_target = calculateTotalDWGLength(pitch_f0_target, Fs);
interpDelay_target = calculateInterpDelayLineLength(DWGLength_target, loopFilterDelay);
[M_target, D_min, D_target, d_target] = calculateInterpDelayLineComponents(lagrangeOrder, interpDelay_target);

%Buffers to store the captured data
y = zeros(1, numSamples);
M_measured = zeros(1, numSamples);
D_measured = zeros(1, numSamples);
d_measured = zeros(1, numSamples);
pitch_f0_measured = zeros(1, numSamples);
DWGLength_measured = zeros(1, numSamples);

%Run the processing loop
stringDWG.pluck();
for n = 1:numSamples
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    %Consume the control signal and output a sample
    stringDWG.consumeControlSignal(L(n));
    y(n) = stringDWG.tick(0);
    %Extract the parameters from the object state
    M_measured(n) = stringDWG.interpolatedDelayLine.M;
    D_measured(n) = stringDWG.interpolatedDelayLine.D;
    d_measured(n) = stringDWG.interpolatedDelayLine.d;
    pitch_f0_measured(n) = stringDWG.pitch_f0;
    DWGLength_measured(n) = stringDWG.DWGLength;
end

M_err = M_target - M_measured;
D_err = D_target - D_measured;
d_err = d_target - d_measured;
pitch_f0_err = pitch_f0_target - pitch_f0_measured;
DWGLength_err = DWGLength_target - DWGLength_measured;

figure;
subplot(5, 1, 1);
plot(L, M_err);
title("M Error");
subplot(5, 1, 2);
plot(L, D_err);
title("D Error");
subplot(5, 1, 3);
plot(L, d_err);
title("d Error");
subplot(5, 1, 4);
plot(L, pitch_f0_err);
title("Pitch f0 Error");
subplot(5, 1, 5);
plot(L, DWGLength_err);
title("DWG Length Error");

assert(sum(M_err) == 0);
assert(sum(D_err) == 0);
assert(sum(d_err) == 0);
assert(sum(pitch_f0_err) == 0);
assert(sum(DWGLength_err) == 0);

figure;
plot(y);
title("String DWG - Test 2");

figure;
spectrogram(y, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title('String DWG - Test 2')