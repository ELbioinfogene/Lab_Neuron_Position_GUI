%NeuronPosGUIv2 Callback 2
%Eric Larsen 2021
%Albrecht Lab @ WPI
%Callback functions for 'NeuronPosGUIv2':
    %Process for user to select neurons in the displayed frame
    %passes positions to the appropriate WELLIMAGES object
    
    %Process for user to mark a well as 'null' (no clear animals/neurons)
    %which is passed to the appropriate WELLIMAGES object
    
    %Process for user to update an animal (either deleting it entirely or
    %giving it a additional specific position)

%User wants to pick neurons (adding additional animals)
SELECTION_RUN = get(INITIALIZE_NEURON_PICK,'value');
if SELECTION_RUN==1
    %Disable all other controls (drop downs and buttons)
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
    %%%
    
    %Show user table of position entries
    set(NEURONPOSTABLE,'Visible','on');

    %user 'click' loop - each left mouse press is an additional animal in
    %the frame - loop ends with ENTER key
    %Tell user about ENTER key
    set(SELECTMODEFINISHNOTE,'Visible','on');
    RETURNBUTTON=0;
    while RETURNBUTTON==0
        hold on
        [x,y,button] = ginput(1);
        %Detect Return button press to end WHILE loop
        if isempty(button)==1
            RETURNBUTTON=1;
        end
        %Detect Left Mouse Click
        if button==1
            %pass X,Y data to object method ADD_ANIMAL
            PASS_XY_DATA = ['[',OBJECT_NAME,',POSITION_ARRAY,UPDATED_FRAME]=',OBJECT_NAME,'.ADD_ANIMAL(x,y);'];
            eval(PASS_XY_DATA);
            IMAGEDISPLAY=imshow(UPDATED_FRAME);
            %Update User Display with array returned by WELLIMAGES.ADD_ANIMAL
            set(NEURONPOSTABLE,'data',POSITION_ARRAY)
            %Draw Neuron Boxes
            DRAW_NEURON_HIGHLIGHT = ['WELL_NEURON_HIGHLIGHT(',OBJECT_NAME,');'];
            eval(DRAW_NEURON_HIGHLIGHT);
        end
    end
    hold off
    %Stop telling user about ENTER key
    set(SELECTMODEFINISHNOTE,'Visible','off');
    %%%
    
    %Update List of animals for modification
    OBJECT_POSITION_QUERY = ['ANIMAL_COUNT=',OBJECT_NAME,'.ANIMALS;'];
    eval(OBJECT_POSITION_QUERY);
    UI_ANIMAL_LIST = cell(ANIMAL_COUNT);
    for A = 1:1:ANIMAL_COUNT
        UI_ANIMAL_LIST{A} = A;
    end
    %reset the DISPLAY_ANIMAL_LIST
    set(DISPLAY_ANIMAL_LIST,'string',UI_ANIMAL_LIST);
    set(DISPLAY_ANIMAL_LIST,'value',1);
    %%%
    
    %Trigger manual frame load button
    set(FRAME_ON_DEMAND,'value',1);
    eval('NEURONPOSv2_CB1');
    set(FRAME_ON_DEMAND,'value',0);
    %%%
    %enable all other controls (drops downs and buttons)
    %BUTTONS
    set(FRAME_ON_DEMAND,'enable','on');
    set(INITIALIZE_NEURON_PICK,'enable','on');
    set(WELL_ADVANCE,'enable','on');
    set(DENOTE_NULL_WELL,'enable','on');
    set(SAVE_TO_FILE,'enable','on');
    set(LOAD_EXISTING_POSITIONS,'enable','on');
    set(MODIFY_ENTRY,'enable','on');
    %DROPDOWNS
    set(WELL_SELECT,'enable','on');
    set(CYCLE_SELECT,'enable','on');
    set(TRIAL_SELECT,'enable','on');
    set(FRAME_SELECT,'enable','on');
    set(VIEW_SELECT,'enable','on');
    set(DISPLAY_ANIMAL_LIST,'enable','on');
    %%%
end
%end of Neuron Selection / animal addition loop
%%%

