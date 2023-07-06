function [dataOut, info] = preProcessImages(data, info)
dataOut = data;
for idx = 1:size(data, 1)
    temp = data.input{idx, 1};
    temp = rescale(temp);
    dataOut.input{idx, 1} = temp;
end
end