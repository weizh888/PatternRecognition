function [ Moment_of_Area ] = MomentOfArea( imageI, p, q )
% Compute the (p,q)th moment area in the image matrix

Moment_of_Area = 0;
height  = size(imageI,1);
width = size(imageI,2);
for x=1:width
    for y=1:height
        Moment_of_Area = Moment_of_Area + x^p*y^q*imageI(x,y);
    end
end
end

