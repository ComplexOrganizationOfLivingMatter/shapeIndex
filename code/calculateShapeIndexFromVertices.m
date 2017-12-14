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
    
    %get empty vertices to delete them
    arrayCellVertices=verticesInfo(:).verticesConnectCells;
    emptyCells=find(cell2mat(cellfun(@(x) isempty(x),verticesInfo.verticesPerCell,'UniformOutput',false))==1);
    perimCells=zeros(totalCells,1);
    areaCells=zeros(totalCells,1);
        
    for i=1:totalCells
        
        if ismember(i,validCells)
            [indexes,~]=find(arrayCellVertices==i);
            indexes=indexes(logical(1-ismember(indexes,emptyCells)));
            threesomes=arrayCellVertices(indexes,:);
            V=vertcat(verticesInfo.verticesPerCell{indexes,1});
            
            %checking if the vertice is a cross and delete one
            cellsNeighsRep=threesomes(threesomes~=i);
            uniqNeighs=unique(cellsNeighsRep);
            %if a cell is present more than 2 times, out one vertex
            if sum(histc(cellsNeighsRep, uniqNeighs)>2)>0
                cellsCross = uniqNeighs(histc(cellsNeighsRep, uniqNeighs)>2);
                vert2delete=zeros(size(threesomes,1),1);
                for nCross=1:length(cellsCross)
                    vert2delete=vert2delete+sum(threesomes==cellsCross(nCross),2);
                end
                v2delete=find(vert2delete==2);
                if size(v2delete,1)>1
                    VDelete=V(v2delete,:);
                    distMatrix=squareform(pdist([VDelete;V]));
                    v2delete=v2delete(sum(distMatrix(size(VDelete,1)+1:end,1:size(VDelete,1))<10)>1);
                end
                threesomes=threesomes(~ismember(1:size(V,1),v2delete),:);
                V=V(~ismember(1:size(V,1),v2delete),:);
            end
            
            %get perimeter from vertices,
            %and sorted vertices to create a polygon and capture it area
            [perimCells(i),sortedVertices] = perimeterFromVertices(V,threesomes);
            areaCells(i)=polyarea(sortedVertices(:,1),sortedVertices(:,2));
        end
    end
    
    medianShapeIndex=median((perimCells(validCells)./sqrt(areaCells(validCells))));
    averageShapeIndex=mean((perimCells(validCells)./sqrt(areaCells(validCells))));
    
    totalValidCells=length(validCells);

end

