function Paths = initpaths
%INITPATHS Initialize paths for input and output.
%   Constructs paths to network location of project.

% Preallocate output structure
Paths = struct(...
    'root'          ,'',...
    'originalData'  ,'',...
    'editedData'    ,'',...
    'analysis'      ,'',...
    'plots'         ,'',...
    'logs'          ,'',...
    'questionaires' ,'',...
    'index'         ,'');

% Set root directory

projectsPath = fullfile('IlluminanceBlanket','results');

if ispc
    Paths.root = fullfile([filesep,filesep],'root','projects',projectsPath);
elseif ismac
    Paths.root = fullfile([filesep,'Volumes'],'projects',projectsPath);
    
    % If the path is not available try mounting it
    if exist(Paths.root,'dir') ~= 7 % 7 = folder
        display('Enter credentials to mount smb://root/projects.');
        username = input('Username: ','s');
        password = input('Password: ','s');
        clc;
        mountCmd = ['mount_smbfs //',username,':',password,'@root/projects /Volumes/projects'];
        system('mkdir /Volumes/projects');
        [status,cmdout] = system(mountCmd);
        clear userName password mountCmd;
        display(cmdout);
    end
else
    error('This program only works on PCs and Macs');
end

% Check that it exists
if exist(Paths.root,'dir') ~= 7 % 7 = folder
    error(['Cannot locate the folder: ',Paths.root]);
end

% Specify session specific directories
Paths.originalData	= fullfile(Paths.root,'originalData');
Paths.editedData	= fullfile(Paths.root,'editedData');
Paths.analysis      = fullfile(Paths.root,'analysis');
Paths.plots         = fullfile(Paths.root,'plots');
Paths.logs          = fullfile(Paths.root,'logs');
Paths.index         = fullfile(Paths.logs,'index.xlsx');

end

