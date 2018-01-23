close all
clear
clc

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
    'subject',               {[]},...
    'phasorMagnitude',       {[]},...
    'phasorAngleHrs',        {[]},...
    'interdailyStability',   {[]},...
    'intradailyVariability', {[]},...
    'averageActivity',       {[]},...
    'averageCS',             {[]},...
    'averageIlluminance',    {[]});

figTitle = 'Incubator Illuminance Blanket Study';

[hFigure,width,height,units] = initfig(1,'on');

load('millerNurses.mat');
defaultFontSize = get(0,'DefaultAxesFontSize');
set(0,'DefaultAxesFontSize',5);


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
    
    cs = light.cs(masks.observation);
    lux = light.illuminance(masks.observation);
    ai = activity(masks.observation);

%     Average = reports.composite.daysimeteraverages(cs,lux,ai);
    Average = reports.composite.daysimeteraverages(light,activity,masks);
    
    hMiller = subplot(3,3,i1);
%     hAxes = millerWithOverlay(Miller.time,'Circadian Stimulus (CS)',Miller.cs,'Activity Index (AI)',Miller.activity,'Typical CS Exposure of Adult',MillerNurses.cs,hMiller);
    hAxes = plots.miller(Miller.time,'Circadian Stimulus (CS)',Miller.cs,'Activity Index (AI)',Miller.activity,hMiller);
    if i1 == 1
%         XLim = hAxes(1).XLim;
%         YLim = hAxes(1).YLim;
%         
%         x1 = 3/abs(XLim(2) - XLim(1));
%         x2 = 1.167/abs(XLim(2) - XLim(1));
%         
%         y1 = 0.5/abs(YLim(2) - YLim(1));
%         y2 = 0.3219/abs(YLim(2) - YLim(1));
%         
%         annotation('textarrow',[x1,x2],[y1,y2],'String','Ex.: Caregiver Interaction');
        hText = text(1.167,0.3219,' \leftarrow Ex.: Caregiver Interaction');
        hText.FontSize = 5;
    end
    
    title(hMiller,subject);
    
%     reports.composite.compositeReport(Paths.plots,Phasor,Actigraphy,Average,Miller,subject,num2str(dimesimeter),figTitle)
    
%     % Clear figures
%     clf;
    
%     Output(i1,1).subject = subject;
%     Output(i1,1).phasorMagnitude = Phasor.magnitude;
%     Output(i1,1).phasorAngleHrs = Phasor.angle.hours;
%     Output(i1,1).interdailyStability = Actigraphy.interdailyStability;
%     Output(i1,1).intradailyVariability = Actigraphy.intradailyVariability;
%     Output(i1,1).averageActivity = Average.activity;
%     Output(i1,1).averageCS = Average.cs;
%     Output(i1,1).averageIlluminance = Average.illuminance;
end

% close all;

% % Save summarized results to Excel file
% OutputDataset = struct2dataset(Output);
% outputCell = dataset2cell(OutputDataset);
% xlsPath = fullfile(Paths.analysis,['!summary_',datestr(now,'yyyy-mm-dd_HH-MM-SS'),'.xlsx']);
% xlswrite(xlsPath,outputCell);
fileName = ['groupReport_',datestr(now,'yyyy-mm-dd_HHMM')];
pdfPath = fullfile(Paths.plots,[fileName,'.pdf']);
saveas(gcf,pdfPath)

pngPath = fullfile(Paths.plots,[fileName,'.png']);
saveas(gcf,pngPath)

set(0,'DefaultAxesFontSize',defaultFontSize);

