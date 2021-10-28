%NeuronPosGUIv2 Callback 3
%Eric Larsen 2021
%Albrecht Lab @ WPI
%Callback functions for 'NeuronPosGUIv2':
    %Saving positions in extant WELLIMAGES objects as neuronPos txt
    %files in an appropriate folder
    
    %loading existing neuronPos txt into WELLIMAGES objects for review and
    %modification

    %ONCE A FOLDER IS SET IT WILL BE OVERWRITTEN IN SUBSEQUENT SAVES UNLESS
    %A NEW ONE IS LOADED
    
%10/25 - WORKING
%User wants to Save Positions to File(s)
EXECUTE_SAVE = get(SAVE_TO_FILE,'value');
if EXECUTE_SAVE==1
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
    %TABLE - VISIBILITY ONLY
    set(NEURONPOSTABLE,'visible','off');
    %%%
    %First step is POS_START_FROM_SCRATCH true?
    if POS_START_FROM_SCRATCH==true
        %create new folder
        POSITIONpath = uigetdir(generaldatapath,'Create Folder for Position Files');
    end
    %write files from objects
    for W=1:1:welltotal
        %Get Object
        OBJECT_NAME = welllisting{W};
        %Does object have position data?
        POSITION_CHECK = ['POS_BOOL=',OBJECT_NAME,'.POSLOADED;'];
        eval(POSITION_CHECK);
        if POS_BOOL==1
            %create file name & address
            SAVENEURONPOSTEXTNAME=['neuronPos',num2str(W),'.txt'];
            SAVENEURONPOSTXTADDRESS=[POSITIONpath,'\',SAVENEURONPOSTEXTNAME];
            %Get digit array
            GET_POS_VALUES = ['DIGITINPUT=',OBJECT_NAME,'.POSITION_DISPLAY;'];
            eval(GET_POS_VALUES);
            DIGITINPUT = transpose(DIGITINPUT);
            TEXTFILEID=fopen(SAVENEURONPOSTXTADDRESS,'w');
            %write transposed array to text file
            fprintf(TEXTFILEID,'well %u x %u y %u a %u c %u t %u f %u\n',DIGITINPUT);
            %Close text file
            fclose(TEXTFILEID);
            %save file address in object
            RECORD_ADDRESS = [OBJECT_NAME,'.POSFILEADDRESS=SAVENEURONPOSTXTADDRESS;'];
            eval(RECORD_ADDRESS);
            %update list of wells with *S*
            DISPLAY_WELL_LIST{W}=[welllisting{W},'_*S*'];
        end
    end
    set(WELL_SELECT,'string',DISPLAY_WELL_LIST);
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
    %TABLE - VISIBILITY ONLY
    set(NEURONPOSTABLE,'visible','on');
    %%%
    %Last Step
    POS_START_FROM_SCRATCH = false;
    %%%
end
%%%


%10/25 WORKING
%User wants to Load Positions from File(s)
EXECUTE_LOAD = get(LOAD_EXISTING_POSITIONS,'value');
if EXECUTE_LOAD==1
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
    %TABLE - VISIBILITY ONLY
    set(NEURONPOSTABLE,'visible','off');
    %%%
    %First step
    POS_START_FROM_SCRATCH = false;
    %%%
    %PROMPT USER TO SELECT NEURONPOS FOLDER
    POSITIONpath = uigetdir(generaldatapath,'Select Folder of Position Files');
    POSITIONlisting = dir(POSITIONpath);
    %remove 'junk' entries
    POSITIONlisting = POSITIONlisting(~ismember({POSITIONlisting.name},{'.','..','.DS_Store','Thumbs.db'}));
    %test if position listing is complete (same# as wells), 
    %incomplete(less), or mismatched (more)
    [POSTOTAL,~]=size(POSITIONlisting);
    if POSTOTAL==welltotal
        for W=1:1:welltotal
            %read files to objects
            POSITIONFILEstring=['neuronPos',num2str(W),'.txt'];
            POSFILEQUERY = contains({POSITIONlisting.name},POSITIONFILEstring);
            POSFILEINDEX=find(POSFILEQUERY);
            POSFILEADDRESS=[POSITIONlisting(POSFILEINDEX).folder,'\',POSITIONlisting(POSFILEINDEX).name];
            OBJECT_NAME = welllisting{W};
            LOAD_POSITION_TO_OBJECT = [OBJECT_NAME,'=',OBJECT_NAME,'.LOADNEURONPOS(POSFILEADDRESS);'];
            eval(LOAD_POSITION_TO_OBJECT)
            %update list of wells with *L*
            DISPLAY_WELL_LIST{W}=[welllisting{W},'_*L*'];
        end
        set(WELL_SELECT,'string',DISPLAY_WELL_LIST);
    end
    
    if POSTOTAL<welltotal
        for P=1:1:POSTOTAL
            %read files to objects
            POSITIONFILEstring=['neuronPos',num2str(P),'.txt'];
            POSFILEQUERY = contains({POSITIONlisting.name},POSITIONFILEstring);
            POSFILEINDEX=find(POSFILEQUERY);
            POSFILEADDRESS=[POSITIONlisting(POSFILEINDEX).folder,'\',POSITIONlisting(POSFILEINDEX).name];
            OBJECT_NAME = welllisting{P};
            LOAD_POSITION_TO_OBJECT = [OBJECT_NAME,'=',OBJECT_NAME,'.LOADNEURONPOS(POSFILEADDRESS);'];
            eval(LOAD_POSITION_TO_OBJECT)
            %update list of wells with *L*
            DISPLAY_WELL_LIST{P}=[welllisting{P},'_*L*'];
        end
        set(WELL_SELECT,'string',DISPLAY_WELL_LIST);
    end
    
    if POSTOTAL>welltotal
        fprintf('Error - Too Many Position Files')
    end
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
    %TABLE - VISIBILITY ONLY
    set(NEURONPOSTABLE,'visible','on');
    %%%
end
%%%

%GENERAL INPUT DISABLE
%BUTTONS
% set(FRAME_ON_DEMAND,'enable','off');
% set(INITIALIZE_NEURON_PICK,'enable','off');
% set(WELL_ADVANCE,'enable','off');
% set(DENOTE_NULL_WELL,'enable','off');
% set(SAVE_TO_FILE,'enable','off');
% set(LOAD_EXISTING_POSITIONS,'enable','off');
% set(MODIFY_ENTRY,'enable','off');
%set(,'enable','off');
%DROPDOWNS
% set(WELL_SELECT,'enable','off');
% set(CYCLE_SELECT,'enable','off');
% set(TRIAL_SELECT,'enable','off');
% set(FRAME_SELECT,'enable','off');
% set(VIEW_SELECT,'enable','off');
% set(DISPLAY_ANIMAL_LIST,'enable','off');
%TABLE - VISIBILITY ONLY
% set(NEURONPOSTABLE,'visible','off');

%GENRAL INPUT ENABLE
%BUTTONS
% set(FRAME_ON_DEMAND,'enable','on');
% set(INITIALIZE_NEURON_PICK,'enable','on');
% set(WELL_ADVANCE,'enable','on');
% set(DENOTE_NULL_WELL,'enable','on');
% set(SAVE_TO_FILE,'enable','on');
% set(LOAD_EXISTING_POSITIONS,'enable','on');
% set(MODIFY_ENTRY,'enable','on');
%set(,'enable','on');
%DROPDOWNS
% set(WELL_SELECT,'enable','on');
% set(CYCLE_SELECT,'enable','on');
% set(TRIAL_SELECT,'enable','on');
% set(FRAME_SELECT,'enable','on');
% set(VIEW_SELECT,'enable','on');
% set(DISPLAY_ANIMAL_LIST,'enable','on');
%TABLE - VISIBILITY ONLY
% set(NEURONPOSTABLE,'visible','on');