function [imdsTrain] = generateMixupByLabels(imds, fileExtensions)
    countLabels = countEachLabel(imds);
    for ind = 1 : height(countLabels)
        row = countLabels(ind, :);
        splitImds = splitEachLabel(imds, row.Count, 'Include', row.Label);    
        imdsTrain = mixupPreGenerateDataStore(splitImds, fileExtensions);
    end
end

