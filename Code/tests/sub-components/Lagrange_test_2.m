%********Frequency Response for range of delay values*********
%For a fixed order, generate a plot of the different frequency response
%values corresponding to different delay amounts.

clear;
close all;

%Lagrange parameters
N = SystemParams.lagrangeOrder;
increment = 1/8;
delays = 2:increment:2.5;

%Output buffers to store values
f = zeros(1, FilterObject.N);
h = zeros(length(delays), FilterObject.N);

%Generate a new figure where everything can be plotted
figure;

for n = 1:length(delays)
    b = hlagr2(N+1, delays(n) - floor(delays(n)));
    lagrangeFilter = FilterObject(b, 1, zeros(N+1, 1));   
    [h(n,:), f] = lagrangeFilter.computeFrequencyResponse();
    hold on;
    plot(f, mag2db(abs(h(n, :))), 'DisplayName', sprintf("Delay = %.2f", delays(n)));
    hold off;
%     text(f(end), mag2db(abs(h(n, end))), sprintf("D = %.2f", delays(n)));
%     text(f(end), mag2db(abs(h(n, end))), sprintf("D = %.2f", delays(n)), 'FontSize', 6);
end

xlabel("Frequency (Hz)");
ylabel("Magnitude (dB)");
title("Lagrange Magnitude Response for Various Delay Values");
grid on;
grid minor;
legend("location", "SouthWest");