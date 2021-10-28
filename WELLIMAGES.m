classdef WELLIMAGES
    %WELLIMAGES - object for storing wellplate image addresses AND neuronPos data
    %Eric Larsen 2020
    %Albrecht Lab @ WPI
    %Eric Larsen REVISED FALL 2021
        %Added functions for adding and removing animals and position data
        %(support for changing animal positions)
        %Redesigned position variable as a structure instead of a cell
        %Add function of returning a single frame from a specific Cycle and
        %Trial with specific optimizations

    properties
        %Object IDENTIFIERS
        wellID=0;
        FRAMES=0;
        CYCLES=0;
        TRIALS=0;
        STIMSTART=0;
        STIMEND=0;
        EXPERIMENT='';
        POPULATION=0;
        ANIMALS=0;
        %NEURON POSITION DATA STORAGE
        %10/17 - make this a MAP or a Structure? USE A STRUCTURE
        %Make One Structure per animal
        %'Super structure' that contains all animal structures (their size
        %will vary based on number of cycles used for selection)
        ANIMAL_POSITION_SUPER = struct;
        %Denote 'Null' (lack of discernible anaimals & neurons)
        IS_NULL=0;
        %For File Saving/loading
        POSFILEADDRESS='';
        POSLOADED=0;
        %Image Indices
        %DO NOT STORE BITMAPS IN THESE OBJECTS
        %Main Index - list of TIF file addresses in organized well folder
        IMGFOLDERADDRESS='';
        MINDEX={};
        %present_video: properties of most recently grabbed frame
        present_video = '';
        present_info = {};
        present_video_vertical=0;
        present_video_horizontal =0;
        present_cycle=0;
        present_trial=0;
        present_frame = 0;
        present_type = 0;
    end
    
    methods
        %Parse Folder of Images
        function obj = LOADWELLFOLDER(obj,folderaddress,EXPERIMENT,wellID,FRAMES,CYCLES,TRIALS,STIMSTART,STIMEND)
            %Parses a numbered well folder and saves the names of the
            %appropriate TIF files to obj.MINDEX
            %From Folder Address - Get a list of TIFF files - check names
            %against CYCLES and TRIALS
            obj.IMGFOLDERADDRESS=folderaddress;
            %If videos match cycles and trials load object with variables
            obj.wellID=wellID;
            obj.FRAMES=FRAMES;
            obj.CYCLES=CYCLES;
            obj.TRIALS=TRIALS;
            obj.STIMSTART=STIMSTART;
            obj.STIMEND=STIMEND;
            obj.EXPERIMENT=EXPERIMENT;
            %Load TIFF file addresses into MINDEX
            FILELIST=dir(folderaddress);
            %remove Junk entries from structure
            FILELIST = FILELIST(~ismember({FILELIST.name},{'.','..','.DS_Store','Thumbs.db'}));
            %go through cycles and trials to pull image filenames in MINDEX in correct order
            wellnamequery=['well',sprintf('%03d',wellID)];
            hit=0;
            for c=1:1:CYCLES
                cyclenamequery=['cycle',sprintf('%03d',c)];
                for t=1:1:TRIALS
                    trialnamequery=['mov',sprintf('%03d',t)];
                    filenamequery=[wellnamequery,cyclenamequery,trialnamequery,'.tif'];
                    %find the specific file in the folder
                    IMGFILEQUERY=contains({FILELIST.name},filenamequery);
                    IMGFILEINDEX=find(IMGFILEQUERY);
                    SPECIFICFILENAME=FILELIST(IMGFILEINDEX).name;
                    if sum(IMGFILEQUERY)==1
                        hit=hit+1;
                    end
                    obj.MINDEX{hit}=SPECIFICFILENAME;
                end
            end
            %WORKING 5/6/2020
        end
        %End of LOADWELLFOLDER()
        
        %frame_grabber gets a specific frame with optimization for user
        %display, it also updates the obj.present_video properties
        function [obj,RETURN_IMG] = frame_grabber(obj,CYCLE_CALL,TRIAL_CALL,FRAME_CALL,IMG_TYPE)
            %Look at video specified by CYCLETOMAP and TRIALTOMAP
            CYCLEMAPSTRING=['cycle',sprintf('%03d',CYCLE_CALL)];
            TRIALMAPSTRING=['mov',sprintf('%03d',TRIAL_CALL)];
            %Find Name of TIFF file
            VIDFIND=strfind(obj.MINDEX,[CYCLEMAPSTRING,TRIALMAPSTRING]);
            [~,VIDCOUNT]=size(obj.MINDEX);
            VIDNAME='';
            for V=1:1:VIDCOUNT
                HITDETECT=VIDFIND{V};
                if HITDETECT==32
                    VIDNAME=obj.MINDEX{V};
                end
            end
            %Build The File Address of the Specific TIFF File
            VID_ADDRESS=[obj.IMGFOLDERADDRESS,'\',VIDNAME];
            %Reminder - NEVER SAVE THE READ_IMG OR THE RETURN_IMG TO THE
            %OBJECT - ONLY SAVE ADDRESSES & FILE INFO
            VID_INFO = {};
            VID_INFO = imfinfo(VID_ADDRESS);
            if obj.present_video_vertical~=0 && obj.present_video_horizontal~=0
                if VID_INFO(1).Height~=obj.present_video_vertical || VID_INFO(1).Width~=obj.present_video_horizontal
                    print('/!\UNEXPECTED: CHANGING VIDEO DIMENSIONS /!\')
                end
            else
                obj.present_video_vertical = VID_INFO(1).Height;
                obj.present_video_horizontal = VID_INFO(1).Width;
            end
            READ_IMG = imread(VID_ADDRESS,'Index',FRAME_CALL,'Info',VID_INFO);
            obj.present_video = VID_ADDRESS;
            obj.present_info = VID_INFO;
            obj.present_cycle = CYCLE_CALL;
            obj.present_trial = TRIAL_CALL;
            obj.present_frame = FRAME_CALL;
            obj.present_type = IMG_TYPE;
            %Return Raw Values
            if IMG_TYPE==0
                RETURN_IMG = READ_IMG;
            end
            %Return Compressed Greyscale
            if IMG_TYPE==1
                RETURN_IMG = WELLIMAGEOPTUM(READ_IMG,obj,IMG_TYPE);
            end
            %Return Colored Image with Delta Highlights. Replaces class
            %method DELTAMAP()
            if IMG_TYPE==2
                RETURN_IMG = WELLIMAGEOPTUM(READ_IMG,obj,IMG_TYPE);
            end
            %TO DO - ADD MORE IMG_TYPEs - must also be updated in
            %WELLIMAGEOPTUM() and GUI DISPLAY_OPTIONS cell
        end
        %End of frame_grabber()
        
        %return ANIMAL ARRAY of integers built from
        %obj.ANIMAL_POSITION_SUPER structure for use in NEURONPOSTABLE
        %display - called by ADD_ANIMAL, UPDATE_ANIMAL, and REMOVE_ANIMAL
        %used for saving to file in NEURONPOSv2_CB3
        function ANIMAL_ARRAY = POSITION_DISPLAY(obj)
                ANIMAL_ARRAY = [];
                for A=1:1:obj.ANIMALS
                    %Number of positions recorded for this animal
                    [~,POS_COUNT] = size(obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION);
                    for P=1:1:POS_COUNT
                        THIS_POS_VALS = [];
                        %get values only
                        WELL = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).WELL;
                        X = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).X_POS;
                        Y = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).Y_POS;
                        ANIMAL = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).ANIMAL_ID;
                        CYCLE = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).CYCLE;
                        TRIAL = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).TRIAL;
                        FRAME = obj.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).FRAME;
                        THIS_POS_VALS = [WELL,X,Y,ANIMAL,CYCLE,TRIAL,FRAME];
                        ANIMAL_ARRAY = cat(1,ANIMAL_ARRAY,THIS_POS_VALS);
                    end
                end
                %return blank array for empty well/null
                if obj.ANIMALS==0
                    ANIMAL_ARRAY=zeros(1,7);
                end
            %end of ANIMAL_ARRAY loop
        end
        %end of POSITION_DISPLAY
        
        %Adds a new unique animal to the well
        function [obj,ANIMAL_ARRAY,NEW_FRAME]=ADD_ANIMAL(obj,X,Y)
            %confirm X,Y click coordinates are in the video frame
            Xcheck=(X>0)&&(X<obj.present_video_horizontal);
            Ycheck=(Y>0)&&(Y<obj.present_video_vertical);
            if Xcheck==1 && Ycheck==1
                %round X and Y values to nearest integer
                INT_X = round(X);
                INT_Y = round(Y);
                %increment animal_ID
                ANIMAL_INT = obj.ANIMALS+1;
                obj.ANIMALS=ANIMAL_INT;
                %build buffer structure to initialize the animal
                ANIMAL_BUFFER = struct;
                ANIMAL_BUFFER.ID = ANIMAL_INT;
                %10/20 new format - initialize structure
                ANIMAL_BUFFER.POSITION(1).WELL = obj.wellID;
                ANIMAL_BUFFER.POSITION(1).X_POS = INT_X;
                ANIMAL_BUFFER.POSITION(1).Y_POS = INT_Y;
                ANIMAL_BUFFER.POSITION(1).ANIMAL_ID = ANIMAL_INT;
                ANIMAL_BUFFER.POSITION(1).CYCLE = obj.present_cycle;
                ANIMAL_BUFFER.POSITION(1).TRIAL = obj.present_trial;
                ANIMAL_BUFFER.POSITION(1).FRAME = obj.present_frame;
                %add the temporary structure ANIMAL_BUFFER to the object
                %'super'structure
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_INT) = ANIMAL_BUFFER;
                %Build ANIMAL_ARRAY for user display table
                ANIMAL_ARRAY = obj.POSITION_DISPLAY;
                %DRAW THE FRAME AGAIN - drawing neuron boxes is function
                %used in the callback
                [obj,NEW_FRAME]=obj.frame_grabber(obj.present_cycle,obj.present_trial,obj.present_frame,obj.present_type);
                if obj.POSLOADED==0
                    obj.POSLOADED=1;
                end
            else
                %invalid X,Y coordinates - return unchaged values
                ANIMAL_ARRAY = obj.POSITION_DISPLAY;
                [obj,NEW_FRAME]=obj.frame_grabber(obj.present_cycle,obj.present_trial,obj.present_frame,obj.present_type);
            end
        end
        %End of ADD_ANIMAL()
        
        %Updates an existing animal with an additional position
        function [obj,ANIMAL_ARRAY,NEW_FRAME]=UPDATE_ANIMAL(obj,X,Y,ANIMAL_UPDATE)
            %confirm X,Y click coordinates are in the video frame
            Xcheck=(X>0)&&(X<obj.present_video_horizontal);
            Ycheck=(Y>0)&&(Y<obj.present_video_vertical);
            if Xcheck==1 && Ycheck==1
                %round X and Y values to nearest integer
                INT_X = round(X);
                INT_Y = round(Y);
                %Get Number of existing positions
                [~,POS_COUNT] = size(obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION);
                %Add Additional Position data
                %10/18 TO DO - this is 'DUMB' - test for existing Pos first!
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).WELL = obj.wellID;
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).X_POS = INT_X;
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).Y_POS = INT_Y;
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).ANIMAL_ID = ANIMAL_UPDATE;
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).CYCLE = obj.present_cycle;
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).TRIAL = obj.present_trial;
                obj.ANIMAL_POSITION_SUPER.ANIMALS(ANIMAL_UPDATE).POSITION(POS_COUNT+1).FRAME = obj.present_frame;
                %return updated ANIMAL_ARRAY and img frame
                ANIMAL_ARRAY = obj.POSITION_DISPLAY;
                [obj,NEW_FRAME]=obj.frame_grabber(obj.present_cycle,obj.present_trial,obj.present_frame,obj.present_type);
            else
                %invalid X,Y coordinates - return unchaged values
                ANIMAL_ARRAY = obj.POSITION_DISPLAY;
                [obj,NEW_FRAME]=obj.frame_grabber(obj.present_cycle,obj.present_trial,obj.present_frame,obj.present_type);
            end
        end
        %End of UPDATE_ANIMAL()
        %TO DO 10/20/21 - needs check to avoid redundant Positions
        
        %Removes all entries for a particular animal and updates all
        %remaining animal ID#s
        function [obj,ANIMAL_ARRAY,NEW_FRAME]=REMOVE_ANIMAL(obj,ANIMAL_DELETE)
            %loop through all animals to remove ANIMAL and update the
            %animal ID#
            pass=0;
            %create buffer, copy the existing object 'super' struture
            BUFFER_STRUCT = struct;
            COPY_STRUCT = obj.ANIMAL_POSITION_SUPER;
            %blank out the object 'super' structure
            obj.ANIMAL_POSITION_SUPER = struct;
            for A=1:1:obj.ANIMALS
                ANIMAL_ID = COPY_STRUCT.ANIMALS(A).ID;
                if ANIMAL_ID~=ANIMAL_DELETE
                    pass=pass+1;
                    %Populate buffer with new ANIMAL_INT
                    BUFFER_STRUCT.ANIMALS(pass).ID = pass;
                    %Populate buffer with copy of this animal's position
                    %data
                    BUFFER_STRUCT.ANIMALS(pass).POSITION = COPY_STRUCT.ANIMALS(A).POSITION;
                    %Change Animal_ID in Buffer Structure
                    [~,POS_COUNT]=size(BUFFER_STRUCT.ANIMALS(pass).POSITION);
                    for P=1:1:POS_COUNT
                        BUFFER_STRUCT.ANIMALS(pass).POSITION(P).ANIMAL_ID=pass;
                    end
                end
            end
            %rewrite the object 'super' structure
            obj.ANIMAL_POSITION_SUPER=BUFFER_STRUCT;
            obj.ANIMALS = obj.ANIMALS-1;
            if obj.ANIMALS==0
                obj.POSLOADED=0;
            end
            %return updated ANIMAL_ARRAY and img frame
            ANIMAL_ARRAY = obj.POSITION_DISPLAY;
            [obj,NEW_FRAME]=obj.frame_grabber(obj.present_cycle,obj.present_trial,obj.present_frame,obj.present_type);
        end
        %End of REMOVE_ANIMAL
        
        %Marks the Well as no visible animals/neurons
        function obj=MARK_NULL(obj)
            obj.POSLOADED=1;
            obj.IS_NULL=1;
            obj.ANIMALS = 0;
            %clear any recorded positions (shouldn't be necessary)
            obj.ANIMAL_POSITION_SUPER = struct;
            %fill a single animal as 0's
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).ID(1) = 0;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).WELL = obj.wellID;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).X_POS = 0;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).Y_POS = 0;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).ANIMAL_ID = 0;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).CYCLE = 0;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).TRIAL = 0;
            obj.ANIMAL_POSITION_SUPER.ANIMALS(1).POSITION(1).FRAME = 0;
        end
        %End of MARK_NULL
        
        %Load NeuronPos text file into 'super' struture of position data
        %supports 'comprehensive' format and older file formats
        function obj=LOADNEURONPOS(obj,textfileaddress)
            %Load Neuron Text file and save it to obj.ANIMAL_POSITION_SUPER
            obj.POSFILEADDRESS=textfileaddress;
            %read NeuronPos text
            OLDER_FORMAT=0;
            try
                %MULTICYCLE INPUT FORMAT
                [w,x,y,an,c,t,f] = textread(textfileaddress,'well %d x %d y %d a %d c %d t %d f %d');
                SELECTIONVIDMARK=1;
            catch
                %existing input format
                try
                    [w,x,y,an,v] = textread(textfileaddress,'well %d x %d y %d a %d v %d');
                    SELECTIONVIDMARK=1;
                    OLDER_FORMAT=1;
                catch
                    %older input format (no cycle record)
                    try
                        [w,x,y,an] = textread(textfileaddress,'well %d x %d y %d a %d');
                        SELECTIONVIDMARK=0;
                        OLDER_FORMAT=1;
                    end
                end
            end
            
            %is this a NULL well?
            [COUNT_OF_LINES,~]=size(w);
            SUM_X_QUERY=sum(x);
            SUM_Y_QUERY=sum(y);
            SUM_ID_QUERY=sum(an);
            if COUNT_OF_LINES==1 && SUM_X_QUERY==0 && SUM_Y_QUERY==0 && SUM_ID_QUERY==0
                obj = obj.MARK_NULL;
            %if well is NOT null then load positions
            else
                A_COUNT=0;
                POSITION_BUFFER=struct;
                for LINE=1:1:COUNT_OF_LINES
                    LINE_WELL=w(LINE);
                    LINE_XPOS=x(LINE);
                    LINE_YPOS=y(LINE);
                    LINE_ANIMAL=an(LINE);
                    %includes trial and frame data
                    if SELECTIONVIDMARK==1&&OLDER_FORMAT==0
                        LINE_CYCLE=c(LINE);
                        LINE_TRIAL=t(LINE);
                        LINE_FRAME=f(LINE);
                    end
                    %no trial or frame data
                    if SELECTIONVIDMARK==1&&OLDER_FORMAT==1
                        LINE_CYCLE=v(LINE);
                        LINE_TRIAL=0;
                        LINE_FRAME=0;
                    end
                    %no cycle, trial, or frame data
                    if SELECTIONVIDMARK==0&&OLDER_FORMAT==1
                        LINE_CYCLE=0;
                        LINE_TRIAL=0;
                        LINE_FRAME=0;
                    end
                    %new animal
                    if LINE_ANIMAL~=A_COUNT
                        A_COUNT=A_COUNT+1;
                        POSITION_BUFFER=struct;
                        POSITION_BUFFER.ID = LINE_ANIMAL;
                        POSITION_BUFFER.POSITION(1).WELL=LINE_WELL;
                        POSITION_BUFFER.POSITION(1).X_POS=LINE_XPOS;
                        POSITION_BUFFER.POSITION(1).Y_POS=LINE_YPOS;
                        POSITION_BUFFER.POSITION(1).ANIMAL_ID=LINE_ANIMAL;
                        POSITION_BUFFER.POSITION(1).CYCLE=LINE_CYCLE;
                        POSITION_BUFFER.POSITION(1).TRIAL=LINE_TRIAL;
                        POSITION_BUFFER.POSITION(1).FRAME=LINE_FRAME;
                        P_COUNT=1;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT) = POSITION_BUFFER;
                    %existing animal - additional positions
                    else
                        P_COUNT=P_COUNT+1;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).WELL=LINE_WELL;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).X_POS=LINE_XPOS;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).Y_POS=LINE_YPOS;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).ANIMAL_ID=LINE_ANIMAL;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).CYCLE=LINE_CYCLE;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).TRIAL=LINE_TRIAL;
                        obj.ANIMAL_POSITION_SUPER.ANIMALS(A_COUNT).POSITION(P_COUNT).FRAME=LINE_FRAME;
                    end
                end
            end
            obj.POSLOADED=1;
            obj.ANIMALS=A_COUNT;
        end
        %End of LOADNEURONPOS()
    end
    %End of Methods
end