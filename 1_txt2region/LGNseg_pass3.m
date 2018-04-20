%% This script works with downloaded annotation from the web portal
% Version 3. Updated 3/23/2018
% Updated 4/20/2018. Includes manual identification and proofreading.
% e.g.
% LGNseg_pass3('m920','/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/');
function LGNseg_pass3(brainid,datadir,vischeck,wkdir)
if nargin<3
    vischeck=0; % no double check
end
if nargin<4
    wkdir=pwd; % default to current directory
end
jp2dir=[datadir,brainid,'/',brainid,'N/JP2/'];
STIFdir=[datadir,brainid,'/',brainid,'N/',upper(brainid),'N-STIF/'];
cd(jp2dir)
filelist=jp2lsread;
% brain regions
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
M=64; % downsample rate
R=length(regionlist); % total number of regions
labelind=[1:R];
% LGNPulind=[1,10,15:17]; % all LGN and pulvinar regions
% DLGind=[2:9]; % subregions of DLG
% IPulind=[11:14]; % subregions of IPul
toplevel={'LGNPul';'DLG';'IPul'}; % top level regions
toplevelind={[1,10,15:17];[2:9];[11:14]};
F=length(filelist);
cd(wkdir) % go to working directory
% create directories to save the mask tif files
maskdir=['../LGNPul_STIF/'];
for t=1:3
    if ~exist([maskdir,toplevel{t}],'dir')
        mkdir([maskdir,toplevel{t}]
    end
end
% go through every file
for f=1:F
    fileid=filelist{f};
    regionoutlinetxt=['Marking-',fileid,'.txt'];
    savefile=[fileid(1:end-4),'_LGNpul.mat'];
    % 1. convert text file into matrix
    if ~exist(savefile)
        if exist(regionoutlinetxt,'file')
            % read out individual region's polygon in full resolution
            regiondata=readanno3(fileid,STIFdir,vischeck);
            % save subregion data in full resolution
            save(savefile,'regiondata')
            % 2. generate individual region's mask in downsampled resolution
            nisslstif=imread([STIFdir,fileid(1:end-4)],'tif');
            [tifheight,tifwidth,~]=size(nisslstif);
            %             regionlabel=uint8(zeros(tifheight,tifwidth));
            regionmask=cell(R,1);
            subregionmask=[];
            for r=1:R
                if ~isempty(regiondata{r})
                    regiondatadown=round(regiondata{r}/M);
                    regionmask{r}=poly2mask(regiondatadown(:,1),regiondatadown(:,2),tifheight,tifwidth);
                    regionmask{r}=regionmask{r}*labelind(r);
                end
            end
            % all top level regions
            for t=1:3
                for l=1:length(toplevelind{t})
                    subregi=toplevelind{t}(l);
                    if ~isempty(regionmask{subregi})
                        if isempty(subregionmask)
                            subregionmask=regionmask{subregi};
                        else
                            subregionmask=subregionmask+regionmask{subregi};
                        end
                    end
                end
                % save
                if ~isempty(subregionmask)
                    subregfile=[maskdir,toplevel{t},'/',fileid(1:end-4),'.tif'];
                    imwrite(uint8(subregionmask*15),subregfile,'tif','WriteMode','overwrite')
                end
            end
        end
    end
end