%User wants to add specific positions for an animal or delete it entirely
START_EDIT = get(MODIFY_ENTRY,'value');
if START_EDIT==1
    %get selected animal from list
    ANIMAL_TO_CHANGE = get(DISPLAY_ANIMAL_LIST,'value');
    %%%
    %Disable all other controls (drop downs and buttons)
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
    %%%
    
    %prompt user to left click a new location for the selected frame
    %or DELETE key to remove animal entirely
    %or end loop with ENTER key
    set(SELECTMODEFINISHNOTE,'Visible','on');
    set(EDIT_MODE_DELETE_NOTE,'Visible','on');
    RETURNBUTTON=0;
    while RETURNBUTTON==0
        hold on
        [x,y,button] = ginput(1);
        %Detect Return button press to end WHILE loop manually
        if isempty(button)==1
            RETURNBUTTON=1;
        end
        %Detect Left Mouse Click
        if button==1
            %pass X,Y data and ANIMAL ID# to object method UPDATE_ANIMAL
            UPDATE_XY_DATA = ['[',OBJECT_NAME,',POSITION_ARRAY,UPDATED_FRAME]=',OBJECT_NAME,'.UPDATE_ANIMAL(x,y,ANIMAL_TO_CHANGE);'];
            eval(UPDATE_XY_DATA);
            IMAGEDISPLAY=imshow(UPDATED_FRAME);
            set(NEURONPOSTABLE,'data',POSITION_ARRAY)
            %Draw Neuron Boxes
            DRAW_NEURON_HIGHLIGHT = ['WELL_NEURON_HIGHLIGHT(',OBJECT_NAME,');'];
            eval(DRAW_NEURON_HIGHLIGHT);
            %End while loop
            RETURNBUTTON=1;
        end
        %Detect 'DELETE' key (button 127) and remove all entries for animal
        if button==127
            REMOVE_ANIMAL = ['[',OBJECT_NAME,',POSITION_ARRAY,UPDATED_FRAME]=',OBJECT_NAME,'.REMOVE_ANIMAL(ANIMAL_TO_CHANGE);'];
            eval(REMOVE_ANIMAL)
            IMAGEDISPLAY=imshow(UPDATED_FRAME);
            set(NEURONPOSTABLE,'data',POSITION_ARRAY)
            %Draw Neuron Boxes
            DRAW_NEURON_HIGHLIGHT = ['WELL_NEURON_HIGHLIGHT(',OBJECT_NAME,');'];
            eval(DRAW_NEURON_HIGHLIGHT);
            %End while loop
            RETURNBUTTON=1;
        end
    end
    hold off
    %Hide user key prompts
    set(SELECTMODEFINISHNOTE,'Visible','off');
    set(EDIT_MODE_DELETE_NOTE,'Visible','off');
    %%%
    
    %Update List of animals for modification
    OBJECT_POSITION_QUERY = ['ANIMAL_COUNT=',OBJECT_NAME,'.ANIMALS;'];
    eval(OBJECT_POSITION_QUERY);
    %Animal list for display (0 if it is null or empty)
    if ANIMAL_COUNT==0
        UI_ANIMAL_LIST={0};
    else
        UI_ANIMAL_LIST = cell(ANIMAL_COUNT);
        for A = 1:1:ANIMAL_COUNT
            UI_ANIMAL_LIST{A} = A;
        end
    end
    %reset the DISPLAY_ANIMAL_LIST
    set(DISPLAY_ANIMAL_LIST,'string',UI_ANIMAL_LIST);
    set(DISPLAY_ANIMAL_LIST,'value',1);
    %%%
    %%%
    %Trigger manual frame load button
    set(FRAME_ON_DEMAND,'value',1);
    eval('NEURONPOSv2_CB1');
    set(FRAME_ON_DEMAND,'value',0);
    %%%
    %CONDITIONAL enable of drop downs and buttons
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
    %Condtional
    if ANIMAL_COUNT>0
        set(MODIFY_ENTRY,'enable','on');
        set(DISPLAY_ANIMAL_LIST,'enable','on');
    end
    
end
%End of edit/delete loop
%%%

%User is marking well as NULL (no clear animals or neurons)
%will automatically advance to next well
NULL_MARK = get(DENOTE_NULL_WELL,'value');
if NULL_MARK==1
    %Update User display and write 'null' positions/state to WELLIMAGES
    MAKE_NULL = [OBJECT_NAME,'=',OBJECT_NAME,'.MARK_NULL;'];
    eval(MAKE_NULL);
    %%%
    %Update list of Wells with *N* annotation
    %Get wellID
    GET_wellID = ['TAGGED_WELL=',OBJECT_NAME,'.wellID;'];
    eval(GET_wellID);
    DISPLAY_WELL_LIST{TAGGED_WELL}=[welllisting{TAGGED_WELL},'_*N*'];
    set(WELL_SELECT,'string',DISPLAY_WELL_LIST);
    %%%
    %load Next Well
    set(WELL_SELECT,'value',TAGGED_WELL+1);
    %Trigger manual frame load button
    set(FRAME_ON_DEMAND,'value',1);
    eval('NEURONPOSv2_CB1');
    set(FRAME_ON_DEMAND,'value',0);
end
%%%

%User is done with this well but is NOT saving anything to a file yet
%This will load the next well in the sequence
NEXT_STEP = get(WELL_ADVANCE,'value');
if NEXT_STEP==1
    THIS_WELL = get(WELL_SELECT,'value');
    %Update list of Wells with *P* annotation
    %Get wellID
    GET_wellID = ['TAGGED_WELL=',OBJECT_NAME,'.wellID;'];
    eval(GET_wellID);
    DISPLAY_WELL_LIST{TAGGED_WELL}=[welllisting{TAGGED_WELL},'_*P*'];
    set(WELL_SELECT,'string',DISPLAY_WELL_LIST);
    %%%
    %load Next Well
    set(WELL_SELECT,'value',THIS_WELL+1);
    %Trigger manual frame load button
    set(FRAME_ON_DEMAND,'value',1);
    eval('NEURONPOSv2_CB1');
    set(FRAME_ON_DEMAND,'value',0);
    %if this is the last well, disable WELL_ADVANCE
    if THIS_WELL+1==welltotal
        set(WELL_ADVANCE,'enable','off');
    end
end
%%%
