%********Phase Delay for range of delay values*********
%For a fixed order, generate a plot of the different delay values 
%corresponding to different delay amounts.

clear;
close all;

%Lagrange parameters
Fs = SystemParams.audioRate;
N = SystemParams.lagrangeOrder;
increment = 1/8;
delays = 2:increment:3-increment;

%Output buffers to store values
w = zeros(1, FilterObject.N);
phi = zeros(length(delays), FilterObject.N);

%Generate a new figure where everything can be plotted
figure;

for n = 1:length(delays)
    b = hlagr2(N+1, delays(n) - floor(delays(n)));
    lagrangeFilter = FilterObject(b, 1, zeros(N+1, 1));   
    [phi(n,:), w] = lagrangeFilter.computePhaseDelay();
    hold on;
    f = w/pi * Fs/2;
    plot(f, phi(n, :), 'DisplayName', sprintf("Delay = %.2f", delays(n)));
    hold off;
%     text(f(end), mag2db(abs(h(n, end))), sprintf("D = %.2f", delays(n)));
    text(f(500), phi(n, 500), sprintf("D = %.2f", delays(n)));
end

xlabel("Frequency (Hz)");
ylabel("Delay (samples)");
% title("Lagrange Phase Delay for Various Delay Values and Order = 5");
grid on;
grid minor;
% legend("location", "SouthWest");
ylim([1.8 3]);
xlim([0 Fs/2]);