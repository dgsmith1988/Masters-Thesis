function [p_int, p_frac_delta] = calculateDelayLineLengths(DWGLength, loopFilterDelay, fractionalDelayInteger)
%Calculate the parameters for the delay lines based on the
%various filter delays in the feedback loop. All lengths are in
%samples
%
%Inputs:
% DWGLength = total length of the digital wave guide
% loopFilterDleay = phase delay associated with loop filter
% fractionalDelayInteger = integer component associated with
%   fractional delay implementation (i.e. 2 if delay = 2.5)
%
%Outputs:
% p_int = integer delay line length
% p_frac_delta = fractional component of fractional delay

p_int = floor(DWGLength - loopFilterDelay - fractionalDelayInteger);
p_frac_delta = DWGLength - p_int - loopFilterDelay - fractionalDelayInteger;
end