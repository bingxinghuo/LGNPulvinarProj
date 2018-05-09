workdir=[datadir,animalid,'/',animalid,'F/cellxreg/'];
FBcellmat=[workdir,'FBdetect_xreg.mat'];
N=length(fileinds_nissl);
cd(nissldir)
nissllist=jp2lsread;
%%
% kcellcount=zeros(N,4);
for n=1:N
    fbcelltf=round(FBnissl{fileinds_nissl(n)});
    kmaskfile=[nissllist{fileinds_nissl(n)}(1:end-4),'_LGNpul.mat'];
    load(kmaskfile,'Klayermask')
    klayer=cellfun(@isempty,Klayermask);
    if sum(~klayer)>0
        k_ind=find(~klayer);
        [imgheight,imgwidth]=size(Klayermask{k_ind(1)});
        
        if ~isempty(fbcelltf)
            % remove out of boundary coordinates
            [ind1,~]=find(fbcelltf<=0);
            ind2=find(fbcelltf(:,1)>imgwidth);
            ind3=find(fbcelltf(:,2)>imgheight);
            fbcelltf([ind1;ind2;ind3],:)=[];
            % read out the annotation indices
            annoind=zeros(size(fbcelltf,1),1);
            for k=1:4
                if ~isempty(Klayermask{k})
                    for i=1:size(fbcelltf,1)
                        if Klayermask{k}(fbcelltf(i,2),fbcelltf(i,1))
                            annoind(i)=k;
                        end
                    end
                end
                kcellcount(n,k)=sum(annoind==k);
            end
        end
    end
end