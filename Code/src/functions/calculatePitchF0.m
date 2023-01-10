function pitch_f0 = calculatePitchF0(L_n, openString_f0)
%Calculate the fundamental frequency of the produced pitch
%based on the open-string fundamental and relative string
%length
pitch_f0 = openString_f0 ./ L_n;
end