% Screen('Preference', 'SkipSyncTests', 1 );

%%  Functional set size in efficient search
%   Created by Gavin Ng
%   Last edit: 10/9/18
%
%
%
%
%
%
%
%
%



%% INITIALIZATION %%
%%%%%%%%%%%%%%%%%%%%

% start timer
tic
rand('state',sum(100*clock));
warning off MATLAB:DeprecatedLogicalAPI

subject_id = input('Enter Subject Number:    ');

DemographicQuestions(subject_id);

KbName('UnifyKeyNames');
HideCursor
% comment out the previous line to run on Macs
global Xcentre;
global Ycentre;
global cx;
global cy;


% Output file
fid = fopen([num2str(subject_id) '_pilot' '.out'], 'a');


%% Reserving memory space for large variables %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

background = [0 0 0];
% [window, rect] = Screen('OpenWindow', max(Screen('Screens')), background);
[window, rect] = Screen('OpenWindow', max(Screen('Screens')), background, [0, 0, 1024, 768]);


% To make the window a smaller size for debugging, uncomment next line
% [window, rect] = Screen('OpenWindow', 0, background, rect);

Screen('TextSize', window, 40);


% Sizes
XLeft=rect(RectLeft);
XRight=rect(RectRight);
YTop=rect(RectTop);
YBottom=rect(RectBottom);
Xcentre=XRight./2;
Ycentre=YBottom./2;

% Colors
white = [255, 255, 255];
black = [0, 0, 0];

% offset and jitter for stimuli
offset = 20;
jitter = 20;

% response keys
escKey=KbName('ESCAPE');
startKey=KbName('=+');
LeftKey=KbName('LeftArrow');
RightKey=KbName('RightArrow');


% timing

refresh_rate=85;
bit=(1/refresh_rate)/2;
resp_time=2.5;
fix_time=0.6;
onset_delay = 0.45;
disp_time=3;
inter_trial=1;
rest_time=30;   %rest time between blocks

% % speed run
%
% refresh_rate=85;
% bit=(1/refresh_rate)/2;
% resp_time=0.1;
% fix_time=0.1;
% onset_delay = 0.1;
% disp_time=0.1;
% inter_trial=0.1;
% rest_time=30;   %rest time between blocks


exit_flag = 0;

