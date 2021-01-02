% Ejercicio 1
% a)
%t = -10:0.01:10;
syms t;
T = 5; % Periodo
x = a*rectangularPulse(-T1/2,T1/2,t);
%x = x+ a*rectangularPulse(1-T1/2,1+T1/2,t);

for i = 1:3
    x = x + a*rectangularPulse(i*T-T1/2,i*T+T1/2,t);
end

% Frecuencia angilar:
w0 = 2*pi/T;

%fplot(t,x,[-10,10]);
k = -100:100;
%coeficientes espectrales

% % cambiando x(t) a funcion con @
x = @(t) a;
c = @(t) x(t).*exp(-j.*w0.*k.*t);
coefs = (1./T).*integral(c,-T./2,T./2);

% pulse(t);
% 
% function res = pulse(t)
%     a = 3;
%     T1 = 2;
%     if abs(t) < T1
%         res = a;
%     else
%         res = 0;
%     end
% end

