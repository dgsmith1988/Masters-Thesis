%Scratch pad to work out details associated with the stopping aspect...

clear;

%System parameters
stringParams = SystemParams.E_string_params;
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

noMotionDuration = NoisePulseTrain.calculateTicks(2*(NoisePulseTrain.disableDelay_ms));
L = [L, L(end)*ones(1, noMotionDuration)];
numSamples = length(L);

%buffers to be filled during processing loop
f_c = zeros(1, numSamples);
slideVelocitySignal = zeros(1, numSamples);
y = zeros(1, numSamples);

%Processing objects
controlSignalProcessor = ControlSignalProcessor(n_w, L(1)-slideVelocity);
noisePulseTrain = NoisePulseTrain(triggerPeriod_ms, pulseLength_ms, decayRate);

%Processing loop
for n = 1:numSamples
    [slideVelocitySignal(n), f_c(n)] = controlSignalProcessor.tick(L(n));
    y(n) = noisePulseTrain.tick(f_c(n));
end


subplot(2, 1, 1);
plot(y);
title("Noise Pulse Train Test");

subplot(2, 1, 2);
plot(f_c, 'DisplayName', 'f_c');
hold on;
plot(slideVelocitySignal, 'DisplayName', 'slide velocity');
hold off;
legend();