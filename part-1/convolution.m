function output = convolution(input, kernel_type, type, x_scale, y_scale)
    kernel = get_kernel(kernel_type, type);
    if kernel_type == "haar-like"
        kernel = expand_kernel(kernel, x_scale, y_scale);
    end
    output_width = size(input, 2)-size(kernel, 2)+1;
    output_height = size(input, 1)-size(kernel, 1)+1;
    output = zeros(output_height, output_width);
    for i=1:output_width
        for j=1:output_height
            sum = double(0);
            for k=1:size(kernel, 2)
                for l=1:size(kernel, 1)
                    value = double(input(j+l-1, i+k-1)) * double(kernel(l, k));
                    sum = sum + value;
                end
            end
            output(j, i) = sum;
        end
    end
end

function kernel = get_kernel(kernel_type, type)
    if kernel_type == "sobel"
        kernel = [-1 0 1; -2 0 2; -1 0 1];
        if type == 2
            kernel = kernel';
        end
    elseif kernel_type == "gaussian"
        kernel = [1 4 6 4 1; 4 16 24 16 4; 6 24 36 24 6; 4 16 24 16 4; 1 4 6 4 1] / 256;
    elseif kernel_type == "haar-like"
        if type == 1
            kernel = [-1; 1];
        elseif type == 2
            kernel = [-1 1];
        elseif type == 3
            kernel = [1; -1; 1];
        elseif type == 4
            kernel = [1 -1 1];
        elseif type == 5
            kernel = [-1 1; 1 -1];
        end
    end
end

function result_kernel = expand_kernel(kernel, x_scale, y_scale)
    if x_scale > 1 || y_scale > 1
        origin_size_x = size(kernel, 2);
        origin_size_y = size(kernel, 1);
        result_kernel = zeros(origin_size_y * y_scale, origin_size_x * x_scale);
        for i=1:origin_size_x
            for j=1:origin_size_y
                result_kernel((j-1) * y_scale + 1:j * y_scale, (i-1) * x_scale + 1:i * x_scale) = kernel(j, i);
            end
        end
    else
        result_kernel = kernel;
    end
end