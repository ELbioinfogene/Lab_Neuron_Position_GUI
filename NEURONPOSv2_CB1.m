%NeuronPosGUIv2 Callback 1
%Eric Larsen 2021
%Albrecht Lab @ WPI
%Callback functions for 'NeuronPosGUIv2':
    %Initializes loading of image folder and settings text
    %Manually loads a frame from drop down menu parameters (called by CB2)

%%% Initializing load of experiment image folder and settings.txt
STARTLOADING=get(SELECTIMAGES,'value');
if STARTLOADING==1
    %Ask user to select image folder
    IMAGEpath = uigetdir('','Select Folder of Organized Well Images');
    IMAGElisting = dir(IMAGEpath);
    %remove 'junk' entries from this structure
    IMAGElisting = IMAGElisting(~ismember({IMAGElisting.name},{'.','..','.DS_Store','Thumbs.db'}));
    %Get General Experiment Folder where settings.txt and neuronPos should
    %be
    folderbreak=strfind(IMAGEpath,'\');
    [~,LASTF]=size(folderbreak);
    generaldatapath=IMAGEpath(1:folderbreak(LASTF));
    %%%
    %Prompt User to select settings.txt - load it as a list of numbers
    [EXPFILE, EXPPATH, txtindex] = uigetfile([generaldatapath,'\*.txt'],'Select Experiment Settings Text');
    fid = fopen([EXPPATH,EXPFILE]);
    SETTINGSREAD = textscan(fid,'%s','delimiter', ',');
    fclose(fid);
    settings = str2double([SETTINGSREAD{:}]);
    %%%
    %Build info from settings.txt
    columnsimaged=settings(12);
    rowsimaged=settings(13);
    %number of wells
    welltotal = rowsimaged*columnsimaged;
    %MAKE LIST OF WELLS
    welllisting = cell(welltotal);
    for w=1:1:welltotal
        wellname = ['Well_',sprintf('%03d',w)];
        welllisting{w} = wellname;
    end
    %%%
    %Get Number of Cycles
    Cycles = settings(15);
    %MAKE LIST of CYCLES
    cyclelisting=cell(Cycles);
    for c=1:1:Cycles
        cyclename = ['Cycle_',int2str(c)];
        cyclelisting{c} = cyclename;
    end
    %%%
    %GET NUMBER OF TRIALS & MAKE LIST
    Trials = settings(4);
    triallisting=cell(Trials);
    for t=1:1:Trials
        trialname = ['Trial_',int2str(t)];
        triallisting{t} = trialname;
    end
    %%%
    %get number of frames per video & MAKE LIST
    FRAMESPERVID = settings(3);
    framelisting = cell(FRAMESPERVID);
    for f=1:1:FRAMESPERVID
        framename = ['Frame_',int2str(f)];
        framelisting{f} = framename;
    end
    %%%
    %get start and end frames of stimulus
    pulseStart = settings(18);
    pulseEnd = settings(20);
    %%%
    
    %get EXPERIMENT Date
    %10/19 TO DO - This is 'DUMB', uses folder name - should get it from
    %image files!
    [DATESTART,DATEEND]=regexp(IMAGEpath,'\d\d\d\d-\d\d-\d\d-\d\d-\d\d');
    EXPERIMENTDATE=IMAGEpath(DATESTART:DATEEND);
    EXPERIMENTNAME=['EXP_',EXPERIMENTDATE];
    %/\ TO DO
    
    %SHOW THIS TO THE USER
    set(EXPERIMENTDATEDISPLAY,'string',EXPERIMENTNAME);
    set(EXPERIMENTDATEDISPLAY,'enable','on');
    set(EXPERIMENTDATEDISPLAY,'visible','on');
    %%%
    
    %CREATE 1 WELLIMAGES OBJECT FOR EACH WELL
    for w=1:1:welltotal
        %create WELLIMAGES object
        wellname=welllisting{w};
        makeobjstring=[wellname,'=WELLIMAGES;'];
        eval(makeobjstring);
        paddedwellstring=sprintf('%03d',w);
        %get image folder from IMAGElisting
        IMAGEFOLDERQUERY = contains({IMAGElisting.name},paddedwellstring);
        IMAGEFOLDERINDEX=find(IMAGEFOLDERQUERY);
        IMAGEFOLDERADDRESS=[IMAGElisting(IMAGEFOLDERINDEX).folder,'\',IMAGElisting(IMAGEFOLDERINDEX).name];
        %Load Image Addresses into WELLIMAGES object
        objectimgdatastring=[wellname,'=',wellname,'.LOADWELLFOLDER(IMAGEFOLDERADDRESS,EXPERIMENTNAME,w,FRAMESPERVID,Cycles,Trials,pulseStart,pulseEnd);'];
        eval(objectimgdatastring);

    end
    %%%
    
    %Disable loading more data
    set(SELECTIMAGES,'enable','off');
    %%%
    
    %activate well, cycle, and view drop downs
    %duplicate welllisting (master list of WELLIMAGES objects)
    %this duplicate will be used for display list so the strings can be
    %modified to report the addition of position data
    DISPLAY_WELL_LIST = welllisting;
    set(WELL_SELECT,'string',DISPLAY_WELL_LIST);
    set(WELL_SELECT,'Visible','On');
    set(WELL_SELECT,'enable','on');
    set(CYCLE_SELECT,'string',cyclelisting);
    set(CYCLE_SELECT,'Visible','On');
    set(CYCLE_SELECT,'enable','on');
    set(TRIAL_SELECT,'string',triallisting);
    set(TRIAL_SELECT,'Visible','On');
    set(TRIAL_SELECT,'enable','on');
    set(FRAME_SELECT,'string',framelisting);
    set(FRAME_SELECT,'Visible','On');
    set(FRAME_SELECT,'enable','on');
    set(VIEW_SELECT,'Visible','On');
    set(VIEW_SELECT,'enable','on');
    set(WELL_ADVANCE,'Visible','On');
    set(WELL_ADVANCE,'enable','on');
    %Display Selection, saving, and loading Buttons
    set(INITIALIZE_NEURON_PICK,'Visible','On');
    set(INITIALIZE_NEURON_PICK,'enable','on');
    set(DENOTE_NULL_WELL,'Visible','On');
    set(DENOTE_NULL_WELL,'enable','on');
    set(SAVE_TO_FILE,'Visible','On');
    set(SAVE_TO_FILE,'enable','on');
    set(LOAD_EXISTING_POSITIONS,'Visible','On');
    set(LOAD_EXISTING_POSITIONS,'enable','on');
    %%%
    
    %AUTOMATICALLY DISPLAY AN IMAGE FROM THE FIRST WELL:
    INITIAL_WELL_IMAGE='[Well_001,INIT_IMAGE]=Well_001.frame_grabber(1,1,1,0);';
    eval(INITIAL_WELL_IMAGE)
    %Show the user the INIT_IMAGE which is 16 bit values on the 1st
    %everything
    IMAGEDISPLAY=imshow(INIT_IMAGE);
    set(IMAGEDISPLAY,'visible','on');
    %SHOW USER MANUAL FRAME LOAD BUTTON
    set(FRAME_ON_DEMAND,'Visible','On');
    set(FRAME_ON_DEMAND,'enable','on');
    %%%
    
    %Display feedback to user
    %What frame is being displayed
    INIT_FRAME_STRING='Displaying Well 1;Cycle 1;Trial 1;Frame 1';
    set(THIS_FRAME_DISPLAY,'string',INIT_FRAME_STRING);
    set(THIS_FRAME_DISPLAY,'visible','on');
    %What is the stimulus frame interval?
    STIMULUS_WINDOW_STRING=['Stimulus begins @ ',num2str(pulseStart),', and ends @ ',num2str(pulseEnd)];
    set(STIM_WINDOW_DISPLAY,'string',STIMULUS_WINDOW_STRING);
    set(STIM_WINDOW_DISPLAY,'visible','on');
    %%%
    
end
%end of INITIAL loading loop

%%%
%Manual frame load loop
PULL_FRAME = get(FRAME_ON_DEMAND,'value');
if PULL_FRAME ==1
    %Disable all controls (drop downs and buttons)
    %BUTTONS
    set(FRAME_ON_DEMAND,'enable','off');
    set(INITIALIZE_NEURON_PICK,'enable','off');
    set(WELL_ADVANCE,'enable','off');
    set(DENOTE_NULL_WELL,'enable','off');
    set(SAVE_TO_FILE,'enable','off');
    set(LOAD_EXISTING_POSITIONS,'enable','off');
    set(MODIFY_ENTRY,'enable','off');
    %DROPDOWNS
    set(WELL_SELECT,'enable','off');
    set(CYCLE_SELECT,'enable','off');
    set(TRIAL_SELECT,'enable','off');
    set(FRAME_SELECT,'enable','off');
    set(VIEW_SELECT,'enable','off');
    set(DISPLAY_ANIMAL_LIST,'enable','off');
    %TABLE - VISIBILITY ONLY
    set(NEURONPOSTABLE,'visible','off');
    %%%
    
    %show the user the specified image
    WELL_NUMBER = get(WELL_SELECT,'value');
    OBJECT_NAME = welllisting{WELL_NUMBER};
    CYCLE_NUMBER = get(CYCLE_SELECT,'value');
    TRIAL_NUMBER = get(TRIAL_SELECT,'value');
    FRAME_NUMBER = get(FRAME_SELECT,'value');
    VIEW_TYPE = get(VIEW_SELECT,'value');
    GRAB_WELL_IMAGE=['[',OBJECT_NAME,',MANUAL_IMAGE]=',OBJECT_NAME,'.frame_grabber(CYCLE_NUMBER,TRIAL_NUMBER,FRAME_NUMBER,VIEW_TYPE-1);'];
    eval(GRAB_WELL_IMAGE)
    %Show the user the MANUAL_IMAGE
    IMAGEDISPLAY=imshow(MANUAL_IMAGE);
    set(IMAGEDISPLAY,'visible','on');
    %%%
    
    %User Display
    %What exact image is being displayed
    GRAB_OBJECT_WELL=['OBJECT_WELL=num2str(',OBJECT_NAME,'.wellID);'];
    GRAB_OBJECT_CYCLE=['OBJECT_CYCLE=num2str(',OBJECT_NAME,'.present_cycle);'];
    GRAB_OBJECT_TRIAL=['OBJECT_TRIAL=num2str(',OBJECT_NAME,'.present_trial);'];
    GRAB_OBJECT_FRAME=['OBJECT_FRAME=num2str(',OBJECT_NAME,'.present_frame);'];
    eval(GRAB_OBJECT_WELL)
    eval(GRAB_OBJECT_CYCLE)
    eval(GRAB_OBJECT_TRIAL)
    eval(GRAB_OBJECT_FRAME)
    THIS_FRAME_STRING=['Displaying Well ',OBJECT_WELL,';Cycle ',OBJECT_CYCLE,';Trial ',OBJECT_TRIAL, ';Frame ',OBJECT_FRAME];
    set(THIS_FRAME_DISPLAY,'string',THIS_FRAME_STRING);
    %What is the stimulus frame interval?
    %Error check from object
    GET_STIM_START = ['PULL_STIM_START = ',OBJECT_NAME,'.STIMSTART;'];
    GET_STIM_END = ['PULL_STIM_END = ',OBJECT_NAME,'.STIMEND;'];
    eval(GET_STIM_START);
    eval(GET_STIM_END);
    if PULL_STIM_START~=pulseStart || PULL_STIM_END~=pulseEnd
        print('/!\UNEXPECTED: CHANGE IN STIMULUS INTERVAL/!\')
    end
    %User Display of stimulus winow
    STIMULUS_WINDOW_STRING=['Stimulus begins @ ',num2str(PULL_STIM_START),', and ends @ ',num2str(PULL_STIM_END)];
    set(STIM_WINDOW_DISPLAY,'string',STIMULUS_WINDOW_STRING);
    %%%
    
    %Displaying position data is the WELLIMAGES already has some
    %blank out display table
    set(NEURONPOSTABLE,'data',dummynum);
    set(DISPLAY_ANIMAL_LIST,'string',{0});
    set(DISPLAY_ANIMAL_LIST,'value',1);
    OBJECT_POSITION_QUERY = ['OBJECT_POSITION_BOOL=',OBJECT_NAME,'.POSLOADED;'];
    eval(OBJECT_POSITION_QUERY);
    if OBJECT_POSITION_BOOL==1
        %is the position a NULL set?
        OBJECT_NULL_QUERY = ['OBJECT_NULL_BOOL=',OBJECT_NAME,'.IS_NULL;'];
        eval(OBJECT_NULL_QUERY);
        %if not null, load position data for display
        if OBJECT_NULL_BOOL==0
            %Draw boxes on image
            DRAW_NEURON_HIGHLIGHT = ['WELL_NEURON_HIGHLIGHT(',OBJECT_NAME,');'];
            eval(DRAW_NEURON_HIGHLIGHT);
            %%%
            %Load Data into NEURONPOSTABLE
            GET_POSITION_ARRAY = ['POSITION_ARRAY=',OBJECT_NAME,'.POSITION_DISPLAY;'];
            eval(GET_POSITION_ARRAY);
            set(NEURONPOSTABLE,'data',POSITION_ARRAY)
            set(NEURONPOSTABLE,'visible','on');
            set(MODIFY_ENTRY,'visible','on');
            set(DISPLAY_ANIMAL_LIST,'visible','on');
            %%%
            %Load list of animals to DISPLAY_ANIMAL_LIST
            GET_ANIMAL_COUNT = ['ANIMAL_COUNT=',OBJECT_NAME,'.ANIMALS;'];
            eval(GET_ANIMAL_COUNT);
            UI_ANIMAL_LIST = cell(ANIMAL_COUNT);
            for A = 1:1:ANIMAL_COUNT
                UI_ANIMAL_LIST{A} = A;
            end
            %reset the DISPLAY_ANIMAL_LIST
            set(DISPLAY_ANIMAL_LIST,'string',UI_ANIMAL_LIST);
            set(DISPLAY_ANIMAL_LIST,'value',1);
            %%% 
        end
        %if null, display this to the user
        if OBJECT_NULL_BOOL==1
            %Load Data into NEURONPOSTABLE
            GET_POSITION_ARRAY = ['POSITION_ARRAY=',OBJECT_NAME,'.POSITION_DISPLAY;'];
            eval(GET_POSITION_ARRAY);
            set(NEURONPOSTABLE,'data',POSITION_ARRAY)
            %%%
            %reset the DISPLAY_ANIMAL_LIST
            set(DISPLAY_ANIMAL_LIST,'string',{0});
            set(DISPLAY_ANIMAL_LIST,'value',1);
        end
    end
    %%%
    %Conditional button condition
    if OBJECT_POSITION_BOOL==1 && OBJECT_NULL_BOOL==0
        set(MODIFY_ENTRY,'enable','on');
        set(DISPLAY_ANIMAL_LIST,'enable','on');
        %TABLE - VISIBILITY ONLY
        set(NEURONPOSTABLE,'visible','on');
    end
    %BUTTONS
    set(FRAME_ON_DEMAND,'enable','on');
    set(INITIALIZE_NEURON_PICK,'enable','on');
    set(WELL_ADVANCE,'enable','on');
    set(DENOTE_NULL_WELL,'enable','on');
    set(SAVE_TO_FILE,'enable','on');
    set(LOAD_EXISTING_POSITIONS,'enable','on');
    %DROPDOWNS
    set(WELL_SELECT,'enable','on');
    set(CYCLE_SELECT,'enable','on');
    set(TRIAL_SELECT,'enable','on');
    set(FRAME_SELECT,'enable','on');
    set(VIEW_SELECT,'enable','on');
end
%end of MANUAL FRAME PULL loop