%DEPRECATED - this functionality and tests should be done on the string
%object directly given the processing loop is inherent to the operation of
%this object

% clear;
dbstop if error

%Processing parameters
durationSec = 2.5;
Fs = SystemParams.audioRate;
numSamples = durationSec * Fs;

%Control signals/buffers
L = ones(1, numSamples);
y = zeros(1, numSamples);

%Processing objects
feedbackLoop = FeedbackLoop(SystemParams.E_string_params, L(1));
antiAliasingFilter = AntiAliasingFilter();

%data to use as the exciation
bufferData = pinknoise(length(feedbackLoop.integerDelayLine.buffer))';
bufferData = bufferData / max(abs(bufferData)); %Normalize the signal to make it stronger

%******Processing loop******
%Fill the buffer to "pluck" the string 
feedbackLoop.integerDelayLine.initializeBuffer(bufferData);
feedbackSample = 0;
for n = 1:numSamples
    feedbackLoop.consumeControlSignal(L(n));
    feedbackSample = feedbackLoop.tick(feedbackSample);
    y(n) = antiAliasingFilter.tick(feedbackSample);
end

plot(y);
sound(.5*y, Fs)
% audiowrite("string_out.wav", y, Fs);
% yin(y', Fs)

disp("Hit enter to run the next test");
pause();

%******Test changing the delay line length******
startingStringLength = 1;
halfStepRatio = 2^(1/12);
endingStringLength = startingStringLength / halfStepRatio;
sampleRatio = halfStepRatio(1)^(1/(numSamples-1));

L = zeros(1, numSamples);
L(1) = startingStringLength;
for n = 2:numSamples
    L(n) = L(n-1)/sampleRatio;
end

feedbackLoop.integerDelayLine.initializeBuffer(bufferData);
feedbackSample = 0;
for n = 1:numSamples
    feedbackLoop.consumeControlSignal(L(n));
    feedbackSample = feedbackLoop.tick(feedbackSample);
    y(n) = antiAliasingFilter.tick(feedbackSample);
end

plot(y);
sound(.5*y, Fs)
audiowrite("string_out_slide.wav", y, Fs);
