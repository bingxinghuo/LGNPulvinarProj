%% layerseg.m
% Bingxing Huo. May 2018
% Manual segmentation of koniocellular layers
function layerseg
% get the section range
filels=dir('*_LGNpul.mat');
if ~isempty(filels)
    for d=1:length(filels)
% for d=26
        fileid=filels(d).name;
        manseg(fileid);
    end
end
end

function Klayermask=manseg(regionfile)
load(regionfile)
sublayer=cellfun(@isempty,regiondata(2:5));
Klayermask=cell(4,1);
if sum(~sublayer)>1
    %% Get whole LGN
    regioncols=max(regiondata{1}(:,1));
    regionrows=max(regiondata{1}(:,2));
    LGNmask=poly2mask(regiondata{1}(:,1),regiondata{1}(:,2),regionrows,regioncols);
    %% Remove M and P layers
    MPlayers=zeros(regionrows,regioncols);
    for i=2:5
        if ~isempty(regiondata{i})
            subpolys=size(regiondata{i},2)/2;
            regionx=regiondata{i}(:,1);
            regionx(regionx>regioncols)=regioncols;
            regiony=regiondata{i}(:,2);
            regiony(regiony>regionrows)=regionrows;
            MPlayers=MPlayers+poly2mask(regionx,regiony,regionrows,regioncols);
            if subpolys>1
                for s=2:subpolys
                    regionx=regiondata{i}(:,(s-1)*2+1);
                    regionx(regionx>regioncols)=regioncols;
                    regiony=regiondata{i}(:,s*2);
                    regiony(regiony>regionrows)=regionrows;
                    MPlayers=MPlayers+poly2mask(regionx,regiony,regionrows,regioncols);
                end
            end
        end
    end
    Klayers=LGNmask-MPlayers;
    %% Visualize
    cutmask=zeros(regionrows,regioncols);
    figure, imagesc(Klayers)
    xlims=[min(regiondata{1}(:,1)),max(regiondata{1}(:,1))];
    ylims=[min(regiondata{1}(:,2)),max(regiondata{1}(:,2))];
    axis image
    axis([xlims,ylims])
    caxis([0 1])
    %% Select cutoff point pairs
    [xi,yi]=getpts;
    N=length(xi);
    xi=reshape(xi,2,N/2);
    yi=reshape(yi,2,N/2);
    for p=1:N/2
        h=imline(gca,[xi(1,p),yi(1,p);xi(2,p),yi(2,p)]);
        cutmask=cutmask+createMask(h);
    end
    se=strel('disk',2);
    cutmask=imdilate(cutmask,se);
    cutmask=1-cutmask;
    Klayers=Klayers.*cutmask;
    %% Select regions
    cc=bwconncomp(Klayers);
    L=labelmatrix(cc);
    
    for k=1:4
        isklayer=input(['Is there K',num2str(k),'? (y/n)'],'s');
        if isklayer=='y'
            title(['K',num2str(k)],'fontsize',20)
            [xi,yi]=getpts;
            yi=round(yi);
            xi=round(xi);
            for p=1:length(xi)
                if p==1
                    Klayermask{k}=ismember(L,L(yi(p),xi(p)));
                else
                    Klayermask{k}=Klayermask{k}+ismember(L,L(yi(p),xi(p)));
                end
            end
        end
        Klayermask{k}=logical(Klayermask{k}); % binary mask
    end
end
save(regionfile,'Klayermask','-append')
close
end