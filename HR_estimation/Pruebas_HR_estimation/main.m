%% VIDEO
clc,clear all
% path del video. El video debe estar en la misma carpeta que este
% archivo.m
file='C:\Users\juank\Desktop\MATLAB\HR_estimation\videoPC_10s_JCRuiz.mp4';
v = VideoReader(file);
% Se declara los objetos detectores de ojos, cara y nariz
% Si el algoritmo no identifica la parte de 70/1.la cara hay que cambiar valores
% de parametro MinSize
EyeDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig');  % minSize >= [11,45];
EyeDetector.MergeThreshold = 10;
EyeDetector.MinSize = [11,45];
MouthDetector = vision.CascadeObjectDetector('Mouth'); %min >= [15,25]
MouthDetector.MergeThreshold = 50;
MouthDetector.MinSize = [15,25];
NoseDetector = vision.CascadeObjectDetector('Nose'); % min>= [15,18]
NoseDetector.MergeThreshold = 50;
NoseDetector.MinSize = [15,18];
%Inicializacion de matriz de datos
x = zeros(v.NumberOfFrames,3);
%Matriz con coordenadas, ancho y alto de los cuadros recortados 
cropped_frames = zeros(v.NumberOfFrames,4);                                 
%% Reconocimiento parte inferior de cara
clc
tic
for i =1:v.NumberOfFrames
disp(i);
%Lectura del i-esimo frame
I = read(v,i);
%Identificacion del bounding box de los ojos
BBOX_eyes = step(EyeDetector,I);
%Se selecciona la 1era opcion correspondiente a los ojos, nariz y boca
if size(BBOX_eyes,1) == 0
    % Se toma el cuadro con la misma posicion y dimernsiones que el
    % anterior
    BBOX_eyes = step(EyeDetector,read(v,i-1));
end
BBOX_eyes = BBOX_eyes(1,:);    
BBOX_mouth = step(MouthDetector,I);
BBOX_mouth = BBOX_mouth(1,:);
BBOX_nose = step(NoseDetector,I);
BBOX_nose = BBOX_nose(1,:);
%Bounding box correspondiente a la ROI (parte inferior de la cara)
BBOX_final = [BBOX_eyes(1)+30,BBOX_nose(2), BBOX_eyes(3)-50,...            
    BBOX_nose(4)+BBOX_eyes(4)];
% Se guarda la informacion del cuadro bounding box seleccionado (para debugs)
cropped_frames(i,:) = BBOX_final;                                          
%--------------------------------------------------------------------------
% CODIGO PARA DEBUG UNICAMENTE: detecta las zonas seleccionadas
% imshow(I)
% hold on
% r =
% Rectangulos para identificar si las zonas identificadas son efecto las de
% los ojos, boca y nariz (para debugs)
% rectangle('Position',BBOX_eyes,'LineWidth',5,'LineStyle','-','EdgeColor','r');       
% r = rectangle('Position',BBOX_mouth,'LineWidth',5,'LineStyle','-','EdgeColor','g');
% r = rectangle('Position',BBOX_mouth,'LineWidth',5,'LineStyle','-','EdgeColor','b');
% r = rectangle('Position',BBOX_final,'LineWidth',5,'LineStyle','-','EdgeColor','k');
%--------------------------------------------------------------------------
%Recorte de la imagen en la ROI
Icr = imcrop(I,BBOX_final);                                                
% Para observar la imagen recortada en cada iteracion descomentar la
% siguiente linea
% imshow(Icr)
%Se calcula el promedio espacial
avg = squeeze(mean(mean(Icr)));                                            
%Se guarda la informacion en la matriz x (las columnas 1,2,3 corresponden a los canales R,G y B de la imagen)
x(i,:) = avg' ;                                                            
end                                                                        
toc

