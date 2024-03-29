function [homography_2to1, homography_1to2, f1_inlier, f2_inlier] = ransac(f1, f2)
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
    B = zeros(max_inlier*2, 9);
    for i=1:max_inlier
        origin = f2_inlier(1:2, i);
        transformed = f1_inlier(1:2, i);
        A((i-1)*2+1:i*2, :) = [origin(1) origin(2) 1 0 0 0 -transformed(1)*origin(1) -transformed(1)*origin(2) -transformed(1);
            0 0 0 origin(1) origin(2) 1 -transformed(2)*origin(1) -transformed(2)*origin(2) -transformed(2)];
        B((i-1)*2+1:i*2, :) = [transformed(1) transformed(2) 1 0 0 0 -origin(1)*transformed(1) -origin(1)*transformed(2) -origin(1);
            0 0 0 transformed(1) transformed(2) 1 -origin(2)*transformed(1) -origin(2)*transformed(2) -origin(2)];
    end
    [~, ~, V] = svd(A);
    homography_2to1 = reshape(V(:, 9), [3, 3]);
    [~, ~, X] = svd(B);
    homography_1to2 = reshape(X(:, 9), [3, 3]);
end