%Recreate the graphs from the fractional delay paper to help verify correct
%filter implementation
clear;
close all;

N = 4096;               %FFT size
D = .5;                 %Fractional delay component
L = [2, 3, 4, 5, 6];    %Filter orders

%Places to store the filter coefficients
b = zeros(length(L), max(L));
a = 1; %as we have an FIR
% legendLabels = [];
%Place to store the freqz() and phasedelay() output
w = zeros(1, N);
h = zeros(length(L), N);
phi = zeros(length(L), N);

for n = 1:length(L)
    b_lagrange = hlagr2(L(n), D);
    for i = 1:length(b_lagrange)
        b(n, i) = b_lagrange(i);
    end
    [h(n, :), w] = freqz(b(n, :), a, N);
    [phi(n, :), ~] = phasedelay(b(n, :), a, N);
%     legendLabels(n) = sprintf("L = %i", L(n));
end

%Plot the results
figure;
subplot(2, 1, 1);
plot(w/pi, abs(h));
xlabel("Normalized Frequency");
ylabel("Magnitude (Linear)");
legend(compose("L = %i", L));
grid on; grid minor;
subplot(2, 1, 2);
plot(w/pi, phi);
xlabel("Normalized Frequency");
ylabel("Phase Delay (Samples)");
legend(compose("L = %i", L));
grid on; grid minor;