function batchcrop
%BATCHCROP Summary of this function goes here
%   Detailed explanation goes here

Paths = initpaths;

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
circadianDir = fullfile(parentDir,'circadian');

addpath(circadianDir);
import('dimesimeter.*');

% Find dimesimeter header files in folder
FilterSpec = [Paths.originalData,filesep,'*header.txt'];
[fileName,pathName,filterIndex] = uigetfile(FilterSpec,'MultiSelect','on');
if ischar(fileName)
    fileName = {fileName};
end
filePath = fullfile(pathName,fileName');
nFile = numel(filePath);

utcOffsetHours = -4; % EDT

% Names of variables to save to file.
variables = {'subject','dimesimeter','absTime','relTime','epoch',...
    'light','activity','masks'};

for iFile = 1:nFile
    thisFilePath = filePath{iFile};
    [dimesimeter,subject] = parsefilename(thisFilePath);
    [absTime,relTime,epoch,light,activity] = convertheader(thisFilePath,dimesimeter,utcOffsetHours);
       
    masks = cropping(subject,absTime.localDateNum,light.cs,activity);
    
    saveName = ['subject',subject,'_dimesimeter',num2str(dimesimeter),'.mat'];
    savePath = fullfile(Paths.editedData,saveName);
    
    save(savePath,variables{:});
end

close all;

end

