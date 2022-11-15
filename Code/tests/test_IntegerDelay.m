%David "Graham" Smith
%11/15/2022
%Test script to ensure integer delay-line functionality works

clear;

% addpath("..\src");

%Input test signal and output buffer
impulseLength = 10;
x = [1, zeros(1, impulseLength-1)];
y = zeros(size(x));

%Integer delay settings
delays = [1, 3, 6];

%******Test the basic constructor first******
figure;
for k = 1:length(delays)
    integerDelay = IntegerDelay(delays(k));
    
    %Run the test signal through the delay to see what comes out
    for n = 1:length(x)
        y(n) = integerDelay.tick(x(n));
    end

    %Plot the results
    n = 0:length(x)-1;
    subplot(length(delays), 1, k);
    stem(n, x, 'DisplayName', 'x');
    hold on;
    stem(n, y, 'DisplayName', 'y');
    hold off;
    grid on;
    grid minor;
    legend();
    title(sprintf("Integer Delay Test - Delay = %i", delays(k)));
end

%******Test the parameter update feature******

%Expand the input signal to be a short impulse train corresponding to the
%number of delay amounts to test. 
x = repmat(x, [1,length(delays)]);
y = zeros(size(x));
% integerDelay.initializeBuffer(zeros(1, integerDelay.getLength())); %reinitialize the buffer
n = 1;
for k = 1:length(delays)
    integerDelay.setDelay(delays(k));
    for l = 1:impulseLength
        y(n) = integerDelay.tick(x(n));
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
title(sprintf("Integer Delay Test - Changing Delay During Operation"));
grid on;
grid minor;
legend();