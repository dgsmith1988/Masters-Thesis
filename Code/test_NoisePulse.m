%Quick test to ensure Noise Pulses are generated correctly. It might be
%worth making a class for that to ensure the same exact functionality is
%called later but this is sufficient for now... 

clear;
close all;

%System parameters
Fs = 48000;
T = 1/Fs;
dur_sec = 4;
num_samples = dur_sec*Fs;
N = 4096;

%Pulse parameters
pulse_count = 5;
pulse_period = round(num_samples/pulse_count);

%Amplitude envelope parameters
dB_decay = -60;
envelope_length = pulse_period;

%Processing objects/variables
noise_pulse = NoisePulse(pulse_period, pulse_count, dB_decay, envelope_length, Fs);
y = zeros(1, num_samples);

for n = 1:num_samples
    y(n) = noise_pulse.tick();
end

plot(y);
sound(.5*y, Fs)

% Y = fft(y, N);
% plot(mag2db(abs(Y)));