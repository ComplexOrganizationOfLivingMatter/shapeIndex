function [ medianShapeIndexWCells,averageShapeIndexWCells,medianShapeIndexNeighsWCells,averageShapeIndexNeighsWCells,mutantCells,neighMutantCells] = calculateShapeIndexVoronoiWeighted( photoPath )

    %get shape index of weighted cells and neighbours
    
    dataPath=strrep(photoPath,'\images\','\data\');
    dataPath=strrep(dataPath,'.png','.mat');
    dataPath=strrep(dataPath,'Imagen','Datos_imagen');
    load(dataPath,'wts','L_original','Vecinos')
    
    wCells=(1:length(wts)).*(wts>0)';
    wCells=wCells(wCells~=0);
    
    neighWCells=unique(vertcat(Vecinos{wCells}))';
    neighWCells=setdiff(neighWCells,wCells);
    
           
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
        neighMutantCells;
    end
    
    
    
end

