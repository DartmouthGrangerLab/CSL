% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function QuantImg = GetCenterSurround(image, padding)
    image_width = size(image, 1);
    image_height = size(image, 2);
    circle_responses = zeros(image_width, image_height, 10);
    parfor j = 1:10 % scale of wavelet/filter
        % Filter the image
        for x = 1:image_width
            for y = 1:image_height
                circle_responses(x,y,j) = sum(sum(image .* circle(x, y, j, image_width, image_height)));
            end
        end
    end
    center_surround = [];
    parfor j = 2:9
        center_surround(:,:,j) = abs(circle_responses(:,:,j) - circle_responses(:,:,j-1) + circle_responses(:,:,j) - circle_responses(:,:,j+1));
    end
    center_surround = center_surround(:,:,2:9);
    
    center_surround = center_surround(padding+1:image_width-padding,padding+1:image_height-padding,:);
    QuantImg = center_surround;
end


function img = circle(x, y, r, width, height)
    img = zeros(width, height);
    for ang = 0:0.01:2*pi
        xp = x + round(r*cos(ang));
        yp = y + round(r*sin(ang));
        if xp > 0 && yp > 0 && xp <= width && yp <= height
            img(xp,yp) = 1;
        end
    end
end