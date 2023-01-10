function L_n = calculateLFromPitchF0(pitch_f0, openString_f0)
%Calculate the relative string length need to produce a pitch at the
%specified f0 based on the string's open f0.

L_n = openString_f0 ./ pitch_f0;
end