%% regionplot_allsections.m
% This function plot the manually segmented regions and save as eps
% file for all sections that has run through LGNseg_pass3.m
% loads output from readanno3.m
function regionplot_allsections(fileidentifier,savedir)
switch nargin
    case 1
        filels=dir(fileidentifier);
        savedir=pwd;
    case  2
        filels=dir(fileidentifier);
        if strcmp(savedir(end),'/')
            savedir=savedir(1:end-1);
        end
    case 0
        filels=dir('*_LGNpul.mat');
        savedir=pwd;
end
if ~isempty(filels)
    for d=1:length(filels)
        regionfile=filels(d).name;
        disp(regionfile)
        regiondata=load(regionfile,'regiondata');
        savefile=[savedir,'/',regionfile(1:end-11),'_regions.eps'];
        regionplot(regiondata.regiondata,savefile)
    end
end
