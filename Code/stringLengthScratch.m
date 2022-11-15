% https://www.stewmac.com/video-and-ideas/online-resources/learn-about-guitar-and-instrument-fretting-and-fretwork/scale-length-explained/

%This script was an experiment to determine the relationship between a fret
%location and the correspondings scaling of the open-string's fundamental
%frequency

%String parameters
scaleLength_in = 25.5;  %this represents 
inch2Meter = 127/5000;
stringLength_meters = 2*scaleLength_in*inch2Meter;
relativeStringLengthMax = 1; %corresponds to an open string and the full length so the fundamental is heard
relativeStringLengthMin = .25; %corresponds to the 24th fret and 4*f0 of the open string

%Selected pitch parameters
fretNumber = 0:12;
halfStepRatio = 2^(1/12)*ones(size(fretNumber)); %keep things in terms of equal temprement for now
noteToOpenRatio = halfStepRatio.^fretNumber;
desiredRelativeLength = 1./noteToOpenRatio
fretLocations = (1-desiredRelativeLength)*scaleLength_in

%note frequencies
f0_Hz = SystemParams.E_string_params.f0
notes_Hz = f0_Hz ./ desiredRelativeLength