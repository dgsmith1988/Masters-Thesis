close all;
clear;
dbstop if error;


%System parameters
stringParams = SystemParams.E_string_params;
stringModeFilterSpec = SystemParams.E_string_modes.brass;
pulseLength_ms = stringParams.pulseLength;
decayRate = stringParams.decayRate;
n_w = stringParams.n_w;
triggerPeriod_ms = 2*pulseLength_ms;
period_samples = round(triggerPeriod_ms*10^-3*SystemParams.audioRate);
duration_ms = 5*triggerPeriod_ms;
numSamples = round(duration_ms*10^-3*SystemParams.audioRate);

%Engineer the L[n] control signal to generate pulses according to the
%parameters above and have it also stop to tigger that functionality in the
%object
slideVelocity = 100/(triggerPeriod_ms*n_w);
stringStart = .25;
stringEnd = stringStart + slideVelocity*(numSamples-1);
L = stringStart:slideVelocity:stringEnd;

noMotionDuration = calculateTicks(2*(NoisePulseTrain.disableDelay_ms));
L = [L, L(end)*ones(1, noMotionDuration)];
numSamples = length(L);
L_n_1 = L(1)-slideVelocity;
contactSoundGenerator = ContactSoundGenerator(stringParams, stringModeFilterSpec, @tanh, L_n_1);

y = zeros(1, length(L));
for n = 1:length(L)
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, length(L));
    end
    y(n) = contactSoundGenerator.tick(L(n));
end

plot(y);
title("CSG Test Output");