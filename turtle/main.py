# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from psychopy import visual, core, data, event, logging
import random
import grid

# setup stuff
tilt = 20
search_grid = grid.square_grid(800, 600, 10,10, 20)
trial_timer = core.Clock()

# create window
window = visual.Window([800, 600], monitor="testMonitor", units="pix")

# import stimuli
turtle_brown = visual.ImageStim(window, 'turtle_brown.png', autoLog=False)
turtle_green = visual.ImageStim(window, 'turtle_green.png', autoLog=False)
tortoise_brown = visual.ImageStim(window, 'tortoise_brown.png', autoLog=False)
tortoise_green = visual.ImageStim(window, 'tortoise_green.png', autoLog=False)

water_top = visual.ImageStim(window, 'water_top_sand_bot.png', autoLog=False)
sand_top = visual.ImageStim(window, 'sand_top_water_bot.png', autoLog=False)


# fixation crosses
fix_hori = visual.Line(window, (-25, 0), (25, 0), lineColor='black')
fix_vert = visual.Line(window, (0, -25), (0, 25), lineColor='black')

# design
num_blocks = 1
trials_per_block = 32
total_trials = num_blocks * trials_per_block



turtle_setsizes = [0, 4, 8, 16]
tortoise_setsizes = [0, 4, 8, 16]
background = [0, 1]
conditions_list =  []
#[dict() for i in range(len(turtle_setsizes) * len(tortoise_setsizes))]


count = 0
for bg in background:
    for i in turtle_setsizes:
        for j in tortoise_setsizes:
            conditions_list.append({'background':bg, 'turtles':i, 'tortoises':j })
            count += 1


nreps = total_trials/len(conditions_list)
data_types = ['resp', 'error', 'rt']
trials = data.TrialHandler(conditions_list, 2, method='random',dataTypes=data_types)

# timing definitions
frame_rate = window.getActualFrameRate()
resp_time = 2.0
fix_frames_min = int(0.3*frame_rate)
fix_frames_max = int(0.5*frame_rate)
resp_frames = int(resp_time*frame_rate)
iti_min = 1.4
iti_max = 1.6
timer = core.Clock()
check_timer = core.Clock()
check_interval = 0.6 * (1/frame_rate)


# keys definition
list_keys = ['left', 'right', 'escape']

#for block in range(num_blocks):
for trial in trials:

    fix_hori.draw()
    fix_vert.draw()
    window.flip()
    core.wait(1)  
    
#        event.clearEvents()
#        current_trial = next(expt_trials)
    tortoise_setsize = trial['tortoises']
    print(tortoise_setsize)
    turtle_setsize = trial['turtles']
    bg = trial['background']

    if bg == 0: #sand on top
        sand_top.draw()
        tortoise_locs = random.sample(range(33, 64), tortoise_setsize)
        target_loc = random.sample(range(0,32), 1)
        turtle_locs = random.sample(list(set(range(0,32)) - set(target_loc)), turtle_setsize)
        
    elif bg == 1: #water on top
        water_top.draw()
        tortoise_locs = random.sample(range(0,32), tortoise_setsize)
        target_loc = random.sample(range(33,64), 1)
        turtle_locs = random.sample(list(set(range(33,64)) - set(target_loc)), turtle_setsize)
        
    for tor in range(tortoise_setsize):
        tortoise_brown.pos = grid.get_coords(tortoise_locs[tor], search_grid)
        tortoise_brown.ori = random.choice([0, 180]) + float(random.sample(range(-tilt,tilt), 1)[0])
        tortoise_brown.draw()
    
    for tur in range(turtle_setsize):
        turtle_brown.pos = grid.get_coords(turtle_locs[tur], search_grid)
        turtle_brown.ori = random.choice([0, 180]) + float(random.sample(range(-tilt,tilt), 1)[0])
        turtle_brown.draw() 
        
      
    
    turtle_green.pos = grid.get_coords(target_loc[0], search_grid)
    turtle_green.ori =   random.choice([0, 180]) + float(random.sample(range(-tilt,tilt), 1)[0]) 
    turtle_green.draw()
        
    window.flip()
    
    
        
        
    while True:
        if len(event.getKeys()) > 0:
            break
        event.clearEvents()
    
   

#for tor in tortoise_locs:
##    pos = grid.get_coords(tor, search_grid)
#    tortoise_brown.pos = grid.get_coords(tor, search_grid)
#    tortoise_brown.draw()
#
#for tur in range(0, 32):
#    if tur == target_loc[0]:
#        pass
#    else:
#        turtle_brown.pos = grid.get_coords(tur, search_grid)
#        turtle_brown.ori = random.choice([0, 180]) + float(random.sample(range(-tilt,tilt), 1)[0])
#        turtle_brown.draw()
#    
#turtle_green.pos = grid.get_coords(target_loc[0], search_grid)
#turtle_green.ori =   random.choice([0, 180]) + float(random.sample(range(-tilt,tilt), 1)[0]) 
#turtle_green.draw()
#
#for tor in range(33,64):
#    tortoise_brown.pos = grid.get_coords(tor, search_grid)
#    tortoise_brown.ori = random.choice([0, 180]) + float(random.sample(range(-tilt,tilt), 1)[0])
#    tortoise_brown.draw()
#     
#window.flip()


# Wait for response

    
window.close()
core.quit()