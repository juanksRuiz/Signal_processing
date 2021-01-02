L = 10;
N = 1000;
fs = L/N;
t = 0:fs:L;;
x = sin(t);

Xjw = (myFFT(x));

Fmax = 2*pi;
w = linspace(0,Fmax,length(Xjw));
plot(w,abs(Xjw));
grid on
xlabel("Frecuencia [Hz]")
ylabel("Magnitud")

