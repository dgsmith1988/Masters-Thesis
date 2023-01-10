function complexValues = linearToComplex(f, R, Fs)
%LINEARTOCOMPLEX Takes the pole/zero specifications from CMJ paper and
%converts them from linear frequencies into complex values

%First convert the linear frequency into an angular frequency/position
theta = (2*pi)*f/Fs;
complexValues = R.*exp(1i*theta);
end