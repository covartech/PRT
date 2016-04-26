function mat = prtUtilMatrixCornerCat(mat1,mat2,padValueFn)
% xxx Need Help xxx







if nargin < 3
    padValueFn = @zeros;
end
mat = cat(1,cat(2,mat1,padValueFn(size(mat1,1),size(mat2,2))),cat(2,padValueFn(size(mat2,1),size(mat1,2)),mat2));
