%David "Graham" Smith
%09/22/2022
%Test script to ensure integer delay-line functionality works

addpath("..\src");

%Input test signal and output buffer
x = [1, zeros(1, 9)];
y = zeros(size(x));


%Integer delay settings
delay_amounts = [1, 3, 6];

for delay = delay_amounts
    dl_int = DelayLineInteger(delay);
    
    %Run the test signal through the delay to see what comes out
    for n = 1:length(x)
        y(n) = dl_int.tick(x(n));
    end

    %Plot the results
    n = 0:length(x)-1;
    figure;
    stem(n, x, 'DisplayName', 'x');
    hold on;
    stem(n, y, 'DisplayName', 'y');
    hold off;
    grid on;
    grid minor;
    legend();
    title(sprintf("Integer Delay Test - Delay = %i", delay));
end