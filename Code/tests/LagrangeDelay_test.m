%David "Graham" Smith
%11/15/2022
%Test script to ensure Lagrange delay-line functionality works

clear

% addpath("..\src");

%Input test signal and output buffer
impulseLength = 10;
x = [1, zeros(1, impulseLength-1)];
y = zeros(size(x));

%Fractional delay filter settings
fractionalDelays = [0, .5, 1]; %fractional delay amount
% fractionalDelays = [0, .5, .99]
L = 6;

%******Test the basic constructor first******
figure;
for k = 1:length(fractionalDelays)
    langangeDelay = LagrangeDelay(L, fractionalDelays(k));
    
    %Run the test signal through the delay to see what comes out
    for n = 1:length(x)
        y(n) = langangeDelay.tick(x(n));
    end
    
    %Plot the results - Lagrange filters operate best with a delay close to
    %half their order, hence why a fractional delay of 0 still has a 2
    %sample delay
    n = 0:length(x)-1;
    subplot(length(fractionalDelays), 1, k);
    stem(n, x, 'DisplayName', 'x');
    hold on;
    stem(n, y, 'DisplayName', 'y');
    hold off;
    grid on;
    grid minor;
    legend();
    title(sprintf("Lagrange Delay Test - L = %i, fd = %1.2f", langangeDelay.filterLength, fractionalDelays(k)));
end

%******Test the parameter update feature******
%Expand the input signal to be a short impulse train corresponding to the
%number of delay amounts to test. 
x = repmat(x, [1,length(fractionalDelays)]);
y = zeros(size(x));

n = 1;
for k = 1:length(fractionalDelays)
    %Given that the test signal is an impulse which is longer than the
    %order of the filter, the delay lines from before will be clear and it
    %isn't necessary to instaniate a new object here.
    langangeDelay.setFractionalDelay(fractionalDelays(k));
    for l = 1:impulseLength
        y(n) = langangeDelay.tick(x(n));
        n = n + 1;
    end
end

%Plot the results. We should see the same three IRs from before but
%appearing sequentially in the output signal.
figure;
n = 0:length(x)-1;
stem(n, x, 'DisplayName', 'x');
hold on;
stem(n, y, 'DisplayName', 'y');
hold off;
title(sprintf("Lagrange Delay Test - Changing Delay During Operation"));
grid on;
grid minor;
legend();