% enable Alpha-Blending
Screen('BlendFunction',window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% images to make textures
[bird_l,~,alpha] = imread('bird_l.png');
bird_l(:,:,4)=alpha(:,:);
[bird_r,~,alpha] = imread('bird_r.png');
bird_r(:,:,4)=alpha(:,:);


[fish_l,~,alpha] = imread('fish_d_l.png');
fish_l(:,:,4)=alpha(:,:);
[fish_r,~,alpha] = imread('fish_d_r.png');
fish_r(:,:,4)=alpha(:,:);

[t_fish_l,~,alpha] = imread('fish_t_l.png');
t_fish_l(:,:,4)=alpha(:,:);
[t_fish_r,~,alpha] = imread('fish_t_r.png');
t_fish_r(:,:,4)=alpha(:,:);

background = imread('background.png');


bird_l = Screen('MakeTexture',window,bird_l);
bird_r = Screen('MakeTexture', window, bird_r);
fish_d_l = Screen('MakeTexture', window, fish_l);
fish_d_r = Screen('MakeTexture', window, fish_r);
fish_t_l = Screen('MakeTexture', window, t_fish_l);
fish_t_r = Screen('MakeTexture', window, t_fish_r);

bg = Screen('MakeTexture', window, background);


fish_width = 56;
fish_height = 26;
bird_width = 56;
bird_height = 30;

% maximum stimuli
% based on the grid

xcells = 10;
ycells = 10;

jitterx = 12;
jittery = 12;

max_birds = (xcells*ycells)/2 - xcells;
% max_fishes = (xcells*ycells)/2;
max_stim = xcells * ycells;





%% Experiment conditions %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

bird_ss = [0, 4, 8, 16];
fish_ss = [0, 4, 8, 16];

total_trials = 720;
ib_trials = 2;
total_practice_trials = length(bird_ss) * length(fish_ss);
total_blocks = 9;
trials_per_block_per_cell = total_trials / total_blocks / (length(bird_ss) * length(fish_ss));

design = repmat(struct('block', 0, 'tid', 0, 'tloc', 0, 'fish_setsize', 0,...
    'bird_setsize', 0, 'fish_locs', 0, 'bird_locs', 0, 'fish_ids', 0, 'bird_ids', 0, 'fish_rotations', 0, 'bird_rotations', 0), 1, total_trials + ib_trials);

master_table = design;


%% Variables to store data %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Trial = ones(total_trials + ib_trials, 1) * (-1);
T_ID = ones(total_trials + ib_trials, 1) * (-1);
Resp = ones(total_trials + ib_trials, 1) * (-1);
Error = ones(total_trials + ib_trials, 1) * (-1);
RT = ones(total_trials + ib_trials, 1) * (-1);
Fix_onset = ones(total_trials + ib_trials, 1) * (-1);
Disp_onset = ones(total_trials + ib_trials, 1) * (-1);

% create master data table
count = 0;
for i = 1:trials_per_block_per_cell
    
    % do this five times for each block
    for block = 1:total_blocks
        % cross all the conditions (bird x fish ss)
        for b = 1:length(bird_ss)
            for f = 1:length(fish_ss)
                trial = f + count;
                
                % fill the table
                master_table(trial).bird_setsize = bird_ss(b);
                master_table(trial).fish_setsize = fish_ss(f);
                master_table(trial).block = block;
                tloc = randsample(max_birds+21 : max_stim, 1);
                master_table(trial).tloc = tloc;
                master_table(trial).bird_locs = randsample(1:max_birds, bird_ss(b));
                master_table(trial).fish_locs = randsample(setdiff(max_birds+21 : max_stim, tloc), fish_ss(f)); %exclude tloc
                master_table(trial).bird_ids = round(rand(bird_ss(b)));
                master_table(trial).fish_ids = round(rand(fish_ss(f)));
                master_table(trial).bird_rotations = (15).*rand(bird_ss(b),1) + 15;
                master_table(trial).fish_rotations = (15).*rand(fish_ss(f),1) + 15;
                
            end
            
            % increase count by the number of rows added
            count = count+length(fish_ss);
            
        end
        
        
        
    end
    
end
% 
% % create trials for IB
% for t = 1:ib_trials
%     
%     for b = 1:bird_ss(3)
%         for f = 1:fish_ss(3)
%             
%             master_table(total_trials + t).bird_setsize = bird_ss(3);
%             master_table(total_trials + t).fish_setsize = fish_ss(3);
%             master_table(total_trials + t).block = block;
%             tloc = randsample(max_birds+21 : max_stim, 1);
%             ib_stim = randsample(1:max_birds, 1); % randomly select one bird to become a fish
%             master_table(total_trials + t).tloc = tloc;
%             master_table(total_trials + t).bird_locs = randsample(setdiff(1:max_birds, ib_stim), bird_ss(3));
%             master_table(total_trials + t).fish_locs = randsample(setdiff(max_birds+21 : max_stim, tloc), fish_ss(3)); %exclude tloc
%             master_table(total_trials + t).bird_ids = round(rand(1, bird_ss(3)));
%             master_table(total_trials + t).fish_ids = round(rand(1, fish_ss(3)));
%             master_table(total_trials + t).bird_rotations = (15).*rand(bird_ss(3),1) + 15;
%             master_table(total_trials + t).fish_rotations = (15).*rand(fish_ss(3),1) + 15;
%             master_table(total_trials + 2).ib = ib_stim;
%             
%             
%         end
%         
%     end
%     
%     
%     
% end




%% Instructions %%
%%%%%%%%%%%%%%%%%%


inst_1 = ['Welcome! \n\n'...
    'This is a visual search experiment. \n\n'...
    'You will be searching for an orange colored fish among some other fishes and birds \n\n'...
    'Your task is to decide which direction the orange fish is facing. \n\n'...
    'You will see examples next. \n\n'];

inst_2 = ['Please press the LEFT arrow key if the fish is facing left \n\n\n\n\n\n\n\n\n'...
    'Press the LEFT arrow key to continue'];

inst_3 = ['Please press the RIGHT arrow key if the fish is facing right \n\n\n\n\n\n\n\n'...
    'Press the RIGHT arrow key to continue'];

practice_inst = ['We will begin with some practice trials.\n\n'...
    'Please try to respond as quickly and as accurately as possible \n\n'...
    'Get ready!'];

start_inst = ['Now the test phase will begin. \n\n'...
    'Your response data will be recorded for our analysis. \n\n'...
    'Please try to respond as quickly and as accurately as possible \n\n\n\n'...
    'Hit the SPACEBAR to begin.'];

rest_inst = ['Please take a short break. Rest your eyes and hands for a bit. \n\n' ...
    'You will have up to ' num2str(rest_time) ' seconds to rest. \n\n'...
    'You can press any key to end the break and continue the experiment. \n\n'];

finish_message = ['We have come to the end of the experiment! \n\n'...
    'Thank you for your participation! \n\n'...
    'You may leave the room now.'];

abort_message = 'The experiment was manually aborted. \n\nPlease notify the experimenter.';


% Welcome instructions
Screen('TextSize',window,14);
DrawFormattedText(window, inst_1, 'center', 'center', white);
vbl=Screen('Flip',window);

while KbCheck
end
understood = [];

while isempty(understood)
    [keyIsDown, KbTime, keyCode] = KbCheck;
    if keyIsDown
        understood = find(keyCode);
        understood = understood(1);
    end
    if ~isempty(understood)
        if understood(1)==startKey
            break
        else understood=[];
        end
        
    end
end

% locations of fish for example on instructions screen
fish_x_l = Xcentre-30;
fish_x_r = Xcentre+30;
fish_y_u = Ycentre+10;
fish_y_d = Ycentre+40;

%% Left example
Screen('TextSize',window,14);
DrawFormattedText(window,inst_2,'center', 'center', white);
Screen('DrawTexture', window, fish_t_l, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);

Screen('Flip',window);

% Wait until understanding confirmation
while KbCheck
end
understood = [];

while isempty(understood)
    [down, secs, keyCode] = KbCheck;
    
    if keyCode(LeftKey)
        understood = 'yes';
    end
end
while KbCheck end


vbl=Screen('Flip',window);

%% Right example
Screen('TextSize',window,14);
DrawFormattedText(window,inst_3,'center', 'center', white);
Screen('DrawTexture', window, fish_t_r, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);

Screen('Flip',window);

% Wait until understanding confirmation

while KbCheck
end
understood = [];

while isempty(understood)
    [down, secs, keyCode] = KbCheck;
    
    if keyCode(RightKey)
        understood = 'yes';
    end
end
while KbCheck end

vbl=Screen('Flip',window);



%% PRACTICE %%
%%%%%%%%%%%%%%


% create practice table
count = 0;

practice_table = design;

% cross all the conditions (bird x fish ss)
for b = 1:length(bird_ss)
    for f = 1:length(fish_ss)
        trial = f + count;
        
        % fill the table
        practice_table(trial).bird_setsize = bird_ss(b);
        practice_table(trial).fish_setsize = fish_ss(f);
        practice_table(trial).block = block;
        tloc = randsample(max_birds+21 : max_stim, 1);
        practice_table(trial).tloc = tloc;
        practice_table(trial).bird_locs = randsample(1:max_birds, bird_ss(b));
        practice_table(trial).fish_locs = randsample(setdiff(max_birds+21 : max_stim, tloc), fish_ss(f)); %exclude tloc
        practice_table(trial).bird_ids = round(rand(bird_ss(b)));
        practice_table(trial).fish_ids = round(rand(fish_ss(f)));
        practice_table(trial).bird_rotations = (15).*rand(bird_ss(b),1) + 15;
        practice_table(trial).fish_rotations = (15).*rand(fish_ss(f),1) + 15;
        
    end
    
    % increase count by the number of rows added
    count = count+length(fish_ss);
    
end

% remove empty rows
practice_table(:, (b*f)+1:end) = [];

% shuffle practice table
practice_table = Shuffle(practice_table);


% Practice instructions

Screen('TextSize',window,14);
DrawFormattedText(window, practice_inst, 'center', 'center', white);
Screen('Flip', window);

while KbCheck
end
understood = [];

while isempty(understood)
    [keyIsDown, KbTime, keyCode] = KbCheck;
    if keyIsDown
        understood = find(keyCode);
        understood = understood(1);
    end
    if ~isempty(understood)
        if understood(1)==startKey
            break
        else understood=[];
        end
        
    end
end
Screen('Flip', window);
WaitSecs(2);

% Start practice

practice_table = struct2table(practice_table);

for p = 1:total_practice_trials
    iti = inter_trial + rand*0.2;
    practice_table.tid(p) = round(rand(1));
    
    
    % draw fixation
    Screen('DrawLine',window,white,Xcentre-15,Ycentre,Xcentre+15,Ycentre,2);
    Screen('DrawLine',window,white,Xcentre,Ycentre-15,Xcentre,Ycentre+15,2);
    
    % get the flip time
    vbl = Screen('Flip',window,vbl+iti-bit);
    vbl = Screen('Flip',window,vbl+fix_time-bit);
    Screen('DrawTexture', window, bg);
    
    % draw target
    
    loc = practice_table.tloc(p);
    %     griddy(loc);
    grid(loc, xcells, ycells, jitterx, jittery, Xcentre, Ycentre);
    tempx = cx;
    tempy = cy;
    
    %     fish_x_l = cx + 30;
    %     fish_x_r = cx + 90;
    %     fish_y_u = cy + 15;
    %     fish_y_d = cy + 45;
    
    fish_x_l = cx - (fish_width/2);
    fish_x_r = cx + (fish_width/2);
    fish_y_u = cy - (fish_height/2);
    fish_y_d = cy + (fish_height/2);
    
    if practice_table.tid(p) == 0
        Screen('DrawTexture', window, fish_t_l, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
    else
        Screen('DrawTexture', window, fish_t_r, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
    end
    
    %% draw birds
    for b = 1:practice_table.bird_setsize(p)
        loc = practice_table.bird_locs{p}(b);
        rotation = practice_table.bird_rotations{p}(b);
        %         griddy(loc);
        grid(loc, xcells, ycells, jitterx, jittery, Xcentre, Ycentre);
        tempx = cx;
        tempy = cy;
        
        bird_x_l = cx - (bird_width/2);
        bird_x_r = cx + (bird_width/2);
        bird_y_u = cy - (bird_height/2);
        bird_y_d = cy + (bird_height/2);
        
        if practice_table.bird_ids{p}(b) == 0
            Screen('DrawTexture', window, bird_l, [], [bird_x_l bird_y_u bird_x_r bird_y_d]);
        else
            Screen('DrawTexture', window, bird_r, [], [bird_x_l bird_y_u bird_x_r bird_y_d]);
        end
        
    end
    
    % draw fishes
    fishes_this_trial = practice_table.fish_locs(p);
    for f = 1:practice_table.fish_setsize(p)
        
        loc = practice_table.fish_locs{p}(f);
        rotation = practice_table.fish_rotations{p}(f);
        %         griddy(loc);
        grid(loc, xcells, ycells, jitterx, jittery, Xcentre, Ycentre);
        
        tempx = cx;
        tempy = cy;
        
        fish_x_l = cx - (fish_width/2);
        fish_x_r = cx + (fish_width/2);
        fish_y_u = cy - (fish_height/2);
        fish_y_d = cy + (fish_height/2);
        
        if practice_table.fish_ids{p}(f) == 0
            Screen('DrawTexture', window, fish_d_l, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
        else
            Screen('DrawTexture', window, fish_d_r, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
        end
        
    end
    
    
    
    vbl=Screen('Flip',window,vbl+onset_delay-bit);
    t0 = vbl;  % stimuli onset time
    
    % response detection
    flag = 0;
    while flag == 0
        [key, secs,keyCode]=KbCheck;
        if keyCode(LeftKey)||keyCode(RightKey)||keyCode(escKey)
            flag=1;
            t1=GetSecs;
        elseif (GetSecs-t0)> disp_time
            flag=2;  % response time out
        end
    end
    
    vbl = Screen('Flip',window);
    
    if keyCode(escKey)
        exit_flag = 1;
    end
    %
    if exit_flag
        break;
    end
    
    
    if flag == 1
        if keyCode(LeftKey)
            resp = 0;
        elseif keyCode(RightKey)
            resp = 1;
        end
        
        if resp ~= practice_table.tid(p)
            makeBeep(750, 0.25);
        end
        
    elseif flag == 2
        makeBeep(750,0.25);
    end
    
    
    
    Screen('Flip',window);
    
    if exit_flag
        break;
    end
    
    
end

%% END PRACTICE %%
%%%%%%%%%%%%%%%%%



Screen('TextSize',window,14);
DrawFormattedText(window, start_inst, 'center', 'center', white);
Screen('Flip', window);

while KbCheck
end
understood = [];

while isempty(understood)
    [keyIsDown, KbTime, keyCode] = KbCheck;
    if keyIsDown
        understood = find(keyCode);
        understood = understood(1);
    end
    if ~isempty(understood)
        if understood(1)== KbName('space');
            break
        else understood=[];
        end
        
    end
end
Screen('Flip', window);
WaitSecs(2);

%%% RUN
master_table = struct2table(master_table);

data_table = table();

t_id = vertcat(zeros(total_trials/total_blocks/2, 1), ones(total_trials/total_blocks/2,1));
for block = 1:total_blocks
    
    
    block_table = master_table(master_table.block == block, :);
    trial_order_rand = randperm(height(block_table));
    block_table = block_table(trial_order_rand', :);
    t_id_rand = randperm(length(t_id));
    
    for trial = trial_order_rand
        block_table.tid(trial) = t_id(t_id_rand(trial));
    end
    
    data_table = [data_table; block_table;];
    
    
    %% display shit
    for t = 1:height(block_table)
        
        iti = inter_trial + rand*0.2;
        trial = t + (1 * (block-1));
        trial = t + ((total_trials/total_blocks) * (block-1));
        Trial(trial) = trial;
        % draw fixation
        Screen('DrawLine',window,white,Xcentre-15,Ycentre,Xcentre+15,Ycentre,2);
        Screen('DrawLine',window,white,Xcentre,Ycentre-15,Xcentre,Ycentre+15,2);
        
        
        % get the flip time
        vbl = Screen('Flip',window,vbl+iti-bit);
        Fix_onset(trial) = vbl;
        vbl = Screen('Flip',window,vbl+fix_time-bit);
        
        Screen('DrawTexture', window, bg);
        
        % draw target
        
        loc = block_table.tloc(t);
        %         griddy(loc);
        grid(loc, xcells, ycells, jitterx, jittery, Xcentre, Ycentre);
        tempx = cx;
        tempy = cy;
        
        fish_x_l = cx - (fish_width/2);
        fish_x_r = cx + (fish_width/2);
        fish_y_u = cy - (fish_height/2);
        fish_y_d = cy + (fish_height/2);
        
        if block_table.tid(t) == 0
            Screen('DrawTexture', window, fish_t_l, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
        else
            Screen('DrawTexture', window, fish_t_r, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
        end
        
        %% draw birds
        for b = 1:block_table.bird_setsize(t)
            loc = block_table.bird_locs{t}(b);
            rotation = block_table.bird_rotations{t}(b);
            %             griddy(loc);
            grid(loc, xcells, ycells, jitterx, jittery, Xcentre, Ycentre);
            tempx = cx;
            tempy = cy;
            
            bird_x_l = cx - (bird_width/2);
            bird_x_r = cx + (bird_width/2);
            bird_y_u = cy - (bird_height/2);
            bird_y_d = cy + (bird_height/2);
            
            if block_table.bird_ids{t}(b) == 0
                Screen('DrawTexture', window, bird_l, [], [bird_x_l bird_y_u bird_x_r bird_y_d]);
            else
                Screen('DrawTexture', window, bird_r, [], [bird_x_l bird_y_u bird_x_r bird_y_d]);
            end
            
        end
        
        % draw fishes
        fishes_this_trial = block_table.fish_locs(t);
        for f = 1:block_table.fish_setsize(t)
            
            loc = block_table.fish_locs{t}(f);
            rotation = block_table.fish_rotations{t}(f);
            %             griddy(loc);
            grid(loc, xcells, ycells, jitterx, jittery, Xcentre, Ycentre);
            tempx = cx;
            tempy = cy;
            
            fish_x_l = cx - (fish_width/2);
            fish_x_r = cx + (fish_width/2);
            fish_y_u = cy - (fish_height/2);
            fish_y_d = cy + (fish_height/2);
            
            if block_table.fish_ids{t}(f) == 0
                Screen('DrawTexture', window, fish_d_l, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
            else
                Screen('DrawTexture', window, fish_d_r, [], [fish_x_l fish_y_u fish_x_r fish_y_d]);
            end
            
        end
        
        
        
        
        vbl=Screen('Flip',window,vbl+onset_delay-bit);
        t0 = vbl;  % stimuli onset time
        Disp_onset(trial) = t0;
        
        
        im=Screen('GetImage',window, rect); %% Gavin--here is the start of the relevant code
        % f=[pwd '\' int2str(subject_id) '\' int2str(trial) '.png'];
        f = [pwd '\' int2str(subject_id) '_' int2str(trial) '.png'];
        imwrite(im,f,'PNG'); % JPEG saved... not sure if JPEG is the best for you or not--you could probably save as a .gif or something else that might keep the fidelity high
        %
        % response detection
        flag = 0;
        while flag == 0
            [key, secs,keyCode]=KbCheck;
            if keyCode(LeftKey)||keyCode(RightKey)||keyCode(escKey)
                flag=1;
                t1=GetSecs;
                
            elseif (GetSecs-t0)> disp_time
                flag=2;  % response time out
            end
        end
        
        vbl = Screen('Flip',window);
        
        if keyCode(escKey)
            exit_flag = 1;
        end
        %
        if exit_flag
            break;
        end
        
        
        if flag == 1
            RT(trial) = (t1-t0)*1000;
            
            if keyCode(LeftKey)
                Resp(trial)=0;
            elseif keyCode(RightKey)
                Resp(trial)=1;
            end
            
            if Resp(trial) == block_table.tid(t)
                Error(trial) = 0;
            else
                Error(trial) = 1;
                makeBeep(750,0.25);
            end
            
            
        elseif flag == 2
            
            RT(trial) = resp_time*1000;
            makeBeep(750,0.25);
            
        end
        Screen('Flip',window);
        
        
    end
    
    if exit_flag
        break;
    end
    
    
    % end of block
    if block~=total_blocks  % not the last block, do rest period
        DrawFormattedText(window,rest_inst,'center','center',[255 255 255]);
        Screen('Flip',window);
        
        WaitSecs(1);
        tt=GetSecs;
        flag=0;
        while (flag==0) && (GetSecs-tt)<rest_time
            [key,secs,keyCode]=KbCheck;
            if key
                flag=1;
            end
        end
        
        Screen('Flip',window);
        
        WaitSecs(2);
        vbl=Screen('Flip',window);
        
    end
    
end

%% IB



if exit_flag
    % the experiment was aborted
    Screen('Flip',window);
    DrawFormattedText(window,abort_message,'center','center',white, 100, 0, 0, 2);
    Screen('Flip',window);
    
    
    while KbCheck
    end
    move_on = [];
    
    while isempty(move_on)
        [keyIsDown, KbTime, keyCode] = KbCheck;
        if keyIsDown
            move_on = find(keyCode);
            move_on = move_on(1);
        end
        if ~isempty(move_on)
            if move_on(1)==startKey
                break
            else move_on=[];
            end
            
        end
    end
end


% display end message
DrawFormattedText(window, finish_message, 'center', 'center', [255 255 255]);
Screen('Flip', window);


%% SAVE DATA %%
%%%%%%%%%%%%%%%


sub_id = repmat(subject_id, size(RT));


% pad the data_table if experiment was aborted
% data_table = vertcat(data_table, struct2table(repmat(design, total_trials - height(data_table), 1)));

% combine the data storing variables
% and make it the same height as the data table (in case expt was aborted)
data_vars = table(sub_id, Trial, RT, Resp, Error, Fix_onset, Disp_onset);
data_vars([height(data_table)+1 : end], :) = [];

% remove unecessary columns from data table
data_table_1 = data_table;
data_table_1(:, 6:end) = [];

data_table_out = [data_vars data_table_1];



% data_table_out = sortrows(data_table_out, 2);
%
filename = ['FSS_pilot', num2str(subject_id), '.csv'];
writetable(data_table_out, filename, 'Delimiter', ',');


DrawFormattedText(window, finish_message, 'center', 'center', [255 255 255]);
Screen('Flip', window);

while KbCheck
    end
    move_on = [];
    
    while isempty(move_on)
        [keyIsDown, KbTime, keyCode] = KbCheck;
        if keyIsDown
            move_on = find(keyCode);
            move_on = move_on(1);
        end
        if ~isempty(move_on)
            if move_on(1)==startKey
                break
            else move_on=[];
            end
            
        end
    end
    
sca;
return;


