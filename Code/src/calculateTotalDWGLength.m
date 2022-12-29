function DWGLength = calculateTotalDWGLength(pitch_f0)
%Calculate the total DWG length in samples based on the
%specified fundamental frequency of the desired pitch
DWGLength = SystemParams.audioRate ./ pitch_f0;
end