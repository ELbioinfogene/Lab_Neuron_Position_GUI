%NeuronPos_GUI v2
%Eric Larsen 2021
%Albrecht Lab @ WPI
%loads wellplate images and settings txt to generated WELLIMAGES objects
%User can then peruse all well/cycle/trial/frames and annotate animal
%positions - which are stored in the WELLIMAGES objects
%10/25 - FEATURE COMPLETE

%%%%create figure
NEURONPOSMAKER2 = figure;
N='normalized';
%Call back file 1 is for initializing the experiment image file folder and
%manually loading a frame
CB1='NEURONPOSv2_CB1';
%Call back file 2 is for selecting and saving neuron positions
CB2='NEURONPOSv2_CB2';
%10/20 TO DO Call back file 3 is for position 'Save to File' and 'Load from File' functions 
CB3='NEURONPOSv2_CB3';
%Call back 3 uses POS_START_FROM_SCRATCH to determine whether or not to make a folder when saving
POS_START_FROM_SCRATCH = true;
set(NEURONPOSMAKER2,'units',N,'Name','Select Neuron GUI','Position',[0.1 0.1 0.75 0.75],'menubar','none');
%%%%Select Data Folder Button
SELECTIMAGES=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.0085 0.935 0.16 0.052],'string','Select Well Image Folder','callback',CB1);

%%%%IMAGE DISPLAY
IMAGEDISPLAY=axes('parent',NEURONPOSMAKER2,'units',N,'position',[0.19 0.055 0.58 0.89],'visible','off','XTick',0,'YTick',0);

%%%%USER INPUTS
%Drop down menus:
WELL_SELECT=uicontrol('style','popupmenu','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.85 0.074 0.04],'enable','off','Visible','off');
CYCLE_SELECT=uicontrol('style','popupmenu','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.79 0.074 0.04],'enable','off','Visible','off');
TRIAL_SELECT=uicontrol('style','popupmenu','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.73 0.074 0.04],'enable','off','Visible','off');
FRAME_SELECT=uicontrol('style','popupmenu','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.67 0.074 0.04],'enable','off','Visible','off');
%Allow user to different display types:
DISPLAY_OPTIONS={'Raw Values','Basic Greyscale','PseudoColor with Delta'};
VIEW_SELECT=uicontrol('style','popupmenu','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.55 0.074 0.048],'enable','off','Visible','off','string',DISPLAY_OPTIONS);
%Buttons:
%Uses Call back 1:
FRAME_ON_DEMAND=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.61 0.075 0.055],'string','LOAD FRAME','callback',CB1,'enable','off','Visible','off');
%Use Call back 2:
INITIALIZE_NEURON_PICK=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.35 0.14 0.052],'string','Select Neurons','callback',CB2,'enable','off','Visible','off');
WELL_ADVANCE=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.25 0.1 0.052],'string','NEXT WELL','callback',CB2,'enable','off','Visible','off');
DENOTE_NULL_WELL=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.087 0.18 0.1 0.052],'string','MARK AS NULL','callback',CB2,'enable','off','Visible','off');
%Use Call back 3:
SAVE_TO_FILE=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.75 0.041 0.14 0.052],'string','Save To File','callback',CB3,'enable','off','Visible','off');
LOAD_EXISTING_POSITIONS=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.91 0.041 0.08 0.052],'string','Load From File','callback',CB3,'enable','off','Visible','off');
%%%%

%%%%FEEDBACK
%Show user Experiment name built from date images were generated
EXPERIMENTDATEDISPLAY=uicontrol('style','text','parent',NEURONPOSMAKER2,'units',N,'position', [0.019 0.9 0.14 0.03],'Visible','off');
%show user the source of the frame being displayed (well, cycle, trial,
%and frame)
THIS_FRAME_DISPLAY=uicontrol('style','text','parent',NEURONPOSMAKER2,'units',N,'position', [0.02 0.50 0.18 0.03],'Visible','off');
%show user start and end frames of the stimulus
STIM_WINDOW_DISPLAY=uicontrol('style','text','parent',NEURONPOSMAKER2,'units',N,'position', [0.02 0.44 0.18 0.03],'Visible','off');

%TEXT NOTIFICATIONS ABOUT HOW TO EXIT NEURON SELECT/EDIT MODE AND HOW TO
%DELETE ANIMAL IN EDIT MODE
SELECTMODEFINISHNOTE=uicontrol('style','text','parent',NEURONPOSMAKER2,'units',N,'position', [0.22 0.95 0.2 0.019],'Visible','off','string','Press ENTER to exit','FontWeight','bold');
EDIT_MODE_DELETE_NOTE=uicontrol('style','text','parent',NEURONPOSMAKER2,'units',N,'position', [0.44 0.95 0.2 0.019],'Visible','off','string','Press DELETE to remove animal','FontWeight','bold');
%TABLE OF NEURONPOS values
dummynum=zeros(1,7);
POSHEADER={'W','X','Y','An','C','T','F'};
CWIDTHS={25,25,25,25,25,25,25};
NEURONPOSTABLE=uitable('parent',NEURONPOSMAKER2,'units',N,'position', [0.74 0.62 0.17 0.33],'enable','off','data',dummynum,'Visible','off','ColumnName',POSHEADER,'ColumnWidth',CWIDTHS);
%drop down menu/button combo for modifying existing positions
MODIFY_ENTRY=uicontrol('style','pushbutton','parent',NEURONPOSMAKER2,'units',N,'position', [0.8 0.565 0.09 0.04],'string','Modify Animal','callback',CB2,'enable','off','Visible','off');
DISPLAY_ANIMAL_LIST=uicontrol('style','popupmenu','parent',NEURONPOSMAKER2,'units',N,'position', [0.75 0.56 0.04 0.04],'enable','off','Visible','off','string',{1});
%%%%
