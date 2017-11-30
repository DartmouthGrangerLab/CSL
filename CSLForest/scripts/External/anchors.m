%from fastkmeans
function [centers, mincenter, mindist, lower, computed] = anchors(firstcenter,k,data)
    % choose k centers by the furthest-first method

    [n,dim] = size(data);
    centers = zeros(k,dim);
    lower = zeros(n,k);
    mindist = Inf*ones(n,1);
    mincenter = ones(n,1);
    computed = 0;
    centdist = zeros(k,k);

    for j = 1:k
        if j == 1
            newcenter = firstcenter;
        else
            [maxradius,i] = max(mindist);
            newcenter = data(i,:);
        end

        centers(j,:) = newcenter;
        centdist(1:j-1,j) = calcdist(centers(1:j-1,:),newcenter);
        centdist(j,1:j-1) = centdist(1:j-1,j)';
        computed = computed + j-1;

        inplay = find(mindist > centdist(mincenter,j)/2);
        newdist = calcdist(data(inplay,:),newcenter);
        computed = computed + size(inplay,1);
        lower(inplay,j) = newdist;

        move = find(newdist < mindist(inplay));
        shift = inplay(move);
        mincenter(shift) = j;
        mindist(shift) = newdist(move);
    end
end

function distances = calcdist(data,center)
    %  input: vector of data points, single center or multiple centers
    % output: vector of distances

    [n,dim] = size(data);
    [n2,dim2] = size(center);

    % Using repmat is slower than using ones(n,1)
    %   delta = data - repmat(center,n,1);
    %   delta = data - center(ones(n,1),:);
    % The following is fastest: not duplicating the center at all
    if n2 == 1
        distances = sum(data.^2, 2) - 2*data*center' + center*center';
    elseif n2 == n
        distances = sum( (data - center).^2 ,2);
    else
        error('bad number of centers');
    end

    % Euclidean 2-norm distance:
    distances = sqrt(distances);

    % Inf-norm distance:
    % distances = max(abs(distances),[],2);
end