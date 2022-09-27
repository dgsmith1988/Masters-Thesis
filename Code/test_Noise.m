%Quick test to make sure Noise class works. Basic idea is to generate a
%bunch of samples and check that the spectrum is flat and/or look at their
%statistics. TODO: Think of a more robust way to test this later...

clear;
close all;

N = 4096;
Fs = 44100;
num_samples = 5*Fs;
y = zeros(1, num_samples);

for n = 1:num_samples
    y(n) = Noise.tick();
end

y_mean = mean(y)    %should be close to zero
y_range = range(y)  %should be close to 2

Y = fft(y, N);
plot(mag2db(abs(Y)));