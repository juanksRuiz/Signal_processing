%Face detection with Viola-Jones algorithm
file = 'C:\Users\juank\Desktop\MATLAB\Signal_Processing\Proyecto_final\caraRuiz_30s.mp4';
v = VideoReader(file);

% Get FaceDetector Object
FaceDetector = vision.CascadeObjectDetector();
% Get EyeDetector Object
EyeDetector = vision.CascadeObjectDetector('EyePairBig');


X1 = zeros(v.NumberOfFrames,3); % para cuadro 1
% Vector para tiempos de extraccion de frames
e = zeros(1,v.NumberOfFrames);
% Vector para tiempos de calculo de medias
f = zeros(1,v.NumberOfFrames);

im1 = read(v,1); 
cropped_frames = zeros(v.NumberOfFrames,4);
%% Con CenteredForeheadBBOX (cuadro pequeño)
for i = 1:v.NumberOfFrames
    %r = rectangle('Position',[20,100,600,50],'LineWidth',5,'LineStyle','-','EdgeColor','r');
    tic
    disp(i)
    img = read(v,i);
    BBOX_face = step(FaceDetector,img);
    size(BBOX_face);
    BBOX_eyes = step(EyeDetector,img);
    if size(BBOX_eyes,1) == 2
        BBOX_eyes = BBOX_eyes(2,:);
    else
        BBOX_eyes = BBOX_eyes(1,:);
    end
    
    smallBBOX_FH = CenteredForeheadBBOX(BBOX_face, BBOX_eyes);      %
%     imshow(img);
%     hold on;
%     r_cara = rectangle('Position',BBOX_face,'LineWidth',5,'LineStyle','-','EdgeColor','r');
%     r_ojos = rectangle('Position',BBOX_eyes,'LineWidth',5,'LineStyle','-','EdgeColor','b');
%     r_final = rectangle('Position',smallBBOX_FH,'LineWidth',5,'LineStyle','-','EdgeColor','g');
    cropped_frames(i,:) = smallBBOX_FH;
%    pause(2)
    e(i) = toc;
    
    tic
    cropped_img = imcrop(img,smallBBOX_FH);
    n = size(cropped_img,1);
    m = size(cropped_img,2);
    %avg = squeeze(mean(mean(cropped_img)));
    avg = zeros(1,3);
    avg(1,1) = (1/(n*m))*(ones(1,n)*double(cropped_img(:,:,1))*ones(m,1)); % Calculo del promedio espacial para los canales RGB 
    avg(1,2) = (1/(n*m))*(ones(1,n)*double(cropped_img(:,:,2))*ones(m,1)); %de la imagen recortada
    avg(1,3) = (1/(n*m))*(ones(1,n)*double(cropped_img(:,:,3))*ones(m,1));
    X1(i,:) = avg ;
    f(i) = toc;
end

%% PREPROCESAMIENTO 1
%interpolación de valores atípicos y nan
outliers = [373];                                                          % indices de valores atipicos
X1(outliers,:) = [nan,nan,nan];
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
X1new = (X1new - mean(X1new))./std(X1new);                                 % Normalización de los datos
dlmwrite('datosRGB_JCRuiz.txt',X1new,'delimiter','\t','newline','pc')      % Escribimos los resultados en un archivo que se tranaja
                                                                           % en el MATLAB online
