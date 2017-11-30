% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [logf] = CalcGaussLogProb (x, mu, S)
  % Returns the inverse logarithm of a multivariate Gaussian density
  % mu must be a 1xd row vector, S a dxd square covariance matrix
  % x a nxd matrix, with one point per row
  % RETURNS: a nx1 column vector of log-densities, calculated at these points
  
%   [n,d] = size(x);
%   xmu = op(x,'-',mu);
%   logf = (-d/2)*log(2*pi)-sum((xmu*inv(diag(S))).*xmu,2)/2-log(det(diag(S)))/2;
%   logf = logf(1);

%    y = mvnpdf(x,mu,sigma);

    % Eli: I know this looks NOTHING like a gaussian log probability, but somehow it yields better performance (ask Ashok).
     M = size(x, 2);
     Denom = -0.5*M*log(2*pi) - 0.5 * sum(log(S(1:M)));
     Numer = 0;
     for b = 1:M
         Numer = Numer + ((x(b) - mu(b))^2)/ S(b);
     end
     Numer = Numer * -0.5;
     logf = Numer + Denom;
end


% function out = op(arg1,operator,arg2)
%   % computes the binnary operation on the arguments, extending 1-dim
%   % dimmensions apropriately. E.g. it is ok to multiply 1xNxP and
%   % MxNx1 matrices, subtarct a vector from a matrix, etc.
%   %
%   % Written by Nathan Srebro, MIT LCS, October 1998.
%   
%   shape1=[size(arg1),ones(1,length(size(arg2))-length(size(arg1)))] ;
%   shape2=[size(arg2),ones(1,length(size(arg1))-length(size(arg2)))] ;
%   
%   out = feval(operator, ...
%       repmat(arg1,(shape1==1) .* shape2 + (shape1 ~= 1) ), ...
%       repmat(arg2,(shape2==1) .* shape1 + (shape2 ~= 1) )) ;
% end