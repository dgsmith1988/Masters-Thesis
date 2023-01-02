%The goal here is to determine how changing the fractional delay line
%during run-time introduces different transients.

clear;
close all;

%System parameters
Fs = SystemParams.audioRate;
duration_sec = 2;
numSamples = duration_sec*Fs;
nRange = 0:numSamples-1;

%Delay values control signal
% transitionSample = 120;
% D = [.0*ones(1, transitionSample), .5*ones(1, numSamples-transitionSample)];
D = 0:1/(numSamples/8-1):1;
D = repmat(D, 1, 8);

%Input signal is a sine wave to make things clearer. Put it in the filter's
%pass band.
f0 = 480;
x = sin(2*pi*f0/Fs*nRange);
% x = [1, zeros(1, numSamples-1)];
% x = ones(1, numSamples);
% x = repmat([1, zeros(1, 11)], 1, numSamples/12);

%Processing object initialization
lagrangeDelay = LagrangeDelay(D(1));
y_lagrange = zeros(1, numSamples);

%Processing loop
for n = nRange+1
    if(mod(n, 100) == 0)
        fprintf("n = %i/%i\n", n, numSamples);
    end
    lagrangeDelay.setFractionalDelay(D(n));
    y_lagrange(n) = lagrangeDelay.tick(x(n));
end

% stem(nRange, x);
% hold on;
% stem(nRange, y_lagrange);
% hold off;
plot(nRange, x, nRange, y_lagrange);
% hold on;
% stem(transitionSample-1, y_lagrange(transitionSample));
% hold off;
legend('x', 'y lagrange');
xlim([0 200]);
grid on;
grid minor;

frameLength = 200;
for i = 1:numSamples/frameLength
    xlim([(i-1)*frameLength+1, i*frameLength]);
    disp("Hit enter for next frame...");
    pause;
end