clear;

pulseLength_ms = SystemParams.E_string_params.pulseLength;
period_mS = 2*pulseLength_ms;
noisePulse = NoisePulse2(pulseLength_ms, SystemParams.E_string_params.decayRate);
metro = Metro(period_mS, noisePulse);
duration_mS = 5*period_mS;
numSamples = duration_mS*10^-3*SystemParams.audioRate;

y = zeros(1, numSamples);
for n = 1:numSamples
    %TODO: Think about embedding a Metro in a class to ensure a correct
    %calling order later
    metro.tick()
    y(n) = noisePulse.tick();
end

%Todo: Properly tighen this up and do a more accurate sample-by-sample
%verification
plot(y);