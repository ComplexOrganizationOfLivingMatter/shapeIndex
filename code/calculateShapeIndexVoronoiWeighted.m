function [ medianShapeIndexWCells,averageShapeIndexWCells,medianShapeIndexNeighsWCells,averageShapeIndexNeighsWCells,mutantCells,neighMutantCells] = calculateShapeIndexVoronoiWeighted( photoPath )

    %get shape index of weighted cells and neighbours
    
    dataPath=strrep(photoPath,'\images\','\data\');
    dataPath=strrep(dataPath,'.png','_data.mat');
    load(dataPath,'wts','L_original','Vecinos')
    
    wCells=(1:length(wts)).*(wts>0)';
    wCells=wCells(wCells~=0);
    
    neighWCells=unique(vertcat(Vecinos{wCells}))';
    neighWCells=setdiff(neighWCells,wCells);
    
           
    %vertices calculation
    [verticesInfo]=calculateVertices(L_original,Vecinos);
    
    %calculate area and perimeter of involved cells
    [areaCells,perimCells]=calculateAreaPerim(L_original,verticesInfo,[neighWCells,wCells]);    
    
    
    medianShapeIndexWCells=median((perimCells(wCells)./sqrt(areaCells(wCells))));
    averageShapeIndexWCells=mean((perimCells(wCells)./sqrt(areaCells(wCells))));
    medianShapeIndexNeighsWCells=median((perimCells(neighWCells)./sqrt(areaCells(neighWCells))));
    averageShapeIndexNeighsWCells=mean((perimCells(neighWCells)./sqrt(areaCells(neighWCells))));
    
    mutantCells=length(wCells);
    neighMutantCells=length(neighWCells);
    
end

