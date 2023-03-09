%Test the ControlSignalProcessor
close all;
clear all;

%General system parameters
duration_sec = .6;
Fs_audio = SystemParams.audioRate;
Fs_ctrl = SystemParams.controlRate;
R = SystemParams.R;
numSamples_audio = Fs_audio*duration_sec;
numSamples_ctrl = Fs_ctrl*duration_sec;
nAudio = 0:numSamples_audio-1;
nCtrl = 0:numSamples_ctrl-1;

%*********Test 1 - Linear L[m]*********
%generate the control signal based on the derivations in your notebook
start = fretNumberToRelativeLength(0);
stop = fretNumberToRelativeLength(24);
increment = (stop - start) / (numSamples_ctrl-1);
L_m = start:increment:stop;

%Processing objects/buffers
controlSignalProcessor = ControlSignalProcessor(L_m(1));
L_n = zeros(1, numSamples_audio);
slideSpeed_n = zeros(1, numSamples_audio);

%Processing loop
n = 1;
for m = 1:numSamples_ctrl
    controlSignalProcessor.consumeControlSignal(L_m(m));
    for k = 1:R
        if(mod(n, 100) == 0)
            fprintf("n = %i/%i\n", n, numSamples_audio);
        end
        [L_n(n), slideSpeed_n(n)] = controlSignalProcessor.tick();
        n = n + 1;
    end
end

figure;
subplot(3, 1, 1);
plot(nCtrl, L_m, 'DisplayName', 'L[m]');
ylabel("L[m]");
xlabel("m (time-index)");
grid on; grid minor;

subplot(3, 1, 2);
plot(nAudio, L_n, 'DisplayName', 'L[n]');
ylabel("L[n]");
xlabel("n (time-index)");
grid on; grid minor;

subplot(3, 1, 3);
plot(nAudio, slideSpeed_n, 'DisplayName', 'slideSpeed[n]');
ylabel("slideSpeed[n]");
xlabel("n (time-index)");
grid on; grid minor;