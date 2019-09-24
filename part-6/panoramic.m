function panoramic()
    images = cell(1, 5);
    for i=1:5
        images{i} = imread(sprintf("im%02d.jpg", i));
    end
    current = images{1};
    for i=2:5
        current = stitch(current, images{i});
    end
    imshow(current);
end

function stitched = stitch(im01, im02)
    im01gray = single(rgb2gray(im01));
    im02gray = single(rgb2gray(im02));
    [f1, d1] = vl_sift(im01gray);
    [f2, d2] = vl_sift(im02gray);
    [matches, ~] = vl_ubcmatch(d1, d2);
    f1_match = f1(:, matches(1, :));
    f2_match = f2(:, matches(2, :));
    homography = ransac(f1_match, f2_match);
    stitched = stitch_using_homography(im01, im02, homography);
end

function [homography, f1_inlier, f2_inlier] = ransac(f1, f2)
    total = size(f1, 2);
    iteration = 30;
    max_inlier = 0;
    inlier = [];
    for i=1:iteration
        p = randperm(total, 5);
        o1 = f2(1:2, p(1));
        o2 = f2(1:2, p(2));
        o3 = f2(1:2, p(3));
        o4 = f2(1:2, p(4));
        o5 = f2(1:2, p(5));
        t1 = f1(1:2, p(1));
        t2 = f1(1:2, p(2));
        t3 = f1(1:2, p(3));
        t4 = f1(1:2, p(4));
        t5 = f1(1:2, p(5));
        a = [o1(1) o1(2) 1 0 0 0 -t1(1)*o1(1) -t1(1)*o1(2) -t1(1);
            0 0 0 o1(1) o1(2) 1 -t1(2)*o1(1) -t1(2)*o1(2) -t1(2);
            o2(1) o2(2) 1 0 0 0 -t2(1)*o2(1) -t2(1)*o2(2) -t2(1);
            0 0 0 o2(1) o2(2) 1 -t2(2)*o2(1) -t2(2)*o2(2) -t2(2);
            o3(1) o3(2) 1 0 0 0 -t3(1)*o3(1) -t3(1)*o3(2) -t3(1);
            0 0 0 o3(1) o3(2) 1 -t3(2)*o3(1) -t3(2)*o3(2) -t3(2);
            o4(1) o4(2) 1 0 0 0 -t4(1)*o4(1) -t4(1)*o4(2) -t4(1);
            0 0 0 o4(1) o4(2) 1 -t4(2)*o4(1) -t4(2)*o4(2) -t4(2);
            o5(1) o5(2) 1 0 0 0 -t5(1)*o5(1) -t5(1)*o5(2) -t5(1);
            0 0 0 o5(1) o5(2) 1 -t5(2)*o5(1) -t5(2)*o5(2) -t5(2)];
        [~, ~, V] = svd(a);
        H = reshape(V(:, 9), [3, 3]);
        transformed = H'*[f2(1:2, :); ones(1, total)];
        transformed = transformed(1:2, :) ./ repmat(transformed(3, :), 2, 1);
        distances = sum((f1(1:2, :) - transformed) .^ 2, 1);
        current_inlier = find(distances < 4);
        inlier_count = size(current_inlier, 2);
        if inlier_count > max_inlier
            max_inlier = inlier_count;
            inlier = current_inlier;
        end
    end
    disp(int2str(max_inlier));
    f1_inlier = f1(:, inlier);
    f2_inlier = f2(:, inlier);
    
    A = zeros(max_inlier*2, 9);
    for i=1:max_inlier
        origin = f2_inlier(1:2, i);
        transformed = f1_inlier(1:2, i);
        A((i-1)*2+1:i*2, :) = [origin(1) origin(2) 1 0 0 0 -transformed(1)*origin(1) -transformed(1)*origin(2) -transformed(1);
            0 0 0 origin(1) origin(2) 1 -transformed(2)*origin(1) -transformed(2)*origin(2) -transformed(2)];
    end
    [~, ~, V] = svd(A);
    homography = reshape(V(:, 9), [3, 3]);
end

function stitched = stitch_using_homography(im01, im02, homography)
    tform = maketform('projective', homography);
    [~, xdata, ydata] = imtransform(im02, tform);
    xbound = [min(1, xdata(1)), max(size(im01, 2), xdata(2))];
    ybound = [min(1, ydata(1)), max(size(im01, 1), ydata(2))];
    im01_transformed = imtransform(im01, maketform('affine',eye(3)), 'XData', xbound, 'YData', ybound);
    im02_transformed = imtransform(im02, tform, 'XData', xbound, 'YData', ybound);
    stitched = max(im01_transformed, im02_transformed);
end