positiveInstances = ojosLabels(:,1:2);
imDir = fullfile(matlabroot,'toolbox','vision','visiondata',...
    'ojosLabels');
% Buscar em path de root de matlab si quedo el folder
addpath(imDir);

% specify folder for negative images
negativeFolder = fullfile(matlabroot,'toolbox','vision','visiondata',...
    'No_Ojos');

% Create an imageDataStore containing negative data
negativeImages = imageDatastore(negativeFolder)