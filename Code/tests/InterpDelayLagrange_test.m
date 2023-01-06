%David "Graham" Smith
%01/09/2022
%Test script to ensure Interpolated Lagrange delay-line functionality works

clear;
close all;

% addpath("..\src");

%Input test signal and output buffer
impulseLength = 15;
x = [1, zeros(1, impulseLength-1)];
y = zeros(size(x));

%Integer delay settings
M = [3, 6, 9]; 
N = 5; %Lagrange order
d = 0; %No fractional component at the moment
D = (N-1)/2 + d;
delay = M + D;

%******Test the basic constructor first******
figure;
for k = 1:length(M)
    interpolatedDelayLine = InterpDelayLagrange(N, delay(k));
    
    %Run the test signal through the delay to see what comes out
    for n = 1:length(x)
        y(n) = interpolatedDelayLine.tick(x(n));
    end
    
    %Plot the results - Lagrange filters operate best with a delay close to
    %half their order, hence why a fractional delay of 0 still has a 2
    %sample delay
    n = 0:length(x)-1;
    subplot(length(M), 1, k);
    stem(n, x, 'DisplayName', 'x');
    hold on;
    stem(n, y, 'DisplayName', 'y');
    hold off;
    grid on;
    grid minor;
    legend();
    title(sprintf("Interp Lagrange Delay Test - M = %i, D = %1.2f, M + D = %1.2f", M(k), D, M(k) + D));
end

%******Test the increment/decrement delay feature******
%Expand the test stimuli to contain the number of delay settings we want to test
x = repmat(x, [1, 3]);
y = zeros(size(x));
M = 8;
delay = M + D;
interpolatedDelayLine = InterpDelayLagrange(N, delay);
n = 1;
for k = 1:3
    if k == 2
        %Increment the delay line by one
        interpolatedDelayLine.incrementDelay();
    elseif k == 3
        %Decrement the delay by two to be one before the initial delay
        %length
        interpolatedDelayLine.decrementDelay();
        interpolatedDelayLine.decrementDelay();
    end
    for l = 1:impulseLength
        y(n) = interpolatedDelayLine.tick(x(n));
        n = n + 1;
    end
end

%Plot the results. We should see the three different impulses delayed the
%three different amounts (10, 11 and 9)
figure;
n = 0:length(x)-1;
stem(n, x, 'DisplayName', 'x');
hold on;
stem(n, y, 'DisplayName', 'y');
hold off;
title(sprintf("Interp Lagrange Delay Test - Changing Delay During Operation"));
grid on;
grid minor;
legend();

%******Test the setFractionalDelay() function******
%Expand the test stimuli to contain the number of delay settings we want to test
M = [8, 9, 8];
d = [.25, .5, .75];
D = d + (N-1)/2;
delay = M + D;
interpolatedDelayLine = InterpDelayLagrange(N, delay(1));
n = 1;
for k = 1:3
    interpolatedDelayLine.setDelay(delay(k))
    for l = 1:impulseLength
        y(n) = interpolatedDelayLine.tick(x(n));
        n = n + 1;
    end
end

%Plot the results. We should see the impulse responses for the
%interploation spaced the at different distances from the impulse each time
%but %change according to the interpolation amount.
figure;
n = 0:length(x)-1;
stem(n, x, 'DisplayName', 'x');
hold on;
stem(n, y, 'DisplayName', 'y');
hold off;
title(sprintf("Interp Lagrange Delay Test - Changing Delay Component"));
grid on;
grid minor;
legend();