function stringStruct = zp2ba(stringStruct, Fs)
%ZP2BA Convert the stringStruct containing data specified in the CMJ format
%to new filter coefficient values to make things realizable
%TODO: This function signature works for now but investigate a more pass by
%reference type of approach
slideTypes = fields(stringStruct);
for k = 1:numel(slideTypes)
    complexZeros = linearToComplex(stringStruct.(slideTypes{k}).zeros.f, stringStruct.(slideTypes{k}).zeros.R, Fs);
    complexPoles = linearToComplex(stringStruct.(slideTypes{k}).zeros.f, stringStruct.(slideTypes{k}).poles.R, Fs);
    [b, a] = zp2tf(complexZeros', complexPoles', k);
    stringStruct.(slideTypes{k}).zeros.b = b;
    stringStruct.(slideTypes{k}).poles.a = a;
end
end