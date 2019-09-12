%% klayervol.m
% Bingxing Huo. May 2018
% Extract volumes of koniocellular layers of LGN and inferior pulvinar
%
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
animalid='M920';
% workdir=[targetdir,upper(animalid),'/',upper(animalid),'_LGNPul/'];
workdir=[targetdir,upper(animalid),'/',upper(animalid),'_LGNPul/segmentation_with_cell_count/'];
R=17;
%% get the section range
cd(workdir)
filels=dir('*_LGNpul.mat');
secnum=zeros(length(filels),1);
for d=1:length(filels)
    secstart0=strfind(filels(d).name,'N')+1;
    secstart1=strfind(filels(d).name,'--')-1;
    secnum(d)=str2double(filels(d).name(secstart0:secstart1));
end
[~,secorder]=sort(secnum,'ascend');
%%
Kvol=cell(length(filels),1);
regionvol=cell(length(filels),1);
for f=1:length(filels)
    fileid=filels(secorder(f)).name
    % decide z axis
    secstart0=strfind(fileid,'N')+1;
    secstart1=strfind(fileid,'--')-1;
    secf=str2double(fileid(secstart0:secstart1));
    if f==1
        sec0=secf;
        Kvol{f}.z=0; % tentative
    else
        %         if secf<120 % m919
        %             Kvol{f}.z=(secf-sec0)*80/1000;
        %         else
        %             Kvol{f}.z=Kvol{f-1}.z+80/1000;
        %         end
        Kvol{f}.z=(secf-sec0)*80/1000; % relative z in mm
    end
    regionvol{f}.z=Kvol{f}.z;
    %%
    Kvol{f}.area=zeros(1,4);
    Klayermask=[];
    regiondata=[];
    load(fileid,'regiondata','Klayermask')
    if ~isempty(Klayermask)
    % get K layer areas
    klayer=cellfun(@isempty,Klayermask);    
    if sum(~klayer)>0
        for k=1:4
            if ~isempty(Klayermask{k})
                %                 figure, imagesc(Klayermask{k})
                Kvol{f}.area(k)=sum(sum(Klayermask{k}))*.46^2/1000^2; % in mm^2
            end
        end
    end
    end
    
    % find region range
    sublayer=cellfun(@isempty,regiondata);
    ind=find(~sublayer);
    regiondata1=regiondata;
    for indn=1:length(ind)
        if size(regiondata{indn},2)>2
            regiondata1{indn}=reshape(regiondata{indn},[],2);
        end
    end
    regionrange=cell2mat(regiondata1(ind));
    regioncols=max(regionrange(:,1));
    regionrows=max(regionrange(:,2));
    % get other region areas
    regionmask=cell(R,1);
    for r=1:R
        if ~isempty(regiondata{r})
            subpolys=size(regiondata{r},2)/2;
            regionmask{r}=poly2mask(regiondata{r}(:,1),regiondata{r}(:,2),regionrows,regioncols);
            if subpolys>1
                for s=2:subpolys
                    regionmask{r}=regionmask{r}+poly2mask(regiondata{r}(:,(s-1)*2+1),regiondata{r}(:,s*2),regionrows,regioncols);
                end
            end
            
            regionvol{f}.area(r)=sum(sum(regionmask{r}))*.46^2/1000^2;
        else
            regionvol{f}.area(r)=0;
        end
    end
end
%% visualize
zs=zeros(length(filels),1);
Karea=zeros(1,4);
regionarea=zeros(1,R);
for f=1:length(filels)
    zs(f)=Kvol{f}.z;
    Karea=[Karea;Kvol{f}.area];
    regionarea=[regionarea;regionvol{f}.area];
end
Karea=Karea(2:end,:);
regionarea=regionarea(2:end,:);
regionarea(:,6:9)=Karea;
% figure, bar(zs,[Karea,regionarea])
% legend('K1','K2','K3','K4','IPul')
% set(gca,'fontsize',14)
%%
save([animalid,'_volumes.mat'],'zs','regionarea')