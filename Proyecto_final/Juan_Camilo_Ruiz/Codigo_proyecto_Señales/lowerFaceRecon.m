clc, clear
%% VIDEO
% path del video. El video debe estar en la misma carpeta que este
% archivo.m
file='C:\Users\juank\Desktop\MATLAB\Signal_Processing\Proyecto_final\Juan_Camilo_Ruiz\JCR_fondoplano.mp4';
v = VideoReader(file);
% Se declara los objetos detectores de ojos, cara y nariz
% Si el algoritmo no reconoce la parte de la cara seleccionada (en la
% siguiente seccion) hay que cambiar valores del parámtetro MinSize
EyeDetector = vision.CascadeObjectDetector('ClassificationModel','EyePairBig','MinSize',[50,50]);  % minSize >= [11,45];
MouthDetector = vision.CascadeObjectDetector('ClassificationModel','Mouth','MinSize',[100,30]); %min >= [15,25]
NoseDetector = vision.CascadeObjectDetector('ClassificationModel','Nose','MinSize',[50,30]); % min>= [15,18]

X1 = zeros(v.NumberOfFrames,3);                                             %Inicializacion de matriz de datos
cropped_frames = zeros(v.NumberOfFrames,4);                                 %Matriz con coordenadas, ancho y alto de los cuadros recortados 
%% Reconocimiento parte inferior de cara
clc
tic
for i =1:v.NumberOfFrames
disp(i);                                                                    
I = read(v,i);                                                              %Lectura del i-esimo frame
BBOX_eyes = step(EyeDetector,I);                                            %Identificacion del bounding box de los ojos
BBOX_eyes = BBOX_eyes(1,:);                                                 %Se selecciona la 1era opcion correspondiente a los ojos, nariz y boca    
BBOX_mouth = step(MouthDetector,I);
BBOX_mouth = BBOX_mouth(1,:);
BBOX_nose = step(NoseDetector,I);
BBOX_nose = BBOX_nose(1,:);
BBOX_final = [BBOX_eyes(1)+30,BBOX_nose(2), BBOX_eyes(3)-50,...             %Bounding box correspondiente a la ROI (parte inferior de la cara)
    BBOX_nose(4)+BBOX_eyes(4)];
cropped_frames(i,:) = BBOX_final;                                           % Se guarda la informacion del cuadro bounding box seleccionado (para debugs)

% imshow(I)
% hold on
% r =
% Rectangulos para identificar si las zonas identificadas son efecto las de
% los ojos, boca y nariz (para debugs)
% rectangle('Position',BBOX_eyes,'LineWidth',5,'LineStyle','-','EdgeColor','r');       
% r = rectangle('Position',BBOX_mouth,'LineWidth',5,'LineStyle','-','EdgeColor','g');
% r = rectangle('Position',BBOX_mouth,'LineWidth',5,'LineStyle','-','EdgeColor','b');
% r = rectangle('Position',BBOX_final,'LineWidth',5,'LineStyle','-','EdgeColor','k');

Icr = imcrop(I,BBOX_final);                                                 %Recorte de la imagen en la ROI
imshow(Icr)
[n,m] = size(Icr);
avg = squeeze(mean(mean(Icr)));                                             %Se calcula el promedio espacial
X1(i,:) = avg' ;                                                            %Se guarda la informacion en la matriz X1
end                                                                         %(las columnas 1,2,3 corresponden a los canales R,G y B de la imagen)
toc

%% PREPROCESAMIENTO (Necesiario sólo si las señales tienen nan o valores atípicos)
% %interpolación de valores atípicos y nan
% Se pudo usar la funcion isoutlier pero a veces no reconocía bien los
% valores atípicos
outliers = [1:4]; % aqui se indica los indices de los valores atipicos, ingresados a mano
% indices de valores atipicos
for i = 1:length(outliers)
    size(X1(outliers(i),:));
    size([nan,nan,nan]);
    X1(outliers(i),:) = [nan,nan,nan];
end
% indices de valores nan son el frame NaN
xNaN = find(isnan(X1(:,1)));
x = find(isnan(X1(:,1))==0);
yr = X1(x,1);
yg = X1(x,2);
yb = X1(x,3);
yNaN_R = spline(x,yr,xNaN);                                                % interpolación con splines cúbicos
yNaN_G = spline(x,yg,xNaN);
yNaN_B = spline(x,yb,xNaN);
X1new = X1;
for i = 1:length(xNaN)
    X1new(xNaN(i),:) = [yNaN_R(i),yNaN_G(i),yNaN_B(i)];
end

%% PREPROCESAMIENTO 2
X1new = (X1new - mean(X1new))./std(X1new);                                 % Normalización de los datos si hubo datos interpolados
% X1 = (X1 - mean(X1))./std(X1);                                           % Normalización de los datos si NO hubo datos interpolados

%%
dlmwrite('datosRGB_JCRuiz_inf.txt',X1new,'delimiter','\t','newline','pc'   % Escribimos los resultados en un archivo que se trabaja en matlab online
% dlmwrite('datosRGB_JCRuiz_inf.txt',X1,'delimiter','\t','newline','pc')
 
