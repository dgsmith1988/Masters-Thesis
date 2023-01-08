%This tests the functionality associated with the functions used to help
%compute quntities/values used within other classes/functions. These
%functions are:
% 1. relativeLengthToFretNumber()
% 2. fretNumberToRelativeLength()
% 3. f_c_To_Ticks()
%linearToComplex() is not tested here as that is tested when the filter
%specficiations are translated into coefficients and it doesn't
%generate/process any audio/control signals.

clear;
close all;
dbstop if error

%********Test 1********
%test the RelativeLengthToFretNumber function by sweeping it through a
%range of values to see what comes out. This should be a logarithmic
%relationship.
L_max = SystemParams.maxRelativeStringLength;
L_min = 0; %this value is never achieved however
numSamples = 1000;
decrement = L_max/numSamples;
L = L_max:-decrement:L_min + decrement;

fretNumber = relativeLengthToFretNumber(L);

figure;
subplot(2, 1, 1);
plot(L, fretNumber);
set(gca, 'xdir', 'reverse' )
ylabel("Fret #");
xlabel("Relative String Length");
title("Relative Length to Fret Number Function Output");
grid on;
grid minor;

%plot 3 octaves on top for reference
hold on;
k0 = find(L == 1);
k1 = find(L == .5);
k2 = find(L == .25);
k3 = find(L == .125);
k = [k0, k1, k2, k3];
plot(L(k), fretNumber(k), "*r");
hold off;

%********Test 2********
%We should be able to feed the values we just calculated back into the
%reverse function and generate the original L[n] signal.

L = fretNumberToRelativeLength(fretNumber);
subplot(2, 1, 2);
plot(fretNumber, L);
xlabel("Fret #");
ylabel("Relative String Length");
title("Fret Number to Relative Length Function Output");
grid on;
grid minor;

%plot 3 octaves on top for reference
hold on;
k0 = find(fretNumber == 0);
k1 = find(fretNumber == 12);
k2 = find(fretNumber == 24);
k3 = find(fretNumber == 36);
k = [k0, k1, k2, k3];
plot(fretNumber(k), L(k), "*r");
hold off;


%********Test 3********
%First we test this by keeping the sampling rate constant and sweeping f_c
%through from 0 to the Nyquist rate.
% Fs = SystemParams.audioRate;
Fs = 48000;
% numSamples = 1000;
f_cMax = Fs/2;
% decrement = f_cMax/numSamples;
decrement = .5;
f_c = Fs/2:-decrement: decrement;
ticks = f_cToTicks(f_c, Fs);

figure;
% plot(f_c, ticks);
stem(f_c, ticks);
title(sprintf("ticks vs. f_c at Fs = %i", Fs));
ylabel("ticks");
xlabel("f_c (Hz)");
grid on;
grid minor;
% xlim([-5, f_cMax]);
% xlim([-5, 5000]);

%********Test 4********
%Test this by keeping the f_c constant and sweeping through different
%sampling rates. This should generate a staircase function where the width
%of each "step" corresponds to f_c. It should start at 2 ticks and go to
%192.

f_c = 250;
Fs_min = 2*f_c;
Fs_max = 48000;
numSamples = 1000;
% decrement = (Fs_max - Fs_min)/numSamples;
decrement = 1;
Fs = Fs_max:-decrement:Fs_min;
ticks = f_cToTicks(f_c, Fs);

figure;
plot(Fs, ticks);
% stem(Fs, ticks);
title(sprintf("ticks vs. Fs with f_c = %i", f_c));
ylabel("ticks");
xlabel("Fs (Hz)");
grid on;
grid minor;
% xlim([-5, f_cMax]);
% xlim([-5, 5000]);