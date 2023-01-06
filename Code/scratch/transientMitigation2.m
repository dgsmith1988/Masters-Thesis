%Compare the Farrow object to my implementation of an interpolated delay
%line

clear;
close all;

%System parameters
Fs_audio = SystemParams.audioRate;
Fs_control = SystemParams.controlRate;
R = Fs_audio/Fs_control;
duration_sec = 2;
numSamples_audio = duration_sec*Fs_audio;
numSamples_control = duration_sec*Fs_control;
nRange_audio = 0:numSamples_audio-1;
nRange_control = 0:numSamples_control-1;
N_lagrange = 5;                 %Lagrange interpolation order
L = 6;                          %Filter length for interpolation
D_min = (N_lagrange - 1) / 2;   %inclusive minimum
D_max = (N_lagrange + 1) / 2;   %exclusive minimum

%Sample delay values control signal
start = 5;
stop = 8;
increment = (stop - start)/(numSamples_control - 1);
delay = start:increment:stop;

%Input signal is a sine wave to make things clearer. Put it in the filter's
%pass band.
f0 = 480;
x = sin(2*pi*f0/Fs_audio*nRange_audio);

%Processing object initialization
farrowDelay = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow', 'FilterLength', L);
%only the inteprolation order matters at instantaition as we change the
%other componenets during the processing loop
interpDelayLagrange = InterpDelayLagrange(N_lagrange, delay(1));
y_farrow = zeros(1, numSamples_audio);
y_lagrangeInterp = zeros(1, numSamples_audio);

%apply interpolation to the D(n) control signal
delay_interp = zeros(1, Fs_audio);
n_audio = 1;
for n_control = nRange_control+1
    %Hold the last value as we have nothing to interpolate to
    if n_control == nRange_control(end) + 1
        increment = 0;
    else
        %calculate the increment to be added each sample
        increment = (delay(n_control+1) - delay(n_control))/R;
    end
    
    for k = 0:R-1
        delay_interp(n_audio) = delay(n_control) + k*increment;
        n_audio = n_audio + 1;
    end
end

figure
subplot(2, 1, 1);
plot(nRange_control, delay);
title("delay");
subplot(2, 1, 2);
plot(nRange_audio, delay_interp);
title("delay interp");

%Processing loop
for n_audio = nRange_audio+1
    if(mod(n_audio, 100) == 0)
        fprintf("n_audio = %i/%i\n", n_audio, numSamples_audio);
    end
    interpDelayLagrange.setDelay(delay_interp(n_audio));
    y_lagrangeInterp(n_audio) = interpDelayLagrange.tick(x(n_audio));
    y_farrow(n_audio) = farrowDelay(x(n_audio), delay_interp(n_audio));
end

figure;
subplot(2, 1, 1);
plot(nRange_audio, x, nRange_audio, y_farrow, nRange_audio, y_lagrangeInterp);
legend('x', 'y farrow', 'y lagrange interp');
grid on;
grid minor;

%TODO: Determine the source of this error
subplot(2, 1, 2);
y_error = y_farrow - y_lagrangeInterp;
plot(nRange_audio, y_error);
grid on; grid minor;

% frameLength = 300;
% overlap = .5;
% hopSize = frameLength*(1-overlap);
% for i = 1:numSamples_audio/(hopSize)
%     start = (i-1)*hopSize+1;
%     stop = start + frameLength;
%     xlim([start, stop]);
%     disp("Hit enter for next frame...");
%     pause;
% end

windowLength = 12*10^-3*Fs_audio; %12 ms window
window = blackmanharris(windowLength);
% window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim = 5;

figure;
subplot(2, 1 , 1);
spectrogram(y_lagrangeInterp, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim]);
title('y lagrange interp');
subplot(2, 1, 2);
spectrogram(y_farrow, window, overlap, N, Fs_audio, "yaxis");  
ylim([0 y_upperLim]);
title('y farrow');
