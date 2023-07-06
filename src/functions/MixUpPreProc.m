function [XTrainX,YY,idxS]=MixUpPreProc(XTrain,YTrain,numMixUp)
    % first, the composition ratio of each image was randomly determined
    % for example, in the explanation above, the value of α, β and γ was
    % decided 
    lambda= rand([numel(YTrain),numMixUp]);
    lambda=lambda./sum(lambda,2);%the sum of lambda value accross the class should be 1 
    lambda=reshape(lambda,[1 1 1 numel(YTrain) numMixUp]);
    
    idxS=[]; XTrainK=[]; YTrainK=[]; XTrainX=zeros([size(XTrain)]); 
    numClasses=numel(countcats(YTrain));classes = categories(YTrain);
    % after this loop, idxS will be a vector with the size of (number of
    % training image) * 1 * (number of mix up)
    % number of mixup is, in many cases, 2, but you can specify as you want
    % The value extracted from idxS(N,1,1:end) represents the index of training images to mix up
    % this means, the images with the same class can be mixed up 
    % The images were mixed up with the weight of lamda
    % The variable XTrainX is the images after mixed-up
    for k=1:numMixUp
        idxK=randperm(numel(YTrain));
        idxS=cat(3,idxS,idxK);
        XTrainK=cat(5,XTrainK,double(XTrain(:,:,:,idxK)));
        YTrainK=cat(2,YTrainK,YTrain(idxK)); %YTrainK:(miniBatchSize)×(numMixUp)
        XTrainX=XTrainX+double(XTrain(:,:,:,idxK)).*lambda(1,1,1,:,k);
    end
    
    % Next, the vector which corresponds to the label information was made
    % if the classes in the task are dog, cat and bird and one image was
    % synthesized using 50 % of dog and bird image, 
    % the label for the synthesized image should be [0.5 0 0.5]
    % Howeve, in this loop, the weitht and the classes to pick were
    % randomly collected, then the lables were prepared as follows: 
    lambda=squeeze(lambda);
    Y = zeros(numClasses, numel(YTrain), numMixUp,'single');
    for j=1:numMixUp
        lambdaJ=lambda(:,j);
        for c = 1:numClasses
            Y(c,YTrain(idxS(1,:,j))==classes(c),j) = lambdaJ(find(YTrain(idxS(1,:,j))==classes(c)));
        end
    end
    YY=sum(Y,3);
end
