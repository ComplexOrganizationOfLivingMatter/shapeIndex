function [ perim, verticesOrdered ] = perimeterFromVertices(V)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    
    perim=0;
    
    V=unique(V,'rows');
    
    orderVertices=convhull(V(:,1),V(:,2));
    
    verticesOrdered=V(orderVertices,:);
    for i=1:length(orderVertices)-1
       perim = perim + pdist([verticesOrdered(i,:);verticesOrdered(i+1,:)],'euclidean');
    end

    
    
end