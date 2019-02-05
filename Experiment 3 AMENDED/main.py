# -*- coding: utf-8 -*-
"""
Spyder Editor

Experiment 3 from the functional set size project
See https://osf.io/bph4a/


error: correct = 0, incorrect = 1, no response = 9999
resp: left = 0, right = 1

turtles and tortoises were created using GIMP


"""

from psychopy import visual, core, data, event, logging, gui, sound
import random
import grid

########################
#### PRE-EXPERIMENT ####
########################

## Get subject details
     

info_1 = {'Subject Number': 99,
          'Room': ['A', 'B', 'D', 'E'],
          'Color blind': ['Yes', 'No']}

info_2 ={'Age': '',
         'Gender': ['Male', 'Female', 'Other', 'Prefer not to answer'],
         'Ethnicity': ['Asian', 'African American', 'Hispanic', 'Multiracial', 'White', 'Other', 'Prefer not to answer'],
         'First Language': ['English', 'Korean', 'Spanish', 'Mandarin', 'Other'],
         'Preferred Hand': ['Right', 'Left']}
             
exptDlg = gui.DlgFromDict(dictionary=info_1,
        title='FSS_Experiment_3', fixed=['ExpVersion'])

if exptDlg.OK:
    pass
else:
    print('User Cancelled')
    
exptDlg = gui.DlgFromDict(dictionary=info_2,
        title='FSS_Experiment_3_a', fixed=['ExpVersion'])    

if exptDlg.OK:
    pass
else:
    print('User Cancelled')
    
info_1.update(info_2) #combine dictionaries
   
    
sub_id = info_1['Subject Number']
trialdata_fname = 'FSS_Expt_3_amended_' + str(sub_id) + '.csv'


###########################
#### Setup experiment ####
##########################

tilt = 20
jitter = 15
xcells = 8
ycells = 8
search_grid = grid.square_grid(1024, 768, xcells, ycells)
trial_timer = core.Clock()

turtles_allowed = int((xcells*ycells)/2)
stimuli_allowed = int(xcells*ycells)


#create sound
beep = sound.Sound(value = "C",sampleRate=44100, secs=0.2, octave=5)

# create window
window = visual.Window([1024, 768], monitor="261", units="pix", color=[-1,-1,-1], fullscr=True)
window.mouseVisible = False


# import stimuli
turtle_black = visual.ImageStim(window, 'turtle_black.png', autoLog=False)
turtle_green = visual.ImageStim(window, 'turtle_green.png', autoLog=False)
tortoise_black = visual.ImageStim(window, 'tortoise_black.png', autoLog=False)
#tortoise_green = visual.ImageStim(window, 'tortoise_green.png', autoLog=False)

# import backgrounds
water_top = visual.ImageStim(window, 'water_top_sand_bot.png', autoLog=False)
sand_top = visual.ImageStim(window, 'sand_top_water_bot.png', autoLog=False)


# fixation crosses
fix_hori = visual.Line(window, (-15, 0), (15, 0), lineColor='white')
fix_vert = visual.Line(window, (0, -15), (0, 15), lineColor='white')


## Timing definitions

# this is for speed run (comment out the block below for this)
frame_rate = window.getActualFrameRate()
resp_time = 0.001
break_time = 1
fix_min = 0.001
fix_max = 0.002
iti_min = 0.001
iti_max = 0.002
timer = core.Clock()
check_timer = core.Clock()
check_interval = 0.6 * (1/frame_rate)


frame_rate = window.getActualFrameRate()
resp_time = 2.5
break_time = 30
fix_min = 0.8
fix_max = 1
iti_min = 1
iti_max = 1.2
timer = core.Clock()
check_timer = core.Clock()
check_interval = 0.6 * (1/frame_rate)


# keys definition
list_keys = ['left', 'right', 'escape']
list_check_keys = ['space']

#############################
#### Experiment design #####
############################

num_blocks = 24
trials_per_block = 32
total_trials = num_blocks * trials_per_block
total_practice_trials = 8

turtle_setsizes = [0, 4, 8, 16]
tortoise_setsizes = [0, 4, 8, 16]
background = [0, 1]

# create conditions dictionary and setup trial handler
conditions_list =  []
for bg in background:
    for i in turtle_setsizes:
        for j in tortoise_setsizes:
            conditions_list.append({'background':bg, 'turtles':i, 'tortoises':j })
            

data_types = ['target_id', 'resp', 'hit', 'rt']
trials = data.TrialHandler(conditions_list, num_blocks, method='random',dataTypes=data_types, extraInfo = info_1)
practice_trials = data.TrialHandler(random.sample(conditions_list, total_practice_trials), 1, method='random', dataTypes=data_types)



