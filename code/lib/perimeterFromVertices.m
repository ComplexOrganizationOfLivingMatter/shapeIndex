function [ perim, verticesOrdered ] = perimeterFromVertices(V,threesomes)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    perim=0;
    pairs=[];
    for i=1:size(threesomes,1)
        for j=i+1:size(threesomes,1)
            
            if sum(ismember(threesomes(i,:),threesomes(j,:)))==2
                pairs(end+1,:)=[i,j];
                perim = perim + pdist([V(i,:);V(j,:)],'euclidean');
            end
            
        end        
    end

    vertOrder=zeros(size(pairs,1),1);
    vertOrder(1,1)=pairs(1,1);
    x=1;
    for z=1:size(pairs,1)-1
      pairs(x,:)=[];
      [x,y]=find(ismember(pairs ,vertOrder(z,:)));
      vertOrder(z+1,:)=pairs(x(1),3-y);
    end
    verticesOrdered=V(vertOrder,:);
    verticesOrdered=[verticesOrdered;verticesOrdered(1,:)];
end

