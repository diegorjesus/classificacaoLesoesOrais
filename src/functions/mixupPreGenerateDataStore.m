function [imdsOut] = mixupPreGenerateDataStore(imds, extensionFile)
    splitUrl = split(imds.Folders{1},"\");
    mixupImagesUrl = strrep(imds.Folders{1},string(splitUrl(end)),'mixupImages\');

    if ~exist(mixupImagesUrl, 'dir')
       mkdir(mixupImagesUrl);
    end
    
    labels = unique(imds.Labels);

    for ind = 1:size(labels)
        aux = strcat(mixupImagesUrl, string(labels(ind)));
        if ~exist(aux, 'dir')
           mkdir(aux);
        else
            rmdir(aux, 's');
            mkdir(aux);
        end
    end
    
    for ind = 1:numel(imds.Files)
        filePath = imds.Files{ind};
        img = imread(filePath);
        newFilePath = strrep(filePath,'original','mixupImages');
        imwrite(img, newFilePath);
    end
    
    XTrainCell=readall(imds);
    XTrain=cat(4,XTrainCell{:});
    YTrain=imds.Labels;

    numMixUp=2;

    [XTrainX,YY,idxS]=MixUpPreProc(XTrain,YTrain,numMixUp);
    
    for ind = 1:size(XTrainX,4)
        categoryMix=YTrain(idxS(1,ind,1:numMixUp));
        IdxMix=find(YY(:,ind)~=0);
        if numel(IdxMix)==2
            if YY(IdxMix(1),ind) > 0.7
                urlAux = mixupImagesUrl + string(categoryMix(1)) + '\';
            elseif YY(IdxMix(2),ind) > 0.7
                urlAux = mixupImagesUrl + string(categoryMix(2)) + '\';
            elseif (categoryMix(1) == 'severe') || (categoryMix(2) == 'severe')
                urlAux = mixupImagesUrl + 'severe' + '\';
            elseif (categoryMix(1) == 'moderate') || (categoryMix(2) == 'moderate')
                urlAux = mixupImagesUrl + 'moderate' + '\';
            elseif (categoryMix(1) == 'mild') || (categoryMix(2) == 'mild')
                urlAux = mixupImagesUrl + 'mild' + '\';
            elseif (categoryMix(1) == 'unhealthy') || (categoryMix(2) == 'unhealthy')
                urlAux = mixupImagesUrl + 'unhealthy' + '\';
            end
        elseif numel(IdxMix)==1
            urlAux = mixupImagesUrl + string(categoryMix(1)) + '\';
        end
        imageName = 'image'+string(ind)+extensionFile;
        imwrite(uint8(XTrainX(:,:,:,ind)), urlAux + imageName);
    end
    
    imdsOut = imageDatastore(mixupImagesUrl,...
    FileExtensions={'.jpg','.tif'},...
    LabelSource="foldernames",...
    IncludeSubfolders=true);
end