##### Instructions and other text #####

instructions_1 = 'Welcome! \n\n' +\
    'You will be searching for a green turtle in a scene of black turtles and black tortoises. \n\n' +\
    'Turtles will always be in the sea, while tortoises will always be on land. \n\n' +\
    'However, the green turtle will always be on land \n\n' +\
    'Your task is to decide which direction the turtle is facing. \n\n' +\
    'You will see examples of the turtle on the following screens.' 

instructions_2 = 'Press the left arrow key if the turtle is facing the left. \n\n\n\n' +\
    'Press the left arrow key to continue'
    

instructions_3 = 'Press the right arrow key if the turtle is facing the right. \n\n\n\n' +\
    'Press the right arrow key to continue'
    
instructions_break = 'You may now take a short break for 30 seconds. \n\n\n\n' +\
    'You may press the SPACE key to skip the break and continue with the experiment.' 
    
instructions_practice = 'We are going to start with a few practice trials. \n\n\n\n' +\
    'Press the SPACE key to continue'
    
instructions_start = 'We have come to the end of the practice section. \n\n' +\
    'Your data will now be recorded. \n\n' +\
    'Please try to respond as quickly and as accurately as possible. \n\n' +\
    'There will be short breaks throughout the experiment. \n\n' +\
    'Press the SPACEBAR to start the experiment! \n\n'
    
instructions_end = 'We have come to the end of the experiment. \n\n' +\
    'Thank you for your participation! You may leave the room now. \n\n'

inst_1 = visual.TextStim(window, instructions_1, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)
inst_2 = visual.TextStim(window, instructions_2, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)
inst_3 = visual.TextStim(window, instructions_3, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)
inst_break = visual.TextStim(window, instructions_break, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)
inst_pract = visual.TextStim(window, instructions_practice, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)
inst_start = visual.TextStim(window, instructions_start, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)
inst_end = visual.TextStim(window, instructions_end, pos=(0.0, 0.0), color=(1.0, 1.0, 1.0), 
                         alignHoriz='center', alignVert='center',wrapWidth=600.0, height=24.0)

#########################
#### RUN EXPERIMENT ####
########################

## Present instructions

# welcome
inst_1.draw()
window.flip()
while True:
    allKeys = event.getKeys(keyList=list_check_keys)
    if len(allKeys) > 0:
        break
        pass
    pass

# press left
inst_2.draw()
turtle_green.pos = (0.0, 0.0)
turtle_green.ori = 0
turtle_green.draw()
window.flip()

resp = None
while resp == None:
    allKeys = event.waitKeys()
    if allKeys[0] == 'left':
        resp = 1
    pass


# press right
inst_3.draw()
turtle_green.pos = (0.0, 0.0)
turtle_green.ori = 180
turtle_green.draw()
window.flip()

resp = None
while resp == None:
    allKeys = event.waitKeys()
    if allKeys[0] == 'right':
        resp = 1
    pass

# practice instructions
inst_pract.draw()
window.flip()

resp = None
while resp == None:
    allKeys = event.waitKeys()
    if allKeys[0] == 'space':
        resp = 1
    pass

window.flip()

#### Start practice

for t in range(total_practice_trials):
    window.flip()
    event.clearEvents()
    
    target_ids = [0]*int(total_practice_trials/2) + [180]*int(total_practice_trials/2)
    random.shuffle(target_ids)
    
