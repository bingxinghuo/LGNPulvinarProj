brainid='m920';
datadir='/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
jp2dir=[datadir,brainid,'/',brainid,'N/JP2/'];
nissllist=filelsread('*_LGNpul.mat'); % output from readanno3.m
% flulist=filelsread('*.jp2.txt'); % from BRAINID_cells/cellanno/
% go through every file
for d=14:length(flulist)
    %     fileid=filels(d).name;
    fluid=flulist{d};
    c0=strfind(fluid,'-F')+2;
    c1=strfind(fluid,'--')-1;
    secind=fluid(c0:c1);
    [~,fileid]=jp2ind(nissllist,['N',secind]);
    disp(fileid)
    allregiondata=load(fileid);
    regiondata=allregiondata.regiondata;
    if isfield(allregiondata,'Klayermask')
        Klayermask=allregiondata.Klayermask; % output from layerseg.m
    end
    jp2file=[fileid(1:end-11),'.jp2'];
    nisslinfo=imfinfo([jp2dir,jp2file]);
    R=10;
    annoimg=zeros(nisslinfo.Height,nisslinfo.Width);
    for r=2:R
        % reorganize regiondata
        if ~isempty(regiondata{r})
            subpolys=size(regiondata{r},2)/2;
            X=cell(1);
            Y=cell(1);
            for s=1:subpolys
                regionoutline=regiondata{r}(:,(s*2-1):(s*2));
                X{s}=regionoutline(:,2);
                Y{s}=regionoutline(:,1);
                annoimg=annoimg+poly2mask(Y{s},X{s},nisslinfo.Height,nisslinfo.Width)*r;
            end
        end
        
    end
    regioncols=max(regiondata{1}(:,1));
    regionrows=max(regiondata{1}(:,2));
    if isfield(allregiondata,'Klayermask')
        for k=1:4
            if (sum(sum(Klayermask{k})))>0
            annoimg(1:regionrows,1:regioncols)=annoimg(1:regionrows,1:regioncols)+Klayermask{k}*(k+5);
            end
        end
    end
    annoimg=uint8(annoimg);
    imwrite(annoimg,[fileid(1:end-10),'_anno.tif'])
    clear Klayermask regiondata allregiondata
end