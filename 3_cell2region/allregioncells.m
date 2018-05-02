%% 1. Set file directories
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
animalid='m1148';
% animal
animalid=lower(animalid); % in case the input is upper case
% original images
fludir=[datadir,animalid,'/',animalid,'F/JP2/'];
nissldir=[datadir,animalid,'/',animalid,'N/JP2/'];
workdir=[datadir,animalid,'/',animalid,'F/cellxreg/'];
% processed data
maskdir=[targetdir,upper(animalid),'/LGNPul_STIF/'];
%% 2. Retrieve data
toplevel={'LGNPul';'DLG';'IPul'}; % top level regions
FBcellmat=[workdir,'FBdetect_xreg.mat'];
load(FBcellmat)
for t=1:3
    % set directory
    subregdir=[maskdir,toplevel{t},'/'];
    % get the section range
    filels=dir([subregdir,'*.tif']);
    secrange=zeros(1,2);
    if ~isempty(filels)
        secnum=zeros(length(filels),1);
        for d=1:length(filels)
            s=filels(d).name(end-7:end-4);
            secnum(d)=str2double(s);
        end
        secrange(1)=min(secnum);
        secrange(2)=max(secnum);
        % count cells in each region
        regcount=regioncellcount(FBnissl,subregdir,fludir,nissldir,secrange);
        % save
        savefile=[subregdir,toplevel{t},'FBcount.mat'];
        save(savefile,'regcount')
    end
end