# -*- coding: utf-8 -*-
"""
Created on Sat Oct 27 16:26:55 2018

@author: Gavin
"""

## issues:
# is it possible to convert locs into an x * y array for easier indexing?

import numpy as np
import random


def square_grid(xpixels, ypixels, xcells, ycells):
    locs = []
    
    # add 2 rows/columns to represent the border 
    # (which will be excluded later)
    xcells += 2
    ycells +=2
    
    # divide the grid     
    x_list = np.linspace(-1024.0//2, 1024.0//2, num = xcells)
    y_temp = np.linspace(-768.0//2, -60.0, num = ycells//2) # leave a 60 pixel gap in the middle for the "wave"
    y_temp2 = np.linspace(60, 768//2, num=ycells//2) # as above
    y_list = np.concatenate((y_temp, y_temp2), axis=0)
    
    # remove first and last rows and columns (basically exclude the border)
    for y in range(1,ycells-1):
        for x in range(1, xcells-1):
            locs.append([float(x_list[x]), float(y_list[y])])
    
    return locs
    
    
def get_coords(pos, locs, jitter):
    x = locs[pos][0] + float(random.sample(range(-jitter, jitter), 1)[0])
    y = locs[pos][1]+ float(random.sample(range(-jitter, jitter), 1)[0])
    return (x, y)