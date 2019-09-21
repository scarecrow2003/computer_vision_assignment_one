function homography_matrix = ransac()
    im01 = imread('im01.jpg');
    im01gray = single(rgb2gray(im01));
    im02 = imread('im02.jpg');
    im02gray = single(rgb2gray(im02));
    [f1, d1] = vl_sift(im01gray);
    [f2, d2] = vl_sift(im02gray);
    [matches, scores] = vl_ubcmatch(d1, d2);
    im01pad = padarray(im01, [0, 640, 0], 0, 'post');
    im02pad = padarray(im02, [0, 640, 0], 0, 'pre');
    ims = im01pad + im02pad;
    f2 = f2 + [640; 0; 0; 0];
    imshow(ims);
    hold on;
    for i=1:size(matches, 2)
        plot([f1(1, matches(1, i)) f2(1, matches(2, i))], [f1(2, matches(1, i)) f2(2, matches(2, i))], 'LineWidth', 2);
    end
    hold off;
end