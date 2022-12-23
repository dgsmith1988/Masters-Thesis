%Test the ImpulseTrain class

clear all;
close all;

%********Basic test for a constant rate********
Fs = SystemParams.audioRate;
tickLimit = 5;
numSamples = 30;
impulseTrain = ImpulseTrain(tickLimit);
f_c = Fs/tickLimit;

%Output buffer
y = zeros(1, numSamples);

for n = 1:numSamples
    y(n) = impulseTrain.tick(f_c);
end

figure;
subplot(5, 1, 1);
stem(0:numSamples-1, y);
title('Constant rate');

%********Test for a changing rate - rate increases********
tickLimits = [5, 6];
f_c1 = Fs/tickLimits(1);
f_c2 = Fs/tickLimits(2);

f_c = [f_c1*ones(1, 15), f_c2*ones(1, 15)];

impulseTrain = ImpulseTrain(tickLimits(1));
for n = 1:numSamples
    y(n) = impulseTrain.tick(f_c(n));
end

subplot(5, 1, 2);
stem(0:numSamples-1, y);
title('Rate increases at sample 15');

%********Test for a changing rate - rate decreases********
tickLimits = [6, 5];
f_c1 = Fs/tickLimits(1);
f_c2 = Fs/tickLimits(2);

f_c = [f_c1*ones(1, 15), f_c2*ones(1, 15)];

impulseTrain = ImpulseTrain(tickLimits(1));
for n = 1:numSamples
    y(n) = impulseTrain.tick(f_c(n));
end

subplot(5, 1, 3);
stem(0:numSamples-1, y);
title('Rate decreases at sample 15');

%********Test for a transition to stop********
tickLimit = 5;
f_c = [Fs/tickLimit*ones(1, 15), zeros(1, 15)];

impulseTrain = ImpulseTrain(tickLimit);
for n = 1:numSamples
    y(n) = impulseTrain.tick(f_c(n));
end

subplot(5, 1, 4);
stem(0:numSamples-1, y);
title('Object stops at sample 15');

%********Test for a transition to start********
tickLimit = 5;
f_c = [zeros(1, 15), Fs/tickLimit*ones(1, 15)];

impulseTrain = ImpulseTrain(0);
for n = 1:numSamples
    y(n) = impulseTrain.tick(f_c(n));
end

subplot(5, 1, 5);
stem(0:numSamples-1, y);
title('Object starts at sample 15');

%TODO: Add a test for where the f_c signal sweeps through a range of
%values?
