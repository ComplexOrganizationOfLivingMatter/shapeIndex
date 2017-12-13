function [ medianShapeIndex,averageShapeIndex,totalValidCells] = calculateShapeIndexReducingBorders( L_img )

    %getshape index from natural images reducing their borders to 1 pixel
    BW=zeros(size(L_img));
    BW(L_img==0)=1;
    
    if max(max(bwlabel(1-BW)))<20
       W=watershed(logical(BW),4);
    else
        W=watershed(logical(BW),8);
    end
    
    %getting valid cells
    totalCells=max(max(W));
    numCells=1:totalCells;
    firstRowCells=unique(W(1,1:end));
    lastRowCells=unique(W(end,1:end));
    firstColumnCells=unique(W(1:end,1))';
    lastColumnCells=unique(W(1:end,end))';
    noValidCells=unique([firstRowCells,lastRowCells,firstColumnCells,lastColumnCells]);
    noValidCells=noValidCells(noValidCells~=0);
    validCells=setxor(numCells,noValidCells);
    
    %calculate area, perimeter and shape index from regionprops
    area=regionprops(W,'Area');
    perim=regionprops(W,'Perimeter');
    area=cat(1,area.Area);
    perim=cat(1,perim.Perimeter);
    shapeIndex=perim./sqrt(area);
    medianShapeIndex=median(shapeIndex(validCells));
    averageShapeIndex=mean(shapeIndex(validCells));

    
    totalValidCells=length(validCells);
end

