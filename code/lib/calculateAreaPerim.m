function [areaCells,perimCells]=calculateAreaPerim(L_img,verticesInfo,validCells)

    totalCells=max(max(L_img));
    
    %get empty vertices to delete them
    arrayCellVertices=verticesInfo(:).verticesConnectCells;
    emptyCells=find(cell2mat(cellfun(@(x) isempty(x),verticesInfo.verticesPerCell,'UniformOutput',false))==1);
    perimCells=zeros(totalCells,1);
    areaCells=zeros(totalCells,1);
    figure('visible', 'off');    
    for i=1:totalCells
        i
        
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
%             if size(sortedVertices, 1) < 4
%                 throw exception
%             end
            plot(sortedVertices(:,1),sortedVertices(:,2));
            hold on;
        end
    end
            

end