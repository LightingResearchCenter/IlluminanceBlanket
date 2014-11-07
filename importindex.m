function [subject,dimesimeter,blanket,startTime,endTime,notes] = importindex(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE Import data from a spreadsheet
%   [subject,dimesimeter,blanket,startTime,endTime,notes] =
%   IMPORTFILE(FILE) reads data from the first worksheet in the Microsoft
%   Excel spreadsheet file named FILE and returns the data as column
%   vectors.
%
%   [subject,dimesimeter,blanket,startTime,endTime,notes] =
%   IMPORTFILE(FILE,SHEET) reads from the specified worksheet.
%
%   [subject,dimesimeter,blanket,startTime,endTime,notes] =
%   IMPORTFILE(FILE,SHEET,STARTROW,ENDROW) reads from the specified
%   worksheet for the specified row interval(s). Specify STARTROW and
%   ENDROW as a pair of scalars or vectors of matching size for
%   dis-contiguous row intervals. To read to the end of the file specify an
%   ENDROW of inf.
%
%	Non-numeric cells are replaced with: NaN
%
% Example:
%   [subject,dimesimeter,blanket,startTime,endTime,notes] =
%   importfile('index.xlsx','Sheet1',2,6);
%
%   See also XLSREAD.

% Auto-generated by MATLAB on 2014/11/07 14:15:42

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    endRow = 100;
end

%% Import the data, extracting spreadsheet dates in Excel serial date format
[~, ~, raw, dates] = xlsread(workbookFile, sheetName, sprintf('A%d:F%d',startRow(1),endRow(1)),'' , @convertSpreadsheetExcelDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:F%d',startRow(block),endRow(block)),'' , @convertSpreadsheetExcelDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dates = [dates;tmpDateNumBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[1,6]);
raw = raw(:,[2,3]);
dates = dates(:,[4,5]);

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),dates); % Find non-numeric cells
dates(R) = {NaN}; % Replace non-numeric Excel dates with NaN

%% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

%% Allocate imported array to column variable names
subject = cellVectors(:,1);
dimesimeter = data(:,1);
blanket = data(:,2);
dates(~cellfun(@(x) isnumeric(x) || islogical(x), dates)) = {NaN};
startTime = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
endTime = datetime([dates{:,2}].', 'ConvertFrom', 'Excel');
notes = cellVectors(:,2);

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% startTime=datenum(startTime);
% endTime=datenum(endTime);

