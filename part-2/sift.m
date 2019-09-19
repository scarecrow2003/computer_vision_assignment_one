function result = sift(input)
    I = single(rgb2gray(imread(input)));
    hold on;
    imshow(I, []);
    [f, d] = vl_sift(I);
    perm = randperm(size(f, 2));
    selected = perm(1:80);
    h3 = vl_plotsiftdescriptor(d(:, selected), f(:, selected));
    set(h3, 'color', 'yellow');
    hold off;
    result = size(f, 2);
end