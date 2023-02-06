clear all;
close all;

x1 = -1:.25:1;
x2 = abs(x1);

M = 3;
b = 1/M * ones(1, M);
a = 1;

y1 = filter(b, a, x1);
y2 = filter(b, a, x2);

figure;
subplot(2, 1, 1);
stem(x1, "DisplayName", "x1");
hold on;
stem(y1, "DisplayName", "y1");
hold off;
legend();
subplot(2, 1, 2);
stem(x2, "DisplayName", "x2");
hold on;
stem(y2, "DisplayName", "y2");
hold off;
legend();