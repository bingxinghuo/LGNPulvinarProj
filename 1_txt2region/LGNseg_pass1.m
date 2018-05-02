%% This script is for when you have to use matlab interface
function LGNseg_pass1(brainid,datadir,fileind,M,wkdir)
if nargin<3
    fileind=input('Please identify an image to annotate: ','s');
end
if nargin<4
    M=64;
elseif M<64
    if mod(64,M)>0
        error('Downsample factor need to be 2^n.')
    end
elseif M>64
    if mod(M,64)>0
        error('Downsample factor need to be 2^n.')
    end
end
if nargin<5
    wkdir=pwd; % default to current directory
end
%%
jp2dir=[datadir,brainid,'/',brainid,'N/JP2/'];
STIFdir=[datadir,brainid,'/',brainid,'N/',upper(brainid),'N-STIF/'];
maskdir=[wkdir,'/../LGNPul_STIF/'];
cd(jp2dir)
filelist=jp2lsread;
% M=64;
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
R=length(regionlist);
labelind=[1:R];
% labelind=[10,2:9,20,11:17];
% labelind=[1:17];
% LGNind=[1,10,15:17];
% DLGind=[2:9];
toplevel={'LGNPul';'DLG';'IPul'}; % top level regions
toplevelind={[1,10,15:17];[2:9];[11:14]};
[~,fileid]=jp2ind(filelist,fileind);
% for f=1:length(filelist)
%     nissljp2=filelist{f};
% clear nisslimg
%% 1. downsample Nissl JP2
nissltif=imread([STIFdir,fileid(1:end-4),'.tif']);
if M~=64
    % load
    nisslimg=imread([jp2dir,fileid],'jp2');
    % downsample
    if M>1
        for i=1:3
            nisslsmall(:,:,i)=downsample_mean(nisslimg(:,:,i),M);
        end
    elseif M==1
        nisslsmall=nisslimg;
    end
    %     % save
    %     imwrite(nisslsmall,nissltif,'tif','compression','lzw')
else
    nisslsmall=nissltif;
end
% imgsize=imfinfo(fileid);
% imgwidth=imgsize.Width;
% imgheight=imgsize.Height;
%% 2. Use superpixel to manually select LGN and pulvinar regions
roiimgall=[];
if M>=32
    segment_sp=input('Do you want to try automatic segmentation? (y/n) ','s');
    % combine to grayscale
    nisslsmallgray=uint8(mean(nisslsmall,3));
    while segment_sp=='y'
        roiimg=[];
        [L,~] = superpixels(nisslsmallgray,250*64/M,'method','SLIC','compactness',10);
        BW=boundarymask(L);
        h=imoverlay(nisslsmallgray,BW);
        figure, imagesc(h)
        isrois=input('Is there any ROI? (y/n) ','s');
        if isrois=='y'
            [x,y]=getpts(gca);
            x=round(x);
            y=round(y);
            NROI=size(x,1);
            roiind=zeros(NROI,1);
            roiimg=cell(NROI,1);
            roioutline=cell(NROI,1);
            roiimgall=zeros(size(nisslsmallgray));
            for i=1:length(x)
                roiind(i)=L(y(i),x(i));
                [roiimg{i},~]=ismember(L,roiind(i));
                roiimgpoly=bwboundaries(roiimg{i});
                roioutline{i}=flip(roiimgpoly{1}*M,2);
                roiimgall=roiimgall+roiimg{i};
            end
            h=imoverlay(nisslsmallgray,roiimgall);
            figure, imagesc(h)
            doublecheck=input('Are you sure with this segmentation? (y/n) ','s');
            if doublecheck=='n'
                
                segment_sp='y';
            else
                segment_sp='n';
                
            end
            close all
        end
    end
end
%% 3. Manual segmentation
segment_man=input('Do you need manual segmentation? (y/n) ','s');
if segment_man=='y'
    ROIinfo=brainROI(nisslsmall);
    NROI=size(ROIinfo.ROIboundary,1); % number of regions selected
    % Get all the outlines in original resolution
    ROIoutline=cell(NROI,1);
    for r=1:NROI
        ROIoutline{r}=[ROIinfo.ROIboundary{r,2},ROIinfo.ROIboundary{r,3}]*M;
        ROIoutline{r}=round(ROIoutline{r});
    end
    % get the 64X downsampled masks
    ROIdown=cell(NROI,1);
    for r=1:NROI
        if M<=64 % downsample
            ROIdown{r}=downsample_mean(ROIinfo.ROIboundary{r,1},64/M);
        else % interpolate
            ROIdown{r}=repelem(ROIinfo.ROIboundary{r,1},M/64);
        end
    end
end
if ~isempty(roiimgall)
    ROIoutline=[roioutline;ROIoutline];
    ROIdown=[roiimg;ROIdown];
end
%% identify regions using 64X downsampled images
figure, imagesc(nissltif)
%     [tifheight,tifwidth,~]=size(ROIdown{1});
regionmask=cell(R,1);
cell2table(regionlist')
regiondata=cell(R,1);
for r=1:length(ROIdown)
    if ~isempty(ROIoutline{r})
        regiondatatemp=ROIoutline{r}/64;
        h=impoly(gca,regiondatatemp);
        rind=input('Please identify the index of the region: ');
        regiondata{rind}=ROIoutline{r};
        regionmask{rind}=uint8(ROIdown{r})*labelind(rind);
        delete(h)
    end
end
%% 3. upsample the ROI mask to the original image
%         roimask=repelem(roiimg,M,M);
%         roimask=roimask(1:imgheight,1:imgwidth);
%% 4. save data
% all region contours
savefile=[wkdir,'/',fileid(1:end-4),'_LGNpul.mat'];
save(savefile,'regiondata')
% all top level regions
for t=1:3
    subregionmask=[];
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


close
% end