function batchdaysigram
%BATCHREPORT Summary of this function goes here
%   Detailed explanation goes here

Paths = initpaths;

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
circadianDir = fullfile(parentDir,'circadian');

addpath(circadianDir);
import('reports.daysigram.*');

% Find files in folder
listing = dir([Paths.editedData,filesep,'*.mat']);
nFiles = numel(listing);

[idxSubject,idxDimesimeter,idxBlanket,idxStartTime,idxEndTime,~] = importindex(Paths.index);

for i1 = 1:nFiles
    filePath = fullfile(Paths.editedData,listing(i1).name);
    S = load(filePath);
    subject = S.subject;
    dimesimeter = S.dimesimeter;
    absTime = S.absTime;
    relTime = S.relTime;
    epoch = S.epoch;
    light = S.light;
    activity = S.activity;
    masks = S.masks;
    
    idx1 = strcmpi(subject,idxSubject);
    idx2 = idxDimesimeter == dimesimeter;
    idxIdx = idx1 & idx2;
    
    blanket = idxBlanket(idxIdx);
%     startTime = idxStartTime(idxIdx);
%     endTime = idxEndTime(idxIdx);
%     
    timeArray = absTime.localDateNum;
%     idx = timeArray >= floor(startTime) & timeArray < ceil(endTime)+1;
    
    temp = timeArray(masks.observation);
    startDate = floor(temp(1));
    endDate = ceil(temp(end));
    idx = timeArray >= startDate & timeArray < endDate;
    
    timeArray = timeArray(idx);
    csArray = light.cs(idx);
    activityArray = activity(idx);
    
    masks.observation = masks.observation(idx);
    masks.compliance = masks.compliance(idx);
    masks.bed = masks.bed(idx);
    
    sheetTitle = {'Incubator Illuminance Blanket Study';...
        ['Subject: ',subject,'  Dimesimeter: ',num2str(dimesimeter),'  Blanket: ',num2str(blanket)]};
    
    daysigram(1,sheetTitle,timeArray,masks,activityArray,csArray,'cs',[0 1],7,Paths.plots,subject)
    % Clear figures
    clf;

end

close all;

end