%% PREPROCESAMIENTO 1: interpolacion y tratamiento de posibles valores nan
t = linspace(0,v.Duration,v.NumberOfFrames);
fs = v.FrameRate
n = v.NumberOfFrames
f = [0:n-1]*fs/n;
x_new = remove_OL_NAN(x,t);
sum(isnan(x_new))
sum(isoutlier(x_new))
figure,plot(x_new)
%% PREPROCESAMIENTO 2 - Pre-whitening
%[xf,W] = prewhiten(x_new);
[xf,W,mu_x] = prewhiten2(x_new);
figure,plot(xf)
%% PREPROCESAMIENTO 3 - Normalizacion
% Normalización de los datos si NO hubo datos interpolados
xf = (xf - mean(xf))./std(xf);                                           
%figure,plot(xf)
%% PREPROCESAMIENTO 4 - interpolando de nuevo los outliers que salieron despues del prewhitenning 
xf = remove_OL_NAN(xf,t);
sum(isnan(xf))
sum(isoutlier(xf))
%figure,plot(xf_new)
%% Filtrado de la señal
x_filt = bandpass(xf,[0.8,140/60],fs);
%% Graficas de la señal
figure,plot(1:n,x_filt(:,1),'r');
xlabel("Frames")
ylabel("Pixel mean value")
grid on
title("Raw trace of signal from red channel")
%--------------------------------------------------------------------------
figure,plot(1:n,x_filt(:,2),'g');
xlabel("Frames")
ylabel("Pixel mean value")
grid on
title("Raw trace of signal from green channel")
%--------------------------------------------------------------------------
figure,plot(1:n,x_filt(:,3));
xlabel("Frames")
ylabel("Pixel mean value")
grid on
title("Raw trace of signal from blue channel")
hold off

%% ICA para la señal filtrada
q = 3;
Mdl = rica(x_filt,q,"NonGaussianityIndicator",ones(q,1),"Standardize",true);
S = transform(Mdl,x_filt);
%% Graficas de las señales fuente
figure
plot(t,S(:,1));
grid on;
xlabel('Tiempo [s]')
ylabel('intensidad de la señal')
title("Señal fuente 1")

figure
plot(t,S(:,2));
grid on;
xlabel('Tiempo [s]')
ylabel('intensidad de la señal')
title("Señal fuente 2")

figure
plot(t,S(:,3));
grid on;
xlabel('Tiempo [s]')
ylabel('intensidad de la señal')
title("Señal fuente 3")

%% Calculo de la PSD para cada señal fuente
[Pxx,F] = pwelch(S(:,1),[],[],[],fs,'psd');
Pxx = Pxx*2*pi; % converting to normal PSD and not power per rad per sample
figure, plot(F,Pxx)
xlabel('Frequency [Hz]')
ylabel('Amplitude dB')
grid on
xlim([0 max(F)])
title('PSD for the source signal 1')
hold on



[Pxx2,F2] = pwelch(S(:,2),[],[],[],fs,'psd');
Pxx2 = Pxx2*2*pi; % converting to normal PSD and not power per rad per sample
plot(F2,Pxx2)
xlabel('Frequency [Hz]')
ylabel('Amplitude dB')
grid on
xlim([0 max(F2)])
title('PSD for the source signal 2')
hold on



[Pxx3,F3] = pwelch(S(:,3),[],[],[],fs,'psd');
Pxx3 = Pxx3*2*pi; % converting to normal PSD and not power per rad per sample
plot(F3,Pxx3)
xlabel('Frequency [Hz]')
ylabel('Amplitude dB')
grid on
xlim([0 max(F3)])
title('PSD for the source signal 3')

legend("PSD de señal fuente 1","PSD de señal fuente 2","PSD de señal fuente 3")
%% Frecuencias en las cuales se encuentea el máximo en cada PSD
i1 = find(Pxx == max(Pxx));
i2 = find(Pxx2 == max(Pxx2));
i3 = find(Pxx3 == max(Pxx3));
peak_freqs = [F(i1),F(i2),F(i3)]
HRs = 60*peak_freqs
% Estimacion final de la frecuencia cardiaca con el promedio de los 3
% maximos
mean(HRs)
