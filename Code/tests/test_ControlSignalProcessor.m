clear;

%Testing parameters - Slide at a constant rate from .25 to 1
stringParams = SystemParams.E_string_params;
n_w = stringParams.n_w;
f0 = stringParams.f0;
relativeLengthStart = .25;
relativeLengthStop = 1;
relativeLengthDistance = relativeLengthStop - relativeLengthStart;
numSamples = 1000;
slideVelocity = relativeLengthDistance/numSamples; %relative string length traveled per sample
L = relativeLengthStart:slideVelocity:relativeLengthStop-slideVelocity;

%Processing objects
controlSignalProcessor = ControlSignalProcessor(n_w, f0, L(1)-slideVelocity);

slide_velocity_up = zeros(1, numSamples);
f_c_up = zeros(1, numSamples);
tp_up = zeros(1, numSamples);
%Processing loop
for n = 1:numSamples
    [slide_velocity_up(n), f_c_up(n), tp_up(n)] = controlSignalProcessor.tick(L(n));
end

subplot(2, 1, 1)
plot(f_c_up, 'DisplayName', 'f_c');
hold on;
plot(slide_velocity_up, 'DisplayName', 'slide velocity');
plot(tp_up, 'DisplayName', 'trigger period');
hold off;
legend();
title('Upward Motion');

%Now lets slide back down the string
%Todo: Investigate where the noise in the second parametrization of L comes
%from
% L = relativeLengthStop-slideVelocity:-slideVelocity:relativeLengthStart;
L = relativeLengthStop:-slideVelocity:relativeLengthStart-slideVelocity;
f_c_down = zeros(1, numSamples);
slide_velocity_down = zeros(1, numSamples);
tp_down = zeros(1, numSamples);

% controlSignalProcessor = ControlSignalProcessor(n_w);
%Processing loop
for n = 1:numSamples
    [slide_velocity_down(n), f_c_down(n), tp_down(n)] = controlSignalProcessor.tick(L(n));
end

subplot(2, 1, 2);
plot(f_c_down, 'DisplayName', 'f_c');
hold on;
plot(slide_velocity_down, 'DisplayName', 'slide velocity');
plot(tp_down, 'DisplayName', 'trigger period');
hold off;
legend();
title('Downward Motion');