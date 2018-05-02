% initialize
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
animalid='m1144';
% set directory
animalid=lower(animalid); % in case the input is upper case
nissldir=[datadir,animalid,'/',animalid,'N/JP2/'];
STIFdir=[datadir,animalid,'/',animalid,'N/',upper(animalid),'N-STIF/'];
maskdir=[targetdir,upper(animalid),'/LGNPul_STIF/'];
savedir=[targetdir,upper(animalid),'/celltif/'];
if ~exist(savedir)
    mkdir(savedir)
end
%%
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
% 1. Get file list
cd(nissldir)
filelist=jp2lsread;
% 2. Get cross-registered cell info
load([targetdir,upper(animalid),'/FBdetect_xreg.mat'])
% 3. Identify a range of images
% [fileind0,~]=jp2ind(filelist,Nrange(1));
% [fileind1,~]=jp2ind(filelist,Nrange(2));
% 4.
M=64;
R=17;
% 4. assemble all region cell counts
toplevel={'LGNPul';'DLG';'IPul'}; % top level regions
% toplevelind={[1,10,15:17];[2:9];[11:14]};
for t=1:3
    subregdir=[maskdir,toplevel{t},'/'];
    load([subregdir,toplevel{t},'FBcount.mat'])
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
    end
    if t==1
        cellcount=regcount;
        sec0=secrange(1);
        [fileind0,~]=jp2ind(filelist,['0',num2str(sec0)]);
        [fileind1,~]=jp2ind(filelist,['0',num2str(secrange(2))]);
    else
        [file0,~]=jp2ind(filelist,['0',num2str(secrange(1))]);
        [file1,~]=jp2ind(filelist,['0',num2str(secrange(2))]);
        cellcount(file0-fileind0+1:file1-fileind0+1,:)=...
            cellcount(file0-fileind0+1:file1-fileind0+1,:)+regcount;
    end
end
savecell=[savedir,'allregioncells.mat'];
if ~exist(savecell,'file')
    save(savecell,'cellcount')
end
%%
for f=fileind0:fileind1
    savetif=[savedir,filelist{f}(1:end-4),'_cells.tif'];
%     if ~exist(savetif,'file')
        %  Nissl image
        nissltif=imread([STIFdir,filelist{f}(1:end-4)],'tif');
        figure, imagesc(nissltif)
        % overlay region delineation
        load([targetdir,upper(animalid),'/',upper(animalid),'_LGNPul/',filelist{f}(1:end-4),'_LGNpul.mat'])
        hold on
        regionpoly=cell(R,1);
        for r=1:R
            if ~isempty(regiondata{r})
                regionpoly{r}=polyshape(regiondata{r}(:,1)/M,regiondata{r}(:,2)/M);
                plot(regionpoly{r})
            end
        end
        % overlay cells
        if ~isempty(FBnissl{f})
            hold on, scatter(FBnissl{f}(:,1)/M,FBnissl{f}(:,2)/M,'.')
        end
        % show statistics
        countlabel_all=[];
        for r=1:R
            if cellcount(f-fileind0+1,r)>0
                countlabel=[regionlist{r},'=',num2str(cellcount(f-fileind0+1,r))];
                countlabel_all=[countlabel_all,',',countlabel];
            end
        end
        if ~isempty(countlabel_all)
            legend(countlabel_all(2:end))
        end
        set(gca,'fontsize',18)
        % save image
        saveas(gcf,savetif)
        close
%     end
end

