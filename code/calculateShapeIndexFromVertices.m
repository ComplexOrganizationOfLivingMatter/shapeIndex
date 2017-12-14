function [ medianShapeIndex,averageShapeIndex,totalValidCells] = calculateShapeIndexFromVertices( L_img )


    %border one pixel 
    BW=zeros(size(L_img));
    BW(L_img==0)=1;
    
    if max(max(bwlabel(1-BW)))<20
       W=watershed(logical(BW),4);
    else
        W=watershed(logical(BW),8);
    end
        
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
    
    %calculate area and perimeter of involved cells
    try
        [areaCells,perimCells]=calculateAreaPerim(W,verticesInfo,validCells);
    catch ex
        throw ex
    end

    medianShapeIndex=median((perimCells(validCells)./sqrt(areaCells(validCells))));
    averageShapeIndex=mean((perimCells(validCells)./sqrt(areaCells(validCells))));
    
    totalValidCells=length(validCells);

end

