function [areaCells,perimCells]=calculateAreaPerim(L_img,verticesInfo,validCells)

    totalCells=max(max(L_img));
    
    %get empty vertices to delete them
    arrayCellVertices=verticesInfo(:).verticesConnectCells;
    emptyCells=find(cell2mat(cellfun(@(x) isempty(x),verticesInfo.verticesPerCell,'UniformOutput',false))==1);
    perimCells=zeros(totalCells,1);
    areaCells=zeros(totalCells,1);
    figure('visible', 'off');    
    for i=1:totalCells
    
        if ismember(i,validCells)
            
            [indexes,~]=find(arrayCellVertices==i);
            indexes=indexes(logical(1-ismember(indexes,emptyCells)));
            V=vertcat(verticesInfo.verticesPerCell{indexes,1});
            
            %get perimeter from vertices,
            %and sorted vertices to create a polygon and capture it area
            [perimCells(i),sortedVertices] = perimeterFromVertices(V);
            areaCells(i)=polyarea(sortedVertices(:,1),sortedVertices(:,2));

            plot(sortedVertices(:,1),sortedVertices(:,2));
            hold on;
        end
    end
            

end