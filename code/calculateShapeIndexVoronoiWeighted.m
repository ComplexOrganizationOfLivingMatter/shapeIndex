function [ medianShapeIndexWCells,averageShapeIndexWCells,medianShapeIndexNeighsWCells,averageShapeIndexNeighsWCells,mutantCells,neighMutantCells] = calculateShapeIndexVoronoiWeighted( photoPath )

    %get shape index of weighted cells and neighbours
    
    dataPath=strrep(photoPath,'\images\','\data\');
    dataPath=strrep(dataPath,'.png','.mat');
    dataPath=strrep(dataPath,'Imagen','Datos_imagen');
    %load(dataPath,'wts','L_original','Vecinos')
    load(dataPath,'wts','L_original')
    
    %get watershed image
    BW=zeros(size(L_original));
    BW(L_original==0)=1;
    
    if max(max(bwlabel(1-BW)))<20
       W=watershed(logical(BW),4);
    else
        W=watershed(logical(BW),8);
    end
    centroids=regionprops(W,'Centroid');
    centroids=cat(1,centroids.Centroid);
    %relabel with original labels
    BW=zeros(size(W));
    for nCen=1:length(centroids)
        if ~isempty(centroids(nCen,1))
            BW(W==nCen)=L_original(round(centroids(nCen,2)),round(centroids(nCen,1)));
        end
    end
    L_original=BW;
    
    Vecinos=calculateNeighbours(L_original);
    
    %getting valid cells
    numCells=unique(L_original);
    numCells=numCells(numCells~=0);
    firstRowCells=unique(L_original(1,1:end));
    lastRowCells=unique(L_original(end,1:end));
    firstColumnCells=unique(L_original(1:end,1))';
    lastColumnCells=unique(L_original(1:end,end))';
    noValidCells=unique([firstRowCells,lastRowCells,firstColumnCells,lastColumnCells]);
    noValidCells=noValidCells(noValidCells~=0);
    if noValidCells==1
        noValidCells=[noValidCells;Vecinos{noValidCells}];
    end
    validCells=setxor(numCells,noValidCells);
    
    
    wCells=(1:length(wts)).*(wts>0)';
    wCells=wCells(wCells~=0);
    wCells=intersect(wCells,validCells)';
    
    neighWCells=unique(vertcat(Vecinos{wCells}))';
    neighWCells=setdiff(neighWCells,wCells);
    neighWCells=intersect(neighWCells,validCells)';
           
    %vertices calculation
    [verticesInfo]=calculateVertices(L_original,Vecinos);
    
    try
        %calculate area and perimeter of involved cells
        [areaCells,perimCells]=calculateAreaPerim(L_original,verticesInfo,[neighWCells,wCells]);    
        medianShapeIndexWCells=median((perimCells(wCells)./sqrt(areaCells(wCells))));
        averageShapeIndexWCells=mean((perimCells(wCells)./sqrt(areaCells(wCells))));
        medianShapeIndexNeighsWCells=median((perimCells(neighWCells)./sqrt(areaCells(neighWCells))));
        averageShapeIndexNeighsWCells=mean((perimCells(neighWCells)./sqrt(areaCells(neighWCells))));
    
        mutantCells=length(wCells);
        neighMutantCells=length(neighWCells);
    catch 
        medianShapeIndexWCells=-1;
        averageShapeIndexWCells=-1;
        medianShapeIndexNeighsWCells=-1;
        averageShapeIndexNeighsWCells=-1;
        mutantCells=-1;
        neighMutantCells=-1;
    end
    
    
    
end

