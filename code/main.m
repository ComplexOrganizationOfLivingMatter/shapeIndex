
addpath lib
rootPath='..\Set of images\';
folders={'regularHexagons','simulationSickEpitheliums\Atrophy Sim','simulationSickEpitheliums\Case II',...
    'simulationSickEpitheliums\Case III','simulationSickEpitheliums\Case IV',...
    'simulationSickEpitheliums\Control Sim no Prol','simulationSickEpitheliums\Control Sim Prolif',...
    'simulationSickEpitheliums\Ideal Area 1 Sim','epitheliums\rosetta','voronoiDiagrams','voronoiNoise'...
    'epitheliums\cNT','epitheliums\dWL','epitheliums\dWP',...
    'epitheliums\dMWP','epitheliums\Eyes'};

artifactsSize=25;
shapeIndexTable={};
%%diagramNumbers = {'001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020', '030', '040', '050', '060', '070', '080', '090', '100', '200', '300', '400', '500', '600', '700'};



for i=1:length(folders)
   
    imagesPath=[rootPath folders{i} '\images\'];
    dataPath=[rootPath folders{i} '\data\'];
    imagesName=dir(imagesPath); 
    imagesName=imagesName(3:end,:);
     
        
    shapeIndexTable=cell(size(imagesName,1),4);
    parfor j=1:size(imagesName,1) %parfor
        photoName=imagesName(j).name;
        %%if any(cellfun(@(x) isempty(strfind(photoName, x)) == 0, diagramNumbers))
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

            if isempty(strfind(folders{i},'epitheliums\'))
                [ medianShapeIndex,averageShapeIndex,totalValidCells] = calculateShapeIndexFromVertices( L_img );
            else
                [ medianShapeIndex,averageShapeIndex,totalValidCells] = calculateShapeIndexReducingBorders( L_img );   
            end
            photoName

            shapeIndexTable(j,:)={photoName,medianShapeIndex,averageShapeIndex,totalValidCells};

        %%end
    end
    folders{i}
    shapeIndexTable=cell2table(shapeIndexTable,'VariableNames',{'name','median','mean','numValidCells'});
    writetable(shapeIndexTable, ['..\excels\vertices\' folders{i} '_' date '.xlsx'])
end
