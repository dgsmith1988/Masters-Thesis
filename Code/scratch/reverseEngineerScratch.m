%Understanding the pitch scaling aspects related to the string specific
%relative frequency signal

%pixel data coming from the IR camera
x = 62.5:.1:250;
step1 = x - 62.5;
step2 = step1/187.5;
step3 = step2 - 1;
step4 = (-1.37844)*step3;
y = step4 + 1;