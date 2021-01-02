function Xf = myFFT(x)
% x:    datos iniciales
X = x;
v =  ceil(log2(length(x)));
% primero: hacer que X tenga 2^v datos, con 2^v superior mas cercano
if mod(log2(length(x)),1)~= 0
    X = X-mean(X);
    c = 2^v - length(X);
    X = [X,zeros(1,c)];
end
N = length(X);
W = exp(-2*pi*1i/N);
if rem(N,2) == 0
    k = (0:(N/2)-1);
    W_N = W.^k;
    pares = myFFT(X(1:2:end));
    impares = W_N.*myFFT(X(2:2:end));
    Xf = [pares + impares, pares - impares];
else
    p = 0:(N-1);
    k= p';
    Xf = (W.^(k*p))*X;
end