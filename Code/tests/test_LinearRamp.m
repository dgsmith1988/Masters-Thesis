%addpath("..\src");
rampLength_ms = SystemParams.E_string_params.pulseLength;
rampLength_samples = (rampLength_ms*10^-3)*SystemParams.audioRate;
num_samples = rampLength_samples + 500;
linearRamp = LinearRamp(rampLength_ms);
y = zeros(1, num_samples);
for n = 1:num_samples
    y(n) = linearRamp.tick();
end
figure;
plot(y);
title(sprintf("Ramp Length Samples = %i", rampLength_samples))