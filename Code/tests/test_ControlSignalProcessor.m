clear;

%Testing parameters
n_w = SystemParams.E_string_params.windsParam;
relativeLengthStart = .25;
relativeLengthStop = 1;
relativeLengthDistance = relativeLengthStop - relativeLengthStart;
numSamples = 1000;
slideVelocity = relativeLengthDistance/numSamples; %relative string length traveled per sample
L = relativeLengthStart:slideVelocity:relativeLengthStop-slideVelocity;

%Processing objects
controlSignalProcessor = ControlSignalProcessor(n_w);

f_c_up = zeros(1, numSamples);
%Processing loop
for n = 1:numSamples
    f_c_up(n) = controlSignalProcessor.tick(L(n));
end

subplot(2, 1, 1)
plot(f_c_up);

%Now lets slide back down the string
%Todo: Investigate where the noise in the second parametrization of L comes
%from
% L = relativeLengthStop-slideVelocity:-slideVelocity:relativeLengthStart;
L = relativeLengthStop:-slideVelocity:relativeLengthStart-slideVelocity;
f_c_down = zeros(1, numSamples);
% controlSignalProcessor = ControlSignalProcessor(n_w);
%Processing loop
for n = 1:numSamples
    f_c_down(n) = controlSignalProcessor.tick(L(n));
end

subplot(2, 1, 2);
plot(f_c_down);