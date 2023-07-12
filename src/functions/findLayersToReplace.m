function [learnableLayer,classLayer] = findLayersToReplace(lgraph)

if ~isa(lgraph,"nnet.cnn.LayerGraph")
    error("Argument must be a LayerGraph object.")
end

src = string(lgraph.Connections.Source);
dst = string(lgraph.Connections.Destination);
layerNames = string({lgraph.Layers.Name}');

isClassificationLayer = arrayfun(@(l) ...
    (isa(l,"nnet.cnn.layer.ClassificationOutputLayer")|isa(l,"nnet.layer.ClassificationLayer")), ...
    lgraph.Layers);

if sum(isClassificationLayer) ~= 1
    error("Layer graph must have a single classification layer.")
end
classLayer = lgraph.Layers(isClassificationLayer);

currentLayerIdx = find(isClassificationLayer);
while true

    if numel(currentLayerIdx) ~= 1
        error("Layer graph must have a single learnable layer preceding the classification layer.")
    end

    currentLayerType = class(lgraph.Layers(currentLayerIdx));
    isLearnableLayer = ismember(currentLayerType, ...
        ["nnet.cnn.layer.FullyConnectedLayer","nnet.cnn.layer.Convolution2DLayer"]);

    if isLearnableLayer
        learnableLayer =  lgraph.Layers(currentLayerIdx);
        return
    end

    currentDstIdx = layerNames(currentLayerIdx) == dst;
    currentLayerIdx = find(src(currentDstIdx) == layerNames);

end

end