function homography_matrix = stitching()
    im01 = imread('im01.jpg');
    imshow(im01);
    t_points = ginput(4);
    im02 = imread('im02.jpg');
    imshow(im02);
    o_points = ginput(4);
    a = [o_points(1, 1) o_points(1, 2) 1 0 0 0 -t_points(1, 1)*o_points(1, 1) -t_points(1, 1)*o_points(1, 2) -t_points(1, 1);
        0 0 0 o_points(1, 1) o_points(1, 2) 1 -t_points(1, 2)*o_points(1, 1) -t_points(1, 2)*o_points(1, 2) -t_points(1, 2);
        o_points(2, 1) o_points(2, 2) 1 0 0 0 -t_points(2, 1)*o_points(2, 1) -t_points(2, 1)*o_points(2, 2) -t_points(2, 1);
        0 0 0 o_points(2, 1) o_points(2, 2) 1 -t_points(2, 2)*o_points(2, 1) -t_points(2, 2)*o_points(2, 2) -t_points(2, 2);
        o_points(3, 1) o_points(3, 2) 1 0 0 0 -t_points(3, 1)*o_points(3, 1) -t_points(3, 1)*o_points(3, 2) -t_points(3, 1);
        0 0 0 o_points(3, 1) o_points(3, 2) 1 -t_points(3, 2)*o_points(3, 1) -t_points(3, 2)*o_points(3, 2) -t_points(3, 2);
        o_points(4, 1) o_points(4, 2) 1 0 0 0 -t_points(4, 1)*o_points(4, 1) -t_points(4, 1)*o_points(4, 2) -t_points(4, 1);
        0 0 0 o_points(4, 1) o_points(4, 2) 1 -t_points(4, 2)*o_points(4, 1) -t_points(4, 2)*o_points(4, 2) -t_points(4, 2)];
    [U, S, V] = svd(a);
    V_T = V';
    homography_matrix = reshape(V_T(9, :), [3, 3]);
    tform = maketform('projective', homography_matrix);
    [~, xdata, ydata] = imtransform(im02, tform);
    xbound = [min(1, xdata(1)), max(size(im01, 2), xdata(2))];
    ybound = [min(1, ydata(1)), max(size(im01, 1), ydata(2))];
    im01_transformed = imtransform(im01, maketform('affine',eye(3)), 'XData', xbound, 'YData', ybound);
    im02_transformed = imtransform(im02, tform, 'XData', xbound, 'YData', ybound);
    ims = max(im01_transformed, im02_transformed);
    imshow(ims);
end