%This tests the functionality associated with the FeedbackLoop's
%consumption of the control signal. The actual sound generation will be
%tested in the StringSynth tests using a dummy CSG as the FeedbackLoop
%needs to operate in the computational context provided by the StringSynth
%to work correctly.

clear;
close all;
dbstop if error

%System processing parameters
stringParams = SystemParams.D_string_params;
durationSec = 2;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Generate a control signal which is constant
L = ones(1, numSamples);

%Initialize the processing object
feedbackLoop = FeedbackLoop(stringParams, L(1));

%Check the initialization
assert(Fs * (L(1)/stringParams.f0) == feedbackLoop.DWGLength);
disp("Initialization check passed");

%Output buffers to track the internal state of the feedback loop
DWGLength = zeros(1, numSamples);
p_int = zeros(1, numSamples);
p_frac = zeros(1, numSamples);

for n = 1:numSamples
    
end