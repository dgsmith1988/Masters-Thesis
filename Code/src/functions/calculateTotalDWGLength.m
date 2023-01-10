function DWGLength = calculateTotalDWGLength(pitch_f0, Fs)
%Calculate the total DWG length in samples based on the
%specified fundamental frequency of the desired pitch and the specified
%sampling rate.

DWGLength = Fs ./ pitch_f0;
end