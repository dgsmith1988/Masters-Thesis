%Script to make measurements using UMIK-2 Microphone. Make sure the
%settings here match what appears in the device's configuration panel.
clear;
close all;

%Length of audio to capture
duration_sec = 5;

%Device Settings
Fs = 48000;
bitDepth = "32-bit float";
device = "miniDSP ASIO Driver";
driver = "ASIO";
numChannels = 1; %UMIK-2 output channels are identical so just grab 1
numSamples = duration_sec*Fs;
samplesPerFrame = 1024;

%Spectrogram analysis parameters
windowLength = 12*10^-3*Fs; %12 ms window
window = hamming(windowLength);
% window = rectwin(windowLength);
overlap = .75*windowLength;
N = 4096;
y_upperLim_kHz = Fs/2000; 

%*******End of user configuration, program begins********
%Frame related calculations
numFrames = ceil(numSamples/samplesPerFrame); %round up to simplify things
numSamples = numFrames*samplesPerFrame; %recalculate based on ceiling function to have an integer number of frames

%Create/setup the various processing objects and buffers before running the loop
deviceReader = audioDeviceReader("Device", device, "Driver", driver, "NumChannels", numChannels, "SamplesPerFrame", samplesPerFrame, "SampleRate", Fs, "BitDepth", bitDepth);
setup(deviceReader)
capturedAudio = zeros(numSamples , numChannels);
numOverrun = zeros(1, numFrames);

%Processing loop
fprintf("Audio capture starting for %1.2f secs.\n", duration_sec);
for n = 1:numFrames
    if mod(n, 25) == 0
        fprintf("Frame #: %i/%i\n",n , numFrames);
    end
    iStart = samplesPerFrame*(n-1) + 1;
    iEnd = iStart + samplesPerFrame - 1;
    [capturedAudio(iStart:iEnd), numOverrun(n)] = deviceReader();
    if numOverrun ~= 0
        fprintf("Frame #%i - %i samples of overrun" , n, numOverrun(n));
    end
end

%Transpose it into a row-vector as I prefer that
capturedAudio = capturedAudio';

fprintf("Audio capture finshed.\n");
fprintf("Total number of samples overrun: %d.\n", sum(numOverrun));
release(deviceReader);

%********Generate Plots********
t = (0:numSamples - 1)/Fs;

figure;
plot(t, capturedAudio);
title("Captured Audio Data");
xlabel("Sec");
ylabel("Amplitude");

figure;
spectrogram(capturedAudio, window, overlap, N, Fs, "yaxis");  
ylim([0 y_upperLim_kHz]);
title("Captured Audio Data");