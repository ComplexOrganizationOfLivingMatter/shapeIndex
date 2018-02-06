
addpath lib

rootPath='..\..\imagesSet\';
folders={'regularHexagons\images','simulationSickEpitheliums\Atrophy Sim\images','simulationSickEpitheliums\Case II\images',...
    'simulationSickEpitheliums\Case III\images','simulationSickEpitheliums\Case IV\images',...
    'simulationSickEpitheliums\Control Sim no Prol\images','simulationSickEpitheliums\Control Sim Prolif\images',...
    'simulationSickEpitheliums\Ideal Area 1 Sim\images','voronoiDiagrams\images','voronoiNoise\images'...
    'epitheliums\cNT\images','epitheliums\dWL\images','epitheliums\dWP\images',...
    'epitheliums\dMWP\images','epitheliums\Eyes\images','epitheliums\rosette\images',...
    'voronoiWeighted\half\images','voronoiWeighted\disk\images','LManningSimulations\solid\images','LManningSimulations\soft\images',...
    'neo_samples\Processed_images\neo\neo0\Skeleton_seq_roi','neo_samples\Processed_images\neo\neo1\Skeleton_seq_roi',...
    'neo_samples\Processed_images\neo\neo2\Skeleton_seq_roi','From ROB\few cells\cleaned\Mbs RNAi',...
    'From ROB\few cells\cleaned\ROK RNAi','From ROB\few cells\cleaned\WT','..\moviesWingDisk_Rob\movie1\final',...
    '..\moviesWingDisk_Rob\movie2\final','..\moviesWingDisk_Rob\movie6\final'};





artifactsSize=25;
filterCVT=[1:20,30:10:100,200:100:700];

filterVoronoiWeighted=[4,10:10:80];
filterVoronoiWeighted=arrayfun(@(x) num2str(x,'%10.2f\n'),filterVoronoiWeighted,'UniformOutput',false);

for i=length(folders)-2:length(folders)

   
    imagesPath=[rootPath folders{i} '\'];
    imagesName=dir(imagesPath); 
    imagesName=imagesName(3:end,:);
    
    flag=0; 
    if ~isempty(strfind(folders{i},'voronoiWeighted')) 
        shapeIndexTable=cell(size(imagesName,1),7);
        flag=1;
    else
        shapeIndexTable=cell(size(imagesName,1),4); 
    end
    
    
    parfor j=1:size(imagesName,1) 
        photoName=imagesName(j).name;
        img=imread([imagesPath photoName]);
        
        BW=im2bw(img);
        if(sum(sum(BW==0))>sum(sum(BW==1))) && isempty(strfind(folders{i},'neo_samples'))
           BW=1-BW; 
           
        end
        BW=bwareaopen(BW,artifactsSize,4);
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
        mkdir(['..\excels\vertices\' folders{i} '\'])
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
