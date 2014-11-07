function [dimesimeter,subject] = parsefilename(fileName)
%PARSEFILENAME Summary of this function goes here
%   Detailed explanation goes here

% Remove path and extension.
[~,str,~] = fileparts(fileName);

% Match regular expression.
% Example str: 'Incubator Lighting Study_Dime211wrist_SubjectMHSB203_03Nov2014header'
expression = '^.*_Dime(\d*)[^_]*_Subject([^_]*)_.*$';
outkey = 'tokens';
out = regexp(str,expression,outkey);

% Assign tokens to variables
dimesimeter = str2double(out{1}{1});
subject = out{1}{2};


end

