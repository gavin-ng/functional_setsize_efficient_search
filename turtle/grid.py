# -*- coding: utf-8 -*-
"""
Created on Sat Oct 27 16:26:55 2018

@author: Gavin
"""

## issues:
# is it possible to convert locs into an x * y array for easier indexing?

import numpy as np
import random

def square_grid(xpixels, ypixels, xcells, ycells, jitter):
#    locs = np.reshape(range(xcells*ycells), (xcells, ycells))
#    locs = np.reshape([0,0] * (xcells*ycells)), (xcells, ycells))
    locs = []
#    x_list = np.linspace(-2/3, 2/3, num = xcells)
#    y_list = np.linspace(0.5, -0.5, num = ycells)
    
    # divide the grid 
    x_list = np.linspace(-xpixels/2, xpixels/2, num = xcells)
    y_list = np.linspace(-ypixels/2, ypixels/2, num = ycells)
    
    # remove first and last rows and columns (basically exclude the border)
    for y in range(1,ycells-1):
        for x in range(1, xcells-1):
            locs.append([float(x_list[x] + random.sample(range(-jitter, jitter), 1)), 
                         float(y_list[y] + random.sample(range(-jitter, jitter), 1))] )
    
    
    return locs
    
    
def get_coords(pos, locs):
    x = locs[pos][0]
    y = locs[pos][1]
    
    return (x, y)