 %FROM: http://www.cosmomvpa.org/
% SVM multi-classifier using matlab's SVM implementation
     % predicted=cosmo_classify_matlabsvm(samples_train, targets_train, samples_test, opt)
     % Inputs
     %   samples_train      PxR training data for P samples and R features
     %   targets_train      Px1 training data classes
     %   samples_test       QxR test data
     %   opt                (optional) struct with options for svm_classify
     % Output
     %   predicted          Qx1 predicted data classes for samples_test
     % Notes:
     %  - this function uses matlab's builtin svmtrain function, which has
     %    the same name as LIBSVM's version. Use of this function is not
     %    supported when LIBSVM's svmtrain precedes in the matlab path; in
     %    that case, adjust the path or use cosmo_classify_libsvm instead.
     %  - for a guide on svm classification, see
     %      http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf
     %    note that cosmo_crossvalidate and cosmo_crossvalidation_measure
     %    provide an option 'normalization' to perform data scaling
     % NNO Aug 2013
function predicted = cosmo_classify_matlabsvm (samples_train, targets_train, samples_test, opt)
     if nargin<4, opt=struct(); end

     [ntrain, nfeatures] = size(samples_train);
     [ntest, nfeaturestst] = size(samples_test);
     ntraintarg = numel(targets_train);

     if nfeatures~=nfeaturestst || ntraintarg~=ntrain,
         error('illegal input size');
     end

     classes = unique(targets_train);
     nclasses = numel(classes);

     if nclasses < 2 || nfeatures == 0
         %matlab's svm cannot deal with empty data, so predict all test 
         %samples as the class of the first sample
         predicted = targets_train(1) * (ones(ntest,1));
         return;
     end

     %number of pair-wise comparisons
     ncombi = nclasses*(nclasses-1)/2;

     %allocate space for all predictions
     all_predicted = zeros(ntest, ncombi);

     %consider all pairwise comparisons (over classes) and store the predictions in all_predicted
     pos = 0;
     for k = 1:(nclasses-1)
         for j = (k+1):nclasses
             pos = pos+1;
             %classify between 2 classes only (from classes(k) and classes(j)).
             mask_k = targets_train==classes(k);
             mask_j = targets_train==classes(j);
             mask = mask_k | mask_j;

             all_predicted(:,pos) = cosmo_classify_matlabsvm_2class(samples_train(mask,:), targets_train(mask), samples_test, opt);
         end
     end

     %find the classes that were predicted most often
     %ties are handled by cosmo_winner_indices
     [winners, test_classes] = cosmo_winner_indices(all_predicted);

     predicted = test_classes(winners);
end

%Given multiple predictions, get indices that were predicted most often.
%[winners,classes]=cosmo_winner_indices(pred)
%Input:
%   pred              PxQ prediction values for Q features and P
%                     predictions per feature. Values of NaN are ignored,
%                     i.e. can never be a winner.
%Output:
%   winners           Px1 indices of classes that occur most often.
%                     winners(k)==w means that no value in
%                     classes(pred(k,:)) occurs more often than classes(w).
%   classes           The sorted list of unique predicted values, across
%                     all non-ignored (non-NaN) values in pred.
%Examples:
%     %a single prediction, with the third one missing
%     pred=[4; 4; NaN; 5];
%     [p, c]=cosmo_winner_indices(pred);
%     p'
%     > [1 1 NaN 2]
%     c'
%     > [4, 5]
%     %one prediction per fold (e.g. using cosmo_nfold_partitioner)
%     pred=[4 NaN NaN; 6 NaN NaN; NaN 3 NaN; NaN NaN NaN; NaN NaN 3];
%     [p, c]=cosmo_winner_indices(pred);
%     p'
%     > [2, 3, 1, NaN, 1]
%     c'
%     > [3 4 6]
%     %given up to three predictions each for eight samples, compute 
%     which predictions occur most often. NaNs are ignored.
%     pred=[4 4 4;4 5 6;6 5 4;5 6 4;4 5 6; NaN NaN NaN; 6 0 0;0 0 NaN];
%     [p, c]=cosmo_winner_indices(pred);
%     p'
%     > [2, 3, 4, 2, 3, NaN, 1, 1]
%     c'
%     > [0, 4, 5, 6]
% Notes:
% - The typical use case is combining results from multiple classification
%   predictions, such as in binary support vector machines (SVMs) and
%   cosmo_crossvalidate
% - The current implementation selects a winner pseudo-randomly (but
%   deterministically) and (presumably) unbiased in case of a tie between
%   multiple winners. That is, using the present implementation, repeatedly
%   calling this function with identical input yields identical output,
%   but unbiased with respect to which class is the 'winner' sample-wise.
% - Samples with no winner are assigned a value of NaN.
% NNO Aug 2013
function [winners,classes] = cosmo_winner_indices (pred)
     [nsamples,nfeatures] = size(pred);
     pred_msk = ~isnan(pred);

     %allocate space for output
     winners=NaN(nsamples,1);

     if nfeatures == 1
         %single prediction, handle seperately
         [classes,~,pred_idxs] = unique(pred(pred_msk));
         winners(pred_msk) = pred_idxs;
         return
     end

     sample_pred_count = sum(pred_msk,2);
     sample_pred_msk = sample_pred_count>0;
     if max(sample_pred_count) <= 1
         %only one prediction per sample; set non-predictions to zero
         %and add them up to get the prediction
         pred(~pred_msk) = 0;
         pred_merged = sum(pred(sample_pred_msk,:),2);

         [classes,~,pred_idxs] = unique(pred_merged);

         winners(sample_pred_msk) = pred_idxs;
         return
     end

     classes = unique(pred(pred_msk));

     %see how often each index was predicted
     counts = histc(pred,classes,2);

     [max_count,idx] = max(counts,[],2);
     nwinners = sum(bsxfun(@eq,max_count,counts),2);

     %deal with single winners
     single_winner_msk = nwinners==1;
     winners(single_winner_msk) = idx(single_winner_msk);

     %% Break ties
     %remove the single winners from samples to consider
     sample_pred_msk(single_winner_msk) = false;

     seed = 0;
     for k = find(sample_pred_msk)'
         tied_idxs = find(counts(k,:) == max_count(k));
         ntied = numel(tied_idxs);
         seed = seed+1;
         winners(k) = tied_idxs(mod(seed,ntied)+1);
     end
