function batchcompositereport
%BATCHREPORT Summary of this function goes here
%   Detailed explanation goes here

Paths = initpaths;

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
circadianDir = fullfile(parentDir,'circadian');

addpath(circadianDir);
import('reports.composite.*');

% Find files in folder
listing = dir([Paths.editedData,filesep,'*.mat']);
nFiles = numel(listing);

% Preallocate Output
Output = struct(...
    'subject',                  {[]},...
    'phasorMagnitude',          {[]},...
    'phasorAngleHrs',           {[]},...
    'interdailyStability',      {[]},...
    'intradailyVariability',    {[]},...
    'arithmeticMeanActivity',   {[]},...
    'arithmeticMeanCS',         {[]},...
    'arithmeticMeanIlluminance',{[]});

figTitle = 'Incubator Illuminance Blanket Study';


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
    
    Phasor = phasor.prep(absTime,epoch,light,activity,masks);

    Actigraphy = struct;
    activity2 = activity;
    activity2(~masks.observation) = [];
    [Actigraphy.interdailyStability,Actigraphy.intradailyVariability] = isiv.isiv(activity2,epoch);

    Miller = struct('time',[],'cs',[],'activity',[]);
    [         ~,Miller.cs] = millerize.millerize(relTime,light.cs,masks);
    [Miller.time,Miller.activity] = millerize.millerize(relTime,activity,masks);
    
    Average = daysimeteraverages(light,activity,masks);
    reports.composite.compositeReport(Paths.plots,Phasor,Actigraphy,Average,Miller,subject,num2str(dimesimeter),figTitle)
    
    % Clear figures
    clf;
    
    Output(i1,1).subject = subject;
    Output(i1,1).phasorMagnitude = Phasor.magnitude;
    Output(i1,1).phasorAngleHrs = Phasor.angle.hours;
    Output(i1,1).interdailyStability = Actigraphy.interdailyStability;
    Output(i1,1).intradailyVariability = Actigraphy.intradailyVariability;
    Output(i1,1).arithmeticMeanActivity = Average.activity.arithmeticMean;
    Output(i1,1).arithmeticMeanCS = Average.cs.arithmeticMean;
    Output(i1,1).arithmeticMeanIlluminance = Average.illuminance.arithmeticMean;
end

close all;

% Save summarized results to Excel file
OutputDataset = struct2dataset(Output);
outputCell = dataset2cell(OutputDataset);
xlsPath = fullfile(Paths.analysis,['!summary_',datestr(now,'yyyy-mm-dd_HH-MM-SS'),'.xlsx']);
xlswrite(xlsPath,outputCell);

end

