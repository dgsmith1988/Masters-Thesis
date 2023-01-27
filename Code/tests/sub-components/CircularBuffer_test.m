%David "Graham" Smith
%01/27/2023
%Test script to ensure integer delay-line functionality works

clear;
close all;

%Input test signal and output buffer
impulseLength = 10;
x = [1, zeros(1, impulseLength-1)];
y = zeros(size(x));

%Delay settings
delays = [1, 3, 6];

%******Test the basic constructor first******
figure;
for k = 1:length(delays)
    circularBuffer = CircularBuffer(delays(k));
    
    %Run the test signal through the delay to see what comes out
    for n = 1:length(x)
        y(n) = circularBuffer.tick(x(n));
    end

    %Plot the results
    n = 0:length(x)-1;
    subplot(length(delays), 1, k);
    stem(n, x, 'DisplayName', 'x');
    hold on;
    stem(n, y, 'DisplayName', 'y');
    hold off;
    grid on;
    grid minor;
    legend();
    title(sprintf("Circular Buffer Test - Delay = %i", delays(k)));
end

%******Test the increment/decrement features******

%Expand the input signal to be a short impulse train corresponding to the
%number of delay amounts to test. 
x = repmat(x, [1, 3]);
y = zeros(size(x));
n = 1;
for k = 1:3
    if k == 2
        %Increment the delay line by one
        circularBuffer.incrementDelay();
    elseif k == 3
        %Decrement the delay by two to be one before the initial delay
        %length
        circularBuffer.decrementDelay();
        circularBuffer.decrementDelay();
    end
    for l = 1:impulseLength
        y(n) = circularBuffer.tick(x(n));
        n = n + 1;
    end
end

%Plot the results. We should see the same three IRs from before but
%appearing sequentially in the output signal.
figure;
n = 0:length(x)-1;
stem(n, x, 'DisplayName', 'x');
hold on;
stem(n, y, 'DisplayName', 'y');
hold off;
title(sprintf("Circular Buffer Test - Changing Delay During Operation"));
grid on;
grid minor;
legend();

%******Test the getSampleAtOffset() function******
%Initialize the buffer with a sequence and then read it out to make sure it
%is correct

delay = 10;
circularBuffer = CircularBuffer(delay);
%reverse the sequence at the input here based on how the read/writer
%pointers are laid out.
sequence = delay-1:-1:0;
circularBuffer.initializeDelayLine(sequence);
y = zeros(1, delay);

for n = 1:delay
    y(n) = circularBuffer.getSampleAtOffset(n);
end

figure;
nPlot = 0:delay-1;
stem(nPlot, y);
title("Circular Buffer Indexing Test - y[n]");
xlabel("Time-index (n)");
ylabel("Sample Value");
grid on; grid minor;

% %******Test the index  wrap around functionality******
%Write enough samples to cross over the end of the buffer boundary and then
%extract all the elements from the buffer using the getSampleAtDelay()
%value to make sure the seqeuence is the same.

delay = 10;
circularBuffer = CircularBuffer(delay);
numSamples = CircularBuffer.maxDelay - delay/2;

%Buffers to track variables/output over time
writePointer = zeros(1, numSamples+1);
readPointer = zeros(1, numSamples+1);
y = zeros(1, delay);

%Run the delay algorithm
for n = 0:numSamples-1
    %Grab the values at the start of each time-index
    writePointer(n+1) = circularBuffer.writePointer;
    readPointer(n+1) = circularBuffer.readPointer;
    circularBuffer.tick(n);
end

%Grab the last values from the last transition
writePointer(end) = circularBuffer.writePointer;
readPointer(end) = circularBuffer.readPointer;

%Extract the last "delay" values
for n = 1:delay
    y(n) = circularBuffer.getSampleAtOffset(n);
end

start = numSamples - 1;
stop = start - (delay-1);
nPlot = start:-1:stop;
figure;
subplot(3, 1, 1);
stem(nPlot, y)
set (gca, 'xdir', 'reverse')
title("Circular Buffer Indexing Test - y[n]");
xlabel("Time-index (n)");
ylabel("Sample Value");
grid on; grid minor;
ylim([nPlot(end) nPlot(1)]);

subplot(3, 1, 2);
stem(0:numSamples, writePointer);
title("Write Pointer Value Over Time")
xlabel("Time-index (n)");

subplot(3, 1, 3);
stem(0:numSamples, readPointer);
title("Read Pointer Value Over Time");
xlabel("Time-index (n)");

assert(writePointer(end) == writePointer(1) + numSamples - CircularBuffer.maxDelay, "Write Pointer did not correctly wrap around");
assert(readPointer(end) == readPointer(1) + numSamples, "Read Pointer did not correctly wrap around");