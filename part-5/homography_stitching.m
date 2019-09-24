function homography_2to1 = homography_stitching()
    im01 = imread("im01.jpg");
    im02 = imread("im02.jpg");
    
    [f1_match, f2_match] = find_match(im01, im02);
    draw_matching(im01, im02, f1_match, f2_match);
    
    [homography_2to1, homography_1to2, f1_inlier, f2_inlier] = ransac(f1_match, f2_match);
    draw_matching(im01, im02, f1_inlier, f2_inlier);
    stitch(im01, im02, homography_2to1);
    stitch(im02, im01, homography_1to2);
end

function draw_matching(im01, im02, f1_match, f2_match)
    im01pad = padarray(im01, [0, 640, 0], 0, 'post');
    im02pad = padarray(im02, [0, 640, 0], 0, 'pre');
    ims = im01pad + im02pad;
    f2_match = f2_match + [640; 0; 0; 0];
    figure;
    imshow(ims);
    hold on;
    for i=1:size(f1_match, 2)
        plot([f1_match(1, i) f2_match(1, i)], [f1_match(2, i) f2_match(2, i)], 'LineWidth', 2);
    end
    hold off;
end

function stitch(im01, im02, homography)
    tform = maketform('projective', homography);
    [~, xdata, ydata] = imtransform(im02, tform);
    xbound = [min(1, xdata(1)), max(size(im01, 2), xdata(2))];
    ybound = [min(1, ydata(1)), max(size(im01, 1), ydata(2))];
    im01_transformed = imtransform(im01, maketform('affine',eye(3)), 'XData', xbound, 'YData', ybound);
    im02_transformed = imtransform(im02, tform, 'XData', xbound, 'YData', ybound);
    ims = max(im01_transformed, im02_transformed);
    figure;
    imshow(ims);
end
