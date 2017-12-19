
addpath lib

rootPath='..\..\imagesSet\';
folders={'regularHexagons','simulationSickEpitheliums\Atrophy Sim','simulationSickEpitheliums\Case II',...
    'simulationSickEpitheliums\Case III','simulationSickEpitheliums\Case IV',...
    'simulationSickEpitheliums\Control Sim no Prol','simulationSickEpitheliums\Control Sim Prolif',...
    'simulationSickEpitheliums\Ideal Area 1 Sim','voronoiDiagrams','voronoiNoise'...
    'epitheliums\cNT','epitheliums\dWL','epitheliums\dWP',...
    'epitheliums\dMWP','epitheliums\Eyes','epitheliums\rosette',...
    'voronoiWeighted\half','voronoiWeighted\disk'};

artifactsSize=25;
filterCVT=[1:20,30:10:100,200:100:700];

filterVoronoiWeighted=[4,10:10:80];
filterVoronoiWeighted=arrayfun(@(x) num2str(x,'%10.2f\n'),filterVoronoiWeighted,'UniformOutput',false);


   
    imagesPath=[rootPath folders{i} '\images\'];
    dataPath=[rootPath folders{i} '\data\'];
    imagesName=dir(imagesPath); 
    imagesName=imagesName(3:end,:);
    
    flag=0; 
    if ~isempty(strfind(folders{i},'voronoiWeighted')) 
        shapeIndexTable=cell(size(imagesName,1),7);
        flag=1;
    else
        shapeIndexTable=cell(size(imagesName,1),4); 
    end
    
    
    parfor j=1:size(imagesName,1) %parfor
        photoName=imagesName(j).name;
        img=imread([imagesPath photoName]);
        
        BW=im2bw(img);
        if(sum(sum(BW==0))>sum(sum(BW==1)))
           BW=1-BW; 
        end
        BW=bwareaopen(BW,artifactsSize);
        L_img=bwlabel(BW);
        if max(max(L_img))<20
            L_img=bwlabel(BW,4);
        end
       
                
        %calculate area and perimeter from vertices
%         if isempty(strfind(folders{i},'epitheliums\'))
            if isempty(strfind(folders{i},'voronoiWeighted'))
                
                [ medianShapeIndex,averageShapeIndex,totalValidCells] = calculateShapeIndexFromVertices( L_img );
                shapeIndexTable(j,:)={photoName,medianShapeIndex,averageShapeIndex,totalValidCells};
            else
                
                flag2=[];
                for numFilt=1:length(filterVoronoiWeighted) 
                   flag2=[flag2,strfind(photoName,['_' filterVoronoiWeighted{numFilt}  '_'])] ;
                end
                
                if isempty(flag2)
                    continue
                end
                
                [ medianShapeIndexWCells,averageShapeIndexWCells,medianShapeIndexNeighsWCells,averageShapeIndexNeighsWCells,mutantCells,neighMutantCells ] = calculateShapeIndexVoronoiWeighted( [imagesPath photoName] );
                shapeIndexTable(j,:)={photoName,medianShapeIndexWCells,averageShapeIndexWCells,medianShapeIndexNeighsWCells,averageShapeIndexNeighsWCells,mutantCells,neighMutantCells};
                
            end
%         else
%             [ medianShapeIndex,averageShapeIndex,totalValidCells] = calculateShapeIndexReducingBorders( L_img, folders{i} );   
%             shapeIndexTable(j,:)={photoName,medianShapeIndex,averageShapeIndex,totalValidCells};
%         end
        photoName
        camroll(-90)
        set(gca,'Visible','off')
        print('-dtiff','-r300',['..\excels\vertices\' folders{i} '\' photoName(1:end-4) '.tiff'])
        close all
        
       

    end
    folders{i}
    if flag==0
        shapeIndexTable=cell2table(shapeIndexTable,'VariableNames',{'name','median','mean','numValidCells'});
    else
        shapeIndexTable=cell2table(shapeIndexTable,'VariableNames',{'name','medianWeighted','meanWeighted','medianNeighWeighted','meanNeighWeighted','weightedCells','neighWeightedCells'});
    end
    
    nameFolder=strsplit(folders{i},'\');
    writetable(shapeIndexTable, ['..\excels\vertices\' folders{i} '\' nameFolder{end} '_' date '.xlsx'])
end