#    fix_frames = random.sample(range(fix_min, fix_max+1), 1)
 #   fix_frames = fix_frames[0]
    fix_duration = random.uniform(fix_min, fix_max)
    iti = random.uniform(iti_min, iti_max)
    
    practice_trial = next(practice_trials)
    
  #  for frame in range(fix_frames):
    fix_hori.draw()
    fix_vert.draw()
    window.flip()
    core.wait(fix_duration)
        
    tortoise_setsize = practice_trial['tortoises']
    turtle_setsize = practice_trial['turtles']
    bg = practice_trial['background']


    if bg == 0: #sand on top
        sand_top.draw()
        target_loc = random.sample(range(turtles_allowed,stimuli_allowed), 1)
        turtle_locs = random.sample(range(0, turtles_allowed), turtle_setsize)
        tortoise_locs = random.sample(list(set(range(turtles_allowed, stimuli_allowed)) - set(target_loc)), tortoise_setsize)
            
    elif bg == 1: #water on top
        water_top.draw()        
        target_loc = random.sample(range(0,turtles_allowed), 1)
        tortoise_locs = random.sample(list(set(range(0, turtles_allowed)) - set(target_loc)), tortoise_setsize)    
        turtle_locs = random.sample(range(turtles_allowed, stimuli_allowed), turtle_setsize)

    
    orientations = []
    all_locs = []
    # draw stimuli
    # locations and orientations are saved to be used later since we need to draw 2 buffers
    for tor in range(tortoise_setsize):
        tortoise_black.pos = grid.get_coords(tortoise_locs[tor], search_grid, jitter)
        all_locs.append(tortoise_black.pos)
        orientations.append(random.choice([0, 180]) + float(random.sample(range(-tilt, tilt), 1)[0]))
        tortoise_black.ori = orientations[-1]
        tortoise_black.draw()
    
    for tur in range(turtle_setsize):
        turtle_black.pos = grid.get_coords(turtle_locs[tur], search_grid, jitter)
        all_locs.append(turtle_black.pos)
        orientations.append(random.choice([0, 180]) + float(random.sample(range(-tilt, tilt), 1)[0]))
        turtle_black.ori = orientations[-1]
        turtle_black.draw() 
            
          
    # draw the target
    target_id = target_ids[t]
    turtle_green.pos = grid.get_coords(target_loc[0], search_grid, jitter)
    all_locs.append(turtle_green.pos)
    orientations.append(target_id + float(random.sample(range(-tilt,tilt), 1)[0])) 
    turtle_green.ori = orientations[-1]
    turtle_green.draw()
            
    window.flip(clearBuffer=False)
    
    ## Draw again because Python has 2 buffers for some reason
    if bg == 0: #water on top
        sand_top.draw()     
    elif bg == 1: #sand on top
        water_top.draw()
       
    for tor in range(tortoise_setsize):
        tortoise_black.pos = all_locs.pop(0)
        tortoise_black.ori = orientations.pop(0)
        tortoise_black.draw()
    
    for tur in range(turtle_setsize):
        turtle_black.pos = all_locs.pop(0)
        turtle_black.ori = orientations.pop(0)
        turtle_black.draw() 
            
          
    # draw the target
    target_id = target_ids[t]
    turtle_green.pos = all_locs.pop(0)
    turtle_green.ori = orientations.pop(0)
    turtle_green.draw()
            
    window.flip(clearBuffer=False)
    
        
    # save screenshots
    #window.getMovieFrame()
    #window.saveMovieFrames('screenshot' + str(t) + '.png')
    
    
    ## Get response
    rt_clock = core.Clock()
    displayed = True
    aborted = False
    while displayed:
        allKeys = event.waitKeys(maxWait = resp_time, keyList = list_keys, timeStamped = rt_clock)
        if allKeys == None:
            beep.play()
            hit = 0
            resp = 999
            break

        elif 'left' in allKeys[0]:
            displayed = False
            resp = 0
            if target_id == 0:
                hit = 1 #correct
            else:
                hit = 0
                beep.play()
                
        elif 'right' in allKeys[0]:
            displayed = False
            resp = 1
            if target_id == 180:
                hit = 1
            else:
                hit = 0
                beep.play()
        elif 'escape' in allKeys[0]:
            aborted = True
            break

    if aborted:
        core.quit()
        window.close()
            
    window.flip(clearBuffer=True)
    window.flip(clearBuffer=True)
    core.wait(iti)
        
        
#### Start actual experiment
            
# present instructions            
inst_start.draw()
window.flip()
while True:
    allKeys = event.getKeys(keyList=list_check_keys)
    if len(allKeys) > 0:
        break
        pass
    pass

#### Run experiment
    
