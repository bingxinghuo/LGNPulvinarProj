Ithresh=30;
Ncell=length(cellsignal1);
cellpix=zeros(Ncell,1);
for n=1:Ncell
    if ~isempty(cellsignal1{n})
    cellmask=cellsignal1{n}(:,:,3)>Ithresh;
    cellpix(n)=sum(sum(cellmask));
    end
end