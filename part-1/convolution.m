function output = convolution(input, kernal_type, type, x_scale, y_scale)
    kernal = get_kernal(input, kernal_type, type);
    if kernal_type == "haar-like"
        kernal = expand_kernal(kernal, x_scale, y_scale);
    end
    output_width = size(input, 2)-size(kernal, 2)+1;
    output_height = size(input, 1)-size(kernal, 1)+1;
    output = zeros(output_height, output_width);
    for i=1:output_width
        for j=1:output_height
            sum = double(0);
            for k=1:size(kernal, 2)
                for l=1:size(kernal, 1)
                    value = double(input(j+l-1, i+k-1)) * double(kernal(l, k));
                    sum = sum + value;
                end
            end
            output(j, i) = sum;
        end
    end
end

function kernal = get_kernal(kernal_type, type)
    if kernal_type == "sobel"
        kernal = [-1 0 1; -2 0 2; -1 0 1];
        if type == 2
            kernal = kernal';
        end
    elseif kernal_type == "gaussian"
        kernal = [1 4 6 4 1; 4 16 24 16 4; 6 24 36 24 6; 4 16 24 16 4; 1 4 6 4 1] / 256;
    elseif kernal_type == "haar-like"
        if type == 1
            kernal = [-1; 1];
        elseif type == 2
            kernal = [-1 1];
        elseif type == 3
            kernal = [1; -1; 1];
        elseif type == 4
            kernal = [1 -1 1];
        elseif type == 5
            kernal = [-1 1; 1 -1];
        end
    end
end

function result_kernal = expand_kernal(kernal, x_scale, y_scale)
    if x_scale > 1 || y_scale > 1
        origin_size_x = size(kernal, 2);
        origin_size_y = size(kernal, 1);
        result_kernal = zeros(origin_size_y * y_scale, origin_size_x * x_scale);
        for i=1:origin_size_x
            for j=1:origin_size_y
                result_kernal((j-1) * y_scale + 1:j * y_scale, (i-1) * x_scale + 1:i * x_scale) = kernal(j, i);
            end
        end
    else
        result_kernal = kernal;
    end
end