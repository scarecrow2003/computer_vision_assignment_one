function [f1_match, f2_match] = find_match(im01, im02)
    im01gray = single(rgb2gray(im01));
    im02gray = single(rgb2gray(im02));
    [f1, d1] = vl_sift(im01gray);
    [f2, d2] = vl_sift(im02gray);
%     [matches, ~] = vl_ubcmatch(d1, d2);
    matches = find_matches(d1, d2, 0.9295);
    f1_match = f1(:, matches(1, :));
    f2_match = f2(:, matches(2, :));
end

function matches = find_matches(d1, d2, reject_threshold)
    d1_size = size(d1, 2);
    d2_size = size(d2, 2);
    matches = zeros(2, d1_size);
    counter = 0;
    for i=1:d1_size
        d1_d = d1(:, i);
        closest_index = 0;
        closest_value = realmax;
        second_closest_value = realmax;
        for j=1:d2_size
            d2_d = d2(:, j);
            dist_square = sum((d1_d - d2_d) .^ 2);
            if dist_square <= closest_value
                second_closest_value = closest_value;
                closest_value = dist_square;
                closest_index = j;
            elseif dist_square < second_closest_value
                second_closest_value = dist_square;
            end
        end
        if sqrt(closest_value) / sqrt(second_closest_value) < reject_threshold
            counter = counter + 1;
            matches(:, counter) = [i; closest_index];
        end
    end
    matches = matches(:, 1:counter);
end