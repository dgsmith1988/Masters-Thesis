%Test functionality of the noise burst trigger chain of objects
clear;

%System parameters
pulseLength_ms = SystemParams.E_string_params.pulseLength;
%n_W = SystemParams.E_string_params.windsParam;
period_mS = 2*pulseLength_ms;
duration_mS = 5*period_mS;
numSamples = duration_mS*10^-3*SystemParams.audioRate;

%determine the f_c signal based on the parameters which have been specified
%here

%Processing objects
noisePulse = NoisePulse2(pulseLength_ms, SystemParams.E_string_params.decayRate);
metro = Metro(period_mS, noisePulse);
noiseBurstTrigger = NoiseBurstTrigger(metro);