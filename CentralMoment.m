function [ Central_Moment ] = CentralMoment( imageI, p, q )
% Compute the (p,q)th Central Moment of an image I

xc = MomentOfArea(imageI,1,0)/MomentOfArea(imageI,0,0);
yc = MomentOfArea(imageI,0,1)/MomentOfArea(imageI,0,0);

Central_Moment = 0;
height  = size(imageI,1);
width = size(imageI,2);
for x=1:width
    for y=1:height
        Central_Moment = Central_Moment + (x-xc)^p*(y-yc)^q*imageI(x,y);
    end
end

end

