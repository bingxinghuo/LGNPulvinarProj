%% readanno3.m
% This script reads the text file downloaded from web portal
% Version 3. Updated 3/23/2018
% Update 4/20/2018. Added manual identification and proofreading.
function regiondata=readanno3(jp2file,tifdir,QCcheck)
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
nulllist='null';
R=length(regionlist);
regiondata=cell(R,1);
if nargin>1 % trigger visualization tool
    M=64; % all in 64X downsampled images
    nissltif=[tifdir,'/',jp2file(1:end-4),'.tif'];
    nisslsmall=imread(nissltif,'tif');
end
%% 1. Convert text file to region contours
% import text file as cell array
regionoutlinetxt=['Marking-',jp2file,'.txt'];
C=fileread(regionoutlinetxt);
addind0=strfind(C,'Add:[[');
C=C(addind0:end); % ignore all the deleted regions
%
% identify how many regions were annotated
delims=strfind(C,'[[');
for d=1:length(delims)
    % identify the region sequence, including labels
    regind0=delims(d)+1; % start of the sequence
    regind1=strfind(C(regind0:end),']]'); % first encounter of ]] after the region starts
    regind1=regind1(1)+regind0-1;
    regionseq=C(regind0:regind1);
    % isolate the last entry as the label
    labelarr0=strfind(regionseq,'[');
    labelarr0=labelarr0(end);
    % read out the label
    labelind0=strfind(regionseq,'(');
    labelind1=strfind(regionseq,')');
    labelseq=regionseq(labelind0+1:labelind1-1);
    if isempty(labelseq)
        labelind0=strfind(regionseq,nulllist);
        if isempty(labelind0)
            error('Unknown region.')
        end
        r=[];
    else
        r=find(strcmp(regionlist,labelseq)); % identify the region
    end
    % read out polygon
    regionseq=regionseq(1:labelarr0-2); % update the region sequence
    regionseq(strfind(regionseq,'['))=[' '];
    regionseq(strfind(regionseq,']'))=[' '];
    regionseq(strfind(regionseq,','))=[' '];
    A=sscanf(regionseq,'%f');
    % reorganize into x and y coordinates
    Acoord=zeros(length(A)/2,2);
    for i=1:length(A)/2
        Acoord(i,:)=A((i-1)*2+1:i*2);
    end
    Acoord=round(abs(Acoord));
    % save in the cooresponding cell
    if ~isempty(r)
        if isempty(regiondata{r})
        regiondata{r}=[regiondata{r},Acoord];
        else % more than one polygon
            l1=size(regiondata{r},1);
            l2=size(Acoord,1);
            lc=max(l1,l2);
            fixlength=zeros(lc,size(regiondata{r},2)+2);
            fixlength(1:l1,1:size(regiondata{r},2))=regiondata{r};
            fixlength(1:l2,end-1:end)=Acoord;
            regiondata{r}=fixlength;
        end
    else
        if nargin<2
            error('Not enough input! TIF file directory is required to identify "null" regions.')
        else
            cell2table(regionlist') % display the regions with their indices
            figure, imagesc(nisslsmall) % show image
            regiondatatemp=Acoord/M;
            h=impoly(gca,regiondatatemp); % show polygon
            rind=input('Please identify the index of the region: '); % manual identification
            regiondata{rind}=Acoord;
            delete(h)
            close gcf
        end
    end
end

%% Manual quality control
if nargin<3
    QCcheck=input('Do you wish to check the region correspondence? (y/n) ','s');
    if QCcheck=='n'
        QCcheck=0;
    else
        QCcheck=1;
    end
end
if QCcheck==1 % trigger visual inspection
    if nargin<2
        error('Not enough input! TIF file directory is required to identify "null" regions.')
    else
        figure, imagesc(nisslsmall)
        regpass=zeros(R,1);
        for r=1:R
            if ~isempty(regiondata{r})
                regiondatatemp=regiondata{r}/M;
                h=impoly(gca,regiondatatemp);
                title(regionlist{r})
                regcheck=input('Accept the current label? (y/n) ','s');
                if regcheck=='y'
                    regpass(r)=1;
                else
                    regpass(r)=-1;
                end
                delete(h) % remove current polygon
            end
        end
        if sum(regpass<0)>0 % there are mis-labeled regions
            regiondata1=cell(R,1);
            for r=1:R
                if regpass(r)>=0 % no data regions (0) or correct regions (1)
                    regiondata1{r}=regiondata{r};
                else
                    regiondatatemp=regiondata{r}/M;
                    h=impoly(gca,regiondatatemp);
                    cell2table(regionlist') % display the regions with their indices
                    title('')
                    rind=input('Please identify the index of the region: '); % manual identification
                    if ~isempty(regiondata1{rind}) % catch mistake
                        disp('Cannot overwrite a correct region.')
                        rind=input('Please identify the region again: ');
                    end
                    regiondata1{rind}=regiondata{r}; % re-identify region
                    delete(h)
                end
            end
        end
        close gcf
    end
end