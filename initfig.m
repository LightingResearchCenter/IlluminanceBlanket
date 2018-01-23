function [hFigure,width,height,units] = initfig(h,visible)
%INITIALIZEFIGURE Summary of this function goes here
%   Detailed explanation goes here

import reports.composite.*;

% Create figure window
hFigure = figure(h);
set(hFigure,'Visible',visible);

% Define paper properties
paperOrientation = 'landscape'; % 'portrait' or 'landscape'
set(hFigure,'PaperOrientation',paperOrientation);

paperType = 'usletter';
set(hFigure,'PaperType',paperType);

paperUnits = 'inches'; % Paper units
set(hFigure,'PaperUnits',paperUnits);

paperSize = get(hFigure,'PaperSize'); % [width,height]

paperPositionMode = 'manual';
set(hFigure,'PaperPositionMode',paperPositionMode);

% Define useable area to print in
width  = paperSize(1);
height = paperSize(2);
paperPosition = [0,0,width,height]; % [left,bottom,width,height]
set(hFigure,'PaperPosition',paperPosition);

% Define figure window properties
units = 'inches'; % Figure units
set(hFigure,'Units',units);

position = [0.5,0.5,width,height]; % [left,bottom,width,height]
set(hFigure,'Position',position);

% Limit user's ability to change figure
dockControls = 'off';
set(hFigure,'DockControls',dockControls);

resize = 'off';
set(hFigure,'Resize',resize);

end

