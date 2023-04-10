clear all;

openString_f0 = SystemParams.e_string_params.f0;
fretNumbers = [0, 18, 19, 20];
L = fretNumberToRelativeLength(fretNumbers);
pitch_f0 = calculatePitchF0(L, openString_f0)