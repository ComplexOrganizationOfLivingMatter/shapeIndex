function [ InnerRoiShapeIndex, OuterRoiShapeIndex] = calculateShapeIndexFromVerticesInnerOuterRois( L_img,imgRoi)


    %border one pixel 
    W=bwlabel(L_img,4);
    
    bwRoi=im2bw(imgRoi);
        
    %calculate neighs and vertices
    [neighs,~]=calculateNeighbours(W);
    [verticesInfo]=calculateVertices(W,neighs);
    
    %getting valid cells
    totalCells=max(max(W));
    numCells=1:totalCells;
    firstRowCells=unique(W(1,1:end));
    lastRowCells=unique(W(end,1:end));
    firstColumnCells=unique(W(1:end,1))';
    lastColumnCells=unique(W(1:end,end))';
    noValidCells=unique([firstRowCells,lastRowCells,firstColumnCells,lastColumnCells]);
    noValidCells=noValidCells(noValidCells~=0);
    if noValidCells==1
        noValidCells=[noValidCells;neighs{noValidCells}];
    end
    validCells=setxor(numCells,noValidCells);
    
    %valid cells into the ROIs
    validCellsInnerRoi=intersect(validCells,unique(bwRoi.*W));
    validCellsOuterRoi=intersect(validCells,unique((1-bwRoi).*W));
    
    %calculate area and perimeter of involved cells
    try
        [areaCells,perimCells]=calculateAreaPerim(W,verticesInfo,validCells);
    
        InnerRoiShapeIndex.medianShapeIndex=median((perimCells(validCellsInnerRoi)./sqrt(areaCells(validCellsInnerRoi))));
        InnerRoiShapeIndex.averageShapeIndex=mean((perimCells(validCellsInnerRoi)./sqrt(areaCells(validCellsInnerRoi))));
        OuterRoiShapeIndex.medianShapeIndex=median((perimCells(validCellsOuterRoi)./sqrt(areaCells(validCellsOuterRoi))));
        OuterRoiShapeIndex.averageShapeIndex=mean((perimCells(validCellsOuterRoi)./sqrt(areaCells(validCellsOuterRoi))));
        InnerRoiShapeIndex.numValidCells=length(validCellsInnerRoi);
        OuterRoiShapeIndex.numValidCells=length(validCellsOuterRoi);
    catch 
        InnerRoiShapeIndex=-1;
        OuterRoiShapeIndex=-1;
    end

    

end