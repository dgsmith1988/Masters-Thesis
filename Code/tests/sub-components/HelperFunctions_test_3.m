%This tests the functionality associated with the functions used to help
%compute quntities/values used within other classes/functions. These
%functions are:
% 1. generateLcurve()

% clear;
% close all;
dbstop if error

%System parameters
Fs = SystemParams.controlRate;
duration_sec = 2;
numSamples = duration_sec*Fs;

%********Test 1 - same fret for starting and ending********
startingFret = 5;
endingFret = startingFret;

L = generateLCurve(startingFret, endingFret, duration_sec, Fs);
theoretical_L = fretNumberToRelativeLength(startingFret)*ones(1, numSamples);
assert(sum(L == theoretical_L) == numSamples);

figure;
plot(0:numSamples-1, L);
title("Constant Fret generateLCurve() Test");
xlabel("n");
ylabel("L[n]")
grid on; grid minor;

%********Test 2 - test extreme ranges for fret numbers********
startingFret = SystemParams.minFretNumber;
endingFret = SystemParams.maxFretNumber;

L = generateLCurve(startingFret, endingFret, duration_sec, Fs);

figure;
plot(0:numSamples-1, L);
title("Min Fret to Max Fret generateLCurve() Test");
xlabel("n");
ylabel("L[n]")
grid on; grid minor;

assert(L(1) == SystemParams.maxRelativeStringLength);
assert(abs((L(end) - SystemParams.minRelativeStringLength)) <= 10^(-13));

%********Test 3 - test to see that swapping the bounds generates a reveresed curve********
startingFret = SystemParams.maxFretNumber;
endingFret = SystemParams.minFretNumber;

%Store the previous test for comparison
L_test_2 = L;
L = generateLCurve(startingFret, endingFret, duration_sec, Fs);
error = fliplr(L_test_2) - L;

figure;
subplot(2, 1, 1);
plot(0:numSamples-1, L, 0:numSamples-1, L_test_2);
title("Reverse bounds generateLCurve() Test");
xlabel("n");
ylabel("L")
legend("L", "L previous", "Location", "east");
grid on; grid minor;
subplot(2, 1, 2);
plot(0:numSamples-1, error);
ylabel("Error");
xlabel("n");
title("Error after fliplr() of last test");
grid on; grid minor;