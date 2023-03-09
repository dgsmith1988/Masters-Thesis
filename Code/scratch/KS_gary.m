% Write a Matlab script that implements the Karplus-Strong
% algorithm. The fundamental frequency, time duration, and blend
% factor of the computation should be specified at the top of the
% script. The computation should allow a fractional delayline
% length using allpass interpolation. [10 pts]

fs = 48000;  % sample rate
f0 = 375;    % fundamental frequency
t = 3.0;     % time duration
B = 1.0;     % blend factor (between 0 - 1)
A = 1;     % amplitude of binary initialization
S = 1.0;     % stretch factor (>=1)

N = round( t * fs );
delay = fs / f0;     % # of samples for delay line
delay = delay - 0.5; % subtract phase delay of averaging filter
D = floor( delay );
delta = delay - D;
if ( delta < 0.3)
    delta = delta + 1;
    D = D - 1;
end
apc = ( 1 - delta ) / ( 1 + delta );  % allpass coefficient

% Initialize delayline with random binary values
% dl = A * round( rand( 1, D ) );
% % %dl = A * ones( 1, D );
% dl( dl == 0 ) = -A;
dl = pinknoise(1, D);

dl = dl - mean(dl);
dl = dl / max(abs(dl));

y = zeros( 1, N );
ptr = 1;
x = 0;
xm1ave = 0; % x[n-1] for first-order averaging filter
xm1ap = 0;  % x[n-1] for first order all-pass
ym1ap = 0;  % y[n-1] for first order all-pass
bfactors = rand( 1, N );
sfactors = rand( 1, N );

for n = 1:N
    y(n) = dl( ptr );
    x = y(n);
    
    %   if sfactors(n) < 1/S
    y(n) = 0.5 * ( x + xm1ave );
    %   else
    %     y(n) = x;
    %   end
    
    xm1ave = x;
    
    %   if bfactors(n) > B
    %       y(n) = -y(n);
    %   end
    
    x = y(n);
%     y(n) = apc * ( x - ym1ap) + xm1ap;
%     xm1ap = x;
%     ym1ap = y(n);
    
    dl( ptr ) = y(n);
    
    ptr = ptr + 1;
    if ( ptr > D )
        ptr = 1;
    end
end

% soundsc( y, fs );

%Spectrogram analysis parameters
windowLength = 12*10^-3*fs; %12 ms window
window = hamming(windowLength);
overlap = .75*windowLength;
N_fft = 4096;

figure;
spectrogram(y, window, overlap, N_fft, fs, "yaxis");
title('Gary-KS Spectrogram');