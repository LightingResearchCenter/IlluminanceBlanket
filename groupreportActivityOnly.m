function groupreportActivityOnly

Paths = initpaths;

% Enable required libraries
[parentDir,~,~] = fileparts(pwd);
circadianDir = fullfile(parentDir,'circadian');

addpath(circadianDir);
import('reports.composite.*');
% Imports
import plots.legendflex.*;

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

    Average = reports.composite.daysimeteraverages(cs,lux,ai);
    
    
    hAxes = subplot(2,2,i1);
    
    h2 = plot(hAxes,Miller.time.hours,Miller.activity);
    set(hAxes,'ActivePositionProperty','position');
    set(hAxes,'TickDir','out');
    set(hAxes,'Box','off');
    set(hAxes,'Color','none');
    set(hAxes,'YColor','k');
    set(hAxes,'Layer','top');
    % Format x-axis
    xTick = 0:24;
    xTickLabel = {'00:00','','','','','',...
                  '06:00','','','','','',...
                  '12:00','','','','','',...
                  '18:00','','','','','',...
                  '24:00'};
    set(hAxes,'XLim',[0,24]);
    % Ticks and labels on first x-axis.
    set(hAxes,'XTick',xTick);
    set(hAxes,'XTickLabel',xTickLabel);
    % Label x-axis
    xlabel(hAxes,'Time');
    
    % Format y-axes
    yTick = 0:0.1:0.7;
    set(hAxes,'YLim',[0,0.7]);
    set(hAxes,'YTick',yTick);
    ylabel(hAxes,'Activity Index (AI)');
    
    % Format data2
    set(h2,'DisplayName','Activity Index (AI)');
    set(h2,'Color',[0,0,0]);
    set(h2,'LineWidth',2);
    
    if i1 == 1
        text(1.167,0.3219,' \leftarrow Ex.: Caregiver Interaction')
    end
    
    
    % Fix box
    fixBox(hAxes);
    
    title(hAxes,['Subject: ',subject]);
    
end

fileName = ['!groupReportActivityOnly_',datestr(now,'yyyy-mm-dd_HHMM')];
pdfPath = fullfile(Paths.plots,[fileName,'.pdf']);
saveas(gcf,pdfPath)

end

function fixBox(hAxes)
% create new, empty axes with box but without ticks
hBox = axes('Position',get(hAxes,'Position'),'box','on','xtick',[],'ytick',[]);
% set original axes as active
axes(hAxes);
% link axes in case of zooming
linkaxes([hAxes hBox])

set(hBox,'Layer','top');
end