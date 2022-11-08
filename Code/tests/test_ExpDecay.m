% addpath("..\src");
dB_decay = -60;
Fs = 44100;
T = 1/Fs;
dur_sec = 1;
num_samples = dur_sec*Fs;
exp_decay = ExpDecay(dB_decay, num_samples);
y = zeros(1, num_samples);
for n = 1:num_samples
    y(n) = exp_decay.tick();
end
figure;
plot(y);