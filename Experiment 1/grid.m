function grid1(sp, xcells, ycells, jitterx, jittery ,centerx, centery)
    global cx;
    global cy;
    global Xcentre;
    global Ycentre;
    global coordinates ;
    

% 12 x 12 display, 144 possible locations

pad = 10;

% % starting coordinates of grid
coords_x = linspace(0,1024,(xcells)+3) ;
coords_y = linspace(0,768, (ycells)+3) ;

% get x and y position on the grid
y = ceil(sp./ ycells) ;
x = mod(sp, xcells) ;

% there is no column 0, so if x==0, it is actually the last column
if x == 0 ;
    x = xcells;
end ;
if y == 0 ;
    y = ycells;
end ;

% convert back to x and y pixel coordinates
tx = coords_x(x+1);
ty = coords_y(y+1);

tx = tx + (Xcentre)./(xcells.*2) ;
ty = ty + (Ycentre)./(ycells.*2) ;

% pon_x = Shuffle([-1, 1]) ;
% pon_y = Shuffle([-1, 1]) ;

% jitterx = jitterx .* (pon_x(1)) ; 
% jittery = jittery .* (pon_y(1)) ; 

cx = tx -jitterx + (jitterx + jitterx) .*rand(1,1);
cy = ty -jittery + (jittery + jittery) .*rand(1,1);
% 
% cx = tx + jitterx ;
% cy = ty + jittery ;

coordinates = [ cx, cy ] ;

end



