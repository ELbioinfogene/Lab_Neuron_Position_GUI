function WELL_NEURON_HIGHLIGHT(WELLIMAGES)
%Draws boxes in the current axes (should be image) using position data
%contained within WELLIMAGES object
%working as called in NEURONPOSv2 callbacks
box_size=16;
text_color = 'yellow';
edge_color = 'y';
if WELLIMAGES.ANIMALS>0
    %get position data and draw box_size^2 (DEFAULT IS 16) box with
    %annotations (Animal # and Cycle Selected)
    %loop through animals
    for A=1:1:WELLIMAGES.ANIMALS
        %Get number of positions assigned to this animal
        [~,POS_COUNT] = size(WELLIMAGES.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION);
        for P=1:1:POS_COUNT
            %GET POSITION DATA
            XPOS = WELLIMAGES.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).X_POS;
            YPOS = WELLIMAGES.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).Y_POS;
            ANIMAL = WELLIMAGES.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).ANIMAL_ID;
            CYCLE = WELLIMAGES.ANIMAL_POSITION_SUPER.ANIMALS(A).POSITION(P).CYCLE;
            %draw a box_size^2 around the X,Y coordinates in each position
            rectangle(gca,'Position',[XPOS-box_size/2 YPOS-box_size/2 box_size box_size],'EdgeColor',edge_color);
            text(gca,XPOS+box_size/2, YPOS+box_size/2, ['A:',num2str(ANIMAL),' C:',num2str(CYCLE)], 'FontSize', 6, 'Color', text_color);
        end
    end
end

end