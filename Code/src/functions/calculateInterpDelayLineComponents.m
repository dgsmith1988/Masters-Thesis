function [M, D_min, D, d] = calculateInterpDelayLineComponents(N, delay)
%Inputs:
%   delay = delay in samples which the line is to compute
%   N = lagrange interpolation order
%Outputs:
%   M = Length of integer delay line preceeding Lagrange interpolation
%       filter
%   D_min = minimum delay necessary for optimal interpolation
%   D = total delay implemented by Largange interpolation
%   d = fractional component of delay

%TODO: Double check this D_min calculation for even order interp
D_min = (N-1)/2;
M = floor(delay - D_min);
d = delay - floor(delay);
D = D_min + d;
end