%Test functionality of the noise burst trigger chain of objects. This
%requires that the ControlSignalProcessor class be tested and verified
%first.
clear;

%System parameters
pulseLength_ms = SystemParams.E_string_params.pulseLength;
n_w = SystemParams.E_string_params.windsParam;
period_mS = 2*pulseLength_ms;
period_samples = period_mS*10^-3*SystemParams.audioRate;
duration_mS = 5*period_mS;
numSamples = round(duration_mS*10^-3*SystemParams.audioRate);

%Engineer the L[n] control signal to generate pulses according to the
%parameters above
slideVelocity = 100/(period_mS*n_w);
stringStart = .25;
stringEnd = stringStart + slideVelocity*(numSamples-1);
L = stringStart:slideVelocity:stringEnd;
%buffers to be filled during processing loop
f_c = zeros(1, numSamples);
y = zeros(1, numSamples);

%Processing objects
controlSignalProcessor = ControlSignalProcessor(n_w);
noisePulse = NoisePulse2(pulseLength_ms, SystemParams.E_string_params.decayRate);
metro = Metro(period_mS, noisePulse);
noiseBurstTrigger = NoiseBurstTrigger(metro);

%Processing loop
for n = 1:numSamples
    f_c(n) = controlSignalProcessor.tick(L(n));
    noiseBurstTrigger.tick(f_c(n));
    metro.tick()
    y(n) = noisePulse.tick();
end

plot(y);
title("Noise Burst Trigger Test");