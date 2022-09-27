%David "Graham" Smith
%09/22/2022
%Test script to ensure fractional delay-line functionality works

%Input test signal and output buffer
x = [1, zeros(1, 9)];
y = zeros(size(x));


%Fractional delay filter settings
L = 6;                      %number of taps
fractional_delay = [0, .5, 1]; %fractional delay amount

for k = 1:length(fractional_delay)
    dl_frac = DelayLineFraction(L, fractional_delay(k));
    
    %Run the test signal through the delay to see what comes out
    for n = 1:length(x)
        y(n) = dl_frac.tick(x(n));
    end

    %Plot the results - Lagrange filters operate best with a delay close to
    %half their order, hence why a fractional delay of 0 still has a 2
    %sample delay
    n = 0:length(x)-1;
    figure;
    stem(n, x, 'DisplayName', 'x');
    hold on;
    stem(n, y, 'DisplayName', 'y');
    hold off;
    grid on;
    grid minor;
    legend();
    title(sprintf("Fractional Delay Test - L = %i, fd = %1.2f", L, fractional_delay(k)));
end