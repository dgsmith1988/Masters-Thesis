%Script for generating filter coefficients base on the specification used
%in the CMJ paper (i.e. pole/zero locations based on linear frequencies and
%radius values)

clear;

Fs = 48000;

E_string.brass.zeros.f = [0, 0, 1400, -1400];
E_string.brass.zeros.R = [.9485, .8510, .9079, .9079];
E_string.brass.poles.f = [643 -643 1400 -1400];
E_string.brass.poles.R = [.9894, .9894, .9922, .9922];

E_string.glass.zeros.f = [0, 0, 1400, -1400];
E_string.glass.zeros.R = [.9272, .8222, .9608, .9608];
E_string.glass.poles.f = [850, -850, 1400, -1400];
E_string.glass.poles.R = [.9957, .9957, .9984, .9984];

E_string.chrome.zeros.f = [696, -696, 1422, -1422];
E_string.chrome.zeros.R = [.9608, .9608, .8042, .8042];
E_string.chrome.poles.f = [748 -748 1422 -1422];
E_string.chrome.poles.R = [.9929, .9929, .9937, .9937];

A_string.brass.zeros.f = [0, 0, 1600, -1600];
A_string.brass.zeros.R = [.9406, .8105, .9478, .9478];
A_string.brass.poles.f = [793 -793 1600 -1600];
A_string.brass.poles.R = [.9957, .9957, .9948, .9948];

A_string.glass.zeros.f = [0, 0, 1640, -1640];
A_string.glass.zeros.R = [.9646, .7902, .9217, .9217];
A_string.glass.poles.f = [644, -644, 1640, -1640];
A_string.glass.poles.R = [.9957, .9957, .9922, .9922];

A_string.chrome.zeros.f = [0, 0, 1640, -1640];
A_string.chrome.zeros.R = [.9686, .7752, .8042, .8042];
A_string.chrome.poles.f = [622 -622 1640 -1640];
A_string.chrome.poles.R = [.9859, .9859, .9937, .9937];

D_string.brass.zeros.f = [0, 0, 2000, -2000];
D_string.brass.zeros.R = [.8727, .7269, .9687, .9687];
D_string.brass.poles.f = [1449 -1449 2000 -2000];
D_string.brass.poles.R = [.9930, .9930, .9948, .9948];

D_string.glass.zeros.f = [0, 0, 1920, -1920];
D_string.glass.zeros.R = [.9887, .0543, .9826, .9826];
D_string.glass.poles.f = [980, -980, 1920, -1920];
D_string.glass.poles.R = [.9720, .9720, .9948, .9948];

D_string.chrome.zeros.f = [0, 0, 2000, -2000];
D_string.chrome.zeros.R = [.9644, .6564, .9217, .9217];
D_string.chrome.poles.f = [859 -859 2000 -2000];
D_string.chrome.poles.R = [.9929, .9929, .9922, .9922];

%Now that we have the data entered we can generate the complex values and
%correspondingly the filter coefficients
E_string = zp2ba(E_string, Fs);
A_string = zp2ba(A_string, Fs);
D_string = zp2ba(D_string, Fs);

%Now lets generate the frequency responses to see how they compare to what
%the paper displays.
N = 4096;
figure;
freqz(E_string.glass.zeros.b, E_string.glass.poles.a, N);
[H, w] = freqz(E_string.glass.zeros.b, E_string.glass.poles.a, N);
H_dB = mag2db(abs(H/max(abs(H))));
semilogx(w/pi*Fs/2, H_dB);
title("String 6 - Glass");
% figure;
% freqz(E_string.glass.zeros.b, E_string.glass.poles.a, N, Fs);
% title("String 6 - Glass");
% figure;
% freqz(E_string.chrome.zeros.b, E_string.chrome.poles.a, N, Fs);
% title("String 6 - Chrome");