for block in range(num_blocks):

    target_ids = [0]*int(trials_per_block/2) + [180]*int(trials_per_block/2)
    random.shuffle(target_ids)
        
    for t in range(trials_per_block):
        window.flip()
        event.clearEvents()
        fix_duration = random.uniform(fix_min, fix_max)
        iti = random.uniform(iti_min, iti_max)

        
        trial = next(trials)

        fix_hori.draw()
        fix_vert.draw()
        window.flip()
        core.wait(fix_duration)
                
        tortoise_setsize = trial['tortoises']
        turtle_setsize = trial['turtles']
        bg = trial['background']
        
           
        if bg == 0: #sand on top
            sand_top.draw()
            target_loc = random.sample(range(turtles_allowed,stimuli_allowed), 1)
            turtle_locs = random.sample(range(0, turtles_allowed), turtle_setsize)
            tortoise_locs = random.sample(list(set(range(turtles_allowed, stimuli_allowed)) - set(target_loc)), tortoise_setsize)
            
        elif bg == 1: #water on top
            water_top.draw()        
            target_loc = random.sample(range(0,turtles_allowed), 1)
            tortoise_locs = random.sample(list(set(range(0, turtles_allowed)) - set(target_loc)), tortoise_setsize)    
            turtle_locs = random.sample(range(turtles_allowed, stimuli_allowed), turtle_setsize)

        orientations = []
        all_locs = []
        # draw stimuli
        # locations and orientations are saved to be used later since we need to draw 2 buffers
        for tor in range(tortoise_setsize):
            tortoise_black.pos = grid.get_coords(tortoise_locs[tor], search_grid, jitter)
            all_locs.append(tortoise_black.pos)
            orientations.append(random.choice([0, 180]) + float(random.sample(range(-tilt, tilt), 1)[0]))
            tortoise_black.ori = orientations[-1]
            tortoise_black.draw()
        
        for tur in range(turtle_setsize):
            turtle_black.pos = grid.get_coords(turtle_locs[tur], search_grid, jitter)
            all_locs.append(turtle_black.pos)
            orientations.append(random.choice([0, 180]) + float(random.sample(range(-tilt, tilt), 1)[0]))
            turtle_black.ori = orientations[-1]
            turtle_black.draw() 
                
          
        # draw the target
        target_id = target_ids[t]
        turtle_green.pos = grid.get_coords(target_loc[0], search_grid, jitter)
        all_locs.append(turtle_green.pos)
        orientations.append(target_id + float(random.sample(range(-tilt,tilt), 1)[0])) 
        turtle_green.ori = orientations[-1]
        turtle_green.draw()
                
        window.flip(clearBuffer=False)
        
        ## Draw again because Python has 2 buffers for some reason
        if bg == 0: #water on top
            sand_top.draw()     
        elif bg == 1: #sand on top
            water_top.draw()
           
        for tor in range(tortoise_setsize):
            tortoise_black.pos = all_locs.pop(0)
            tortoise_black.ori = orientations.pop(0)
            tortoise_black.draw()
        
        for tur in range(turtle_setsize):
            turtle_black.pos = all_locs.pop(0)
            turtle_black.ori = orientations.pop(0)
            turtle_black.draw() 
                
              
        # draw the target
        target_id = target_ids[t]
        turtle_green.pos = all_locs.pop(0)
        turtle_green.ori = orientations.pop(0)
        turtle_green.draw()
                
        window.flip(clearBuffer=False)
        
        ## Get response
        rt_clock = core.Clock()
        displayed = True
        aborted = False
        while displayed:
            allKeys = event.waitKeys(maxWait = resp_time, keyList = list_keys, timeStamped = rt_clock)
            if allKeys == None:
                beep.play()
                hit = 0
                resp = 9999
                rt = 9999
                break

            elif 'left' in allKeys[0]:
                rt = allKeys[0][1] * 1000
                displayed = False
                resp = 0
                if target_id == 0:
                    hit = 1 #correct
                else:
                    hit = 0
                    beep.play()
                    
            elif 'right' in allKeys[0]:

                rt = allKeys[0][1] * 1000
                displayed = False
                resp = 1
                if target_id == 180:
                    hit = 1
                else:
                    hit = 0
                    beep.play()
            elif 'escape' in allKeys[0]:
                aborted = True
                break

        if aborted:
            trials.saveAsWideText(trialdata_fname, delim = ",") 
            core.quit()
            window.close()
        
        # add results to df
        trials.addData('rt', rt)
        trials.addData('target_id', target_id)
        trials.addData('resp', resp)
        trials.addData('hit', hit)
        trials.addData('block', block)
        trials.addData('iti', iti)
        trials.addData('fix_duration', fix_duration)
        trials.addData('target_loc', target_loc)
        logging.console.setLevel(logging.WARNING)

        # present ITI
    
        window.flip(clearBuffer=True)
        window.flip(clearBuffer=True)
        core.wait(iti)
    
    ## Rest after every 3 blocks (96 trials)
    
    if block+1 != num_blocks and (block+1) % 3 == 0:
        inst_break.draw()
        window.flip()
        break_clock = core.Clock()
        while True:
            breakKeys = event.waitKeys(maxWait = break_time, keyList = list_check_keys, timeStamped = break_clock)
            if breakKeys == None:
                break
            elif 'space' in breakKeys[0]:
                break
            break


###########################
#### END OF EXPERIMENT ####
###########################

inst_end.draw()
window.flip()
            
trials.saveAsWideText(trialdata_fname, delim = ",")
    


resp = None
while resp == None:
    allKeys = event.waitKeys()
    if allKeys[0] == 'space':
        resp = 1
    pass

window.close()
core.quit()