end

% svm classifier wrapper (around svmtrain/svmclassify)
% predicted=cosmo_classify_matlabsvm_2class(samples_train, targets_train, samples_test, opt)
% Inputs:
%   samples_train      PxR training data for P samples and R features
%   targets_train      Px1 training data classes
%   samples_test       QxR test data
%   opt                struct with options. supports any option that svmtrain supports
% Output:
%   predicted          Qx1 predicted data classes for samples_test
% Notes:
%  - this function uses Matlab's builtin svmtrain function, which has
%    the same name as LIBSVM's version. Use of this function is not
%    supported when LIBSVM's svmtrain precedes in the matlab path; in
%    that case, adjust the path or use cosmo_classify_libsvm instead.
%  - Matlab's SVM classifier is rather slow, especially for multi-class
%    data (more than two classes). When classification takes a long time,
%    consider using libsvm.
%  - for a guide on svm classification, see
%      http://www.csie.ntu.edu.tw/~cjlin/papers/guide/guide.pdf
%    Note that cosmo_crossvalidate and cosmo_crossvalidation_measure
%    provide an option 'normalization' to perform data scaling
% NNO Aug 2013
function predicted = cosmo_classify_matlabsvm_2class (samples_train, targets_train, samples_test, opt)
     if nargin<4, opt=struct(); end

     [ntrain,nfeatures] = size(samples_train);
     [ntest,nfeatures2] = size(samples_test);
     ntrain2 = numel(targets_train);

     if nfeatures ~= nfeatures2 || ntrain2 ~= ntrain
         error('illegal input size');
     end

     if nfeatures == 0
         %matlab's svm cannot deal with empty data, so predict all test samples as the class of the first sample
         predicted = targets_train(1) * ones(ntest,1);
         return
     end

     classes = unique(targets_train);
     nclasses = numel(classes);
     if nclasses ~= 2
         error('%s requires 2 classes, found %d. Consider using cosmo_classify_{matlab,lib}svm instead', mfilename(),nclasses);
     end

     %train & test
     try
         %Use svmtrain and svmclassify to get predictions for the testing set.
         s = svmtrain(samples_train, targets_train, 'options', opt);
         predicted = svmclassify(s, samples_test);
     catch
         caught_exception = lasterror();

         if strcmp(caught_exception.identifier,'stats:svmtrain:NoConvergence');
             warning(['SVM training did not converge. Your options are:\n'...
                    ' 1) increase ''boxconstraint''\n'...
                    ' 2) increase ''tolkkt''\n'...
                    ' 3) set ''kktviolationlevel'' to a positive value\n'...
                    ' 4) use a different classifier\n'],'');
         else
             rethrow(caught_exception);
         end
     end
end