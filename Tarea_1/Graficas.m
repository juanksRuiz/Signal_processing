%% FALTA GRAFICA DE SINC
%%Constantes
T = 2*pi;
w = 2*pi/T;
T1 = pi; %T1 < T
a = 1;
k = -10:10;
j = complex(0,1);

%%Funcion del puso rectangular
F = @(k) (2*a*T1)*sinc(w.*k.*T1);
f = @(k) abs(F(k));
%Magnitud de coefs
stem(k,f(k))
%xlabel("w")
%ylabel("|ak|")
%fase: 
ph1 = @(k) atan(imag(F(k))./real(F(k)));

stem(k,ph1(k));


%% Funcion de onda triangular
g = @(k) ((-4*a)./(T.*j.*w.*k)).*(exp(j.*w.*k.*(T/2)));
h = @(k) ((8.*a)./(T.^2)).*((1 - exp(j.*w.*k.*(T/2)))./(w.^2.*k.^2));
p = @(k) ((-2*a)./(T)).*((1 - exp(j.*w.*k.*(T/2)))./(j.*w.*k));
F = @(k) abs(g(k) + h(k) + p(k));
%%Graficación  
%stem(k,F(k));

% fase
final = @(k) g(k)+h(k) + p(k);
ph2 = @(k) atan(imag(final(k))./real(final(k)));

stem(k,ph2(k));

%% Funcion diente de sierra
g2 = @(k) (-(exp(-j.*w.*k.*T/2))*T)./(2.*w.*j.*k);
h2 = @(k) -(exp(j.*w.*k.*T/2))./(2.*w.*j.*k);
p2 = @(k) exp(-j.*w.*k.*T/2)./(w.^2.*k.^2);
q2 = @(k) -exp(j.*w.*k.*T/2)./(w.^2.*k.^2);

F2 = @(k) abs(g2(k)+h2(k)+p2(k)+q2(k));


%Grafica
%stem(k,F2(k));

% fase
final2 = @(k)g2(k)+h2(k)+p2(k)+q2(k);
ph3 = @(k) atan(imag(final2(k))./real(final2(k)));

stem(k,ph3(k));

%% Funcion Delta de Dirac
F3 = @(k) 1/T;

%stem(k,(1/T)*ones(1,length(k)));
%fase
stem(k,zeros(1,length(k)))

%% Funcion constante
g3 = @(k) (a/T).*(exp(j.*w.*k.*T/2)-exp(-j.*w.*k.*T/2))./(j.*w.*k);

F3 = @(k) abs(g3(k));

%stem(k,F3(k));

%fase
ph4 = @(k) atan(imag(g3(k))./real(g3(k)));

stem(k,ph4(k));

%==========================================================================
%% TRANSFORMADA DE FOURIER
% A rectangular pulse, with amplitude a ? R, and width T1 ? R. -- PREGUNTAR
F4 = @(t) abs(a*T*sinc(pi*w*t));

%fplot(F4,[-5,5])
%fase

final5 = @(t) (a.*T.*sinc(pi.*w.*t));

ph5 = @(t) atan(imag(final5(t))./real(final5(t)));
fplot(ph5,[-5,5]);


%% SINC
%% Delta de Dirac;
t = linspace(-5,5,100);
%plot(t, ones(1,length(t)));

%fase
%plot(t,zeros(1,length(t)))

%% Funcion sign(t)
F5 = @(t) abs(2/(j*w));

plot(t,F5(t)*ones(1,length(t)));

%Fase
final6 = @(t) 2./(j*w);
ph7 = @(t) atan(imag(final6(t))./real(final6(t)));
plot(t,ph7(t)*ones(1,length(t)));
