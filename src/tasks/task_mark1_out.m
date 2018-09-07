function task_mark1_out(hObj)
try
    
    handles = guidata(hObj);
    myData = handles.myData;
    settings=myData.settings;
    taskinfo = myData.taskinfo;
    calling_function = handles.myData.taskinfo.calling_function;
    
    display([taskinfo.task, ' called from ', calling_function])
    
    switch calling_function
        
        case 'Load_Input_File' % Read in the taskinfo
            
            taskinfo_default(hObj, taskinfo)
            handles = guidata(hObj);
            taskinfo = handles.myData.taskinfo;
            taskinfo.rotateback = 0;
            if length(taskinfo.desc)>9
                myData.finshedTask = myData.finshedTask + 1;
            end
        case {'Update_GUI_Elements', ...
                'ResumeButtonPressed'} % Initialize task elements
            
            % Load the image
            taskimage_load(hObj);
            handles = guidata(hObj);

            % Show management buttons
            taskmgt_default(handles, 'on');
            handles = guidata(hObj);
            handles.panning_Zooming_Tool.markexists=0;
            
            handles.textX = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [40,6,20,2], ...
                'Style', 'Text', ...
                'String', 'X coordinate:', ...
                'Tag', 'textX');
            
            handles.textY = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [70,6,20,2], ...
                'Style', 'Text', ...
                'String', 'Y coordinate:', ...
                'Tag', 'textY');
            
            handles.textROI = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [20,4,20,2], ...
                'Style', 'Text', ...
                'String', 'ROI:', ...
                'Tag', 'textROI');
            
            handles.textROIX = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [0.95, 0.95, 0.95], ...
                'Position', [40,4,20,2], ...
                'Style', 'Text', ...
                'String', 'not set', ...
                'Tag', 'SelectRegionTextX', ...
                'Callback', @SelectRegionTextX_Callback);
            
            handles.textROIY = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', [0.95, 0.95, 0.95], ...
                'Position', [70,4,20,2], ...
                'Style', 'Text', ...
                'String', 'not set', ...
                'Tag', 'SelectRegionTextY', ...
                'Callback', @SelectRegionTextY_Callback);
            
            handles.textWSI = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [20,1.5,20,2], ...
                'Style', 'Text', ...
                'String', 'WSI:', ...
                'Tag', 'textWSI');
            
            handles.textWSIX = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [40,1.5,20,2], ...
                'Style', 'Text', ...
                'String', 'not set', ...
                'Tag', 'textWSIX');
            
            handles.textWSIY = uicontrol(...
                'Parent', handles.task_panel, ...
                'FontSize', handles.myData.settings.FontSize, ...
                'Units', 'Characters', ...
                'HorizontalAlignment', 'left', ...
                'ForegroundColor', handles.myData.settings.FG_color, ...
                'BackgroundColor', handles.myData.settings.BG_color, ...
                'Position', [70,1.5,20,2], ...
                'Style', 'Text', ...
                'String', 'not set', ...
                'Tag', 'textWSIY');
            
        case 'ImageAxes_ButtonDownFcn' % Capture the user input
            
            % Get the position of the mouse click
            pos=get(handles.ImageAxes,'CurrentPoint');
            x = pos(1,1);
            y = pos(1,2);
            % Map the position from ROI coordinates to WSI coordinates
            RotateWSI = settings.RotateWSI;
            switch RotateWSI
                case 270                     %6 o'clock
                    x_wsi = taskinfo.roi_x - taskinfo.img_w/2 + y;
                    y_wsi = taskinfo.roi_y + taskinfo.img_h/2 - x;
                case 90                     %12 o'clock
                    x_wsi = taskinfo.roi_x + taskinfo.img_w/2 - y;
                    y_wsi = taskinfo.roi_y - taskinfo.img_h/2 + x;
            end    
            
            % Reload the image
            taskimage_load(hObj);
            handles = guidata(hObj);
            % Create the mark, make it size 80
            handles.panning_Zooming_Tool.mark = rectangle('Position',...
                [x-40,y-40,80,80],'Curvature',[1,1],...
                'LineWidth',4,'LineStyle','--','EdgeColor','r','Tag','mark');
            handles.panning_Zooming_Tool.markexists=1;
            
            % Display the coordinates of the click in the textboxes
            set(handles.textROIX,'String',num2str(x));
            set(handles.textROIY,'String',num2str(y));
            set(handles.textWSIX,'String',num2str(x_wsi));
            set(handles.textWSIY,'String',num2str(y_wsi));
            
            % Enable next button
            set(handles.NextButton,'Enable','on');
            uicontrol(handles.NextButton);
            
            % Pack the user data into taskinfo
            taskinfo.nmarks = 1;
            taskinfo.xy_marks = [x_wsi,y_wsi];
            
            % Pack the results
            myData.tasks_out{handles.myData.iter} = taskinfo;
            
            
        case 'Reticlebutton_Callback' % keep mark result after hide/show reticle
            if handles.panning_Zooming_Tool.markexists==1
                textROIX= get(handles.textROIX);
                textROIY= get(handles.textROIY);
                x = str2num(textROIX.String);
                y = str2num(textROIY.String);
                handles.panning_Zooming_Tool.mark = rectangle('Position',...
                    [x-40,y-40,80,80],'Curvature',[1,1],...
                    'LineWidth',4,'LineStyle','--','EdgeColor','r','Tag','mark');
                handles.panning_Zooming_Tool.markexists=1;
            end
            
            
        case {'NextButtonPressed', ...
                'PauseButtonPressed',...
                'Backbutton_Callback',...
                'Refine_Register_Button_Callback'} % Clean up the task elements

            % Hide image and management buttons
            taskmgt_default(handles, 'off');
            handles = guidata(hObj);
            
            set(handles.iH,'visible','off');
            if handles.panning_Zooming_Tool.markexists==1
                set(handles.panning_Zooming_Tool.mark,'visible','off');
            end            
            set(handles.ImageAxes,'visible','off');
            delete(handles.textX);
            delete(handles.textY);
            delete(handles.textROI);
            delete(handles.textROIX);
            delete(handles.textROIY);
            delete(handles.textWSI);
            delete(handles.textWSIX);
            delete(handles.textWSIY);
            handles = rmfield(handles, 'textX');
            handles = rmfield(handles, 'textY');
            handles = rmfield(handles, 'textROI');
            handles = rmfield(handles, 'textROIX');
            handles = rmfield(handles, 'textROIY');
            handles = rmfield(handles, 'textWSI');
            handles = rmfield(handles, 'textWSIX');
            handles = rmfield(handles, 'textWSIY');
            
            taskimage_archive(handles);
        case 'exportOutput' % export current task information and reuslt
            if taskinfo.currentWorking ==1 % write finish task in current study
                 fprintf(myData.fid, [...
                        taskinfo.task, ',', ...
                        taskinfo.id, ',', ...
                        num2str(taskinfo.order), ',', ...
                        num2str(taskinfo.slot), ',',...
                        num2str(taskinfo.roi_x), ',',...
                        num2str(taskinfo.roi_y), ',', ...
                        num2str(taskinfo.roi_w), ',', ...
                        num2str(taskinfo.roi_h), ',', ...
                        taskinfo.text, ',', ...
                        num2str(taskinfo.duration), ',', ...
                        num2str(taskinfo.xy_marks(1)), ',', ...
                        num2str(taskinfo.xy_marks(2))]);
            elseif taskinfo.currentWorking ==0 % write undone task
                  fprintf(myData.fid, [...
                       taskinfo.task, ',', ...
                       taskinfo.id, ',', ...
                       num2str(taskinfo.order), ',', ...
                       num2str(taskinfo.slot), ',',...
                       num2str(taskinfo.roi_x), ',',...
                       num2str(taskinfo.roi_y), ',', ...
                       num2str(taskinfo.roi_w), ',', ...
                       num2str(taskinfo.roi_h), ',', ...
                       taskinfo.text, ',']);
            else                               % write done task from previous study
                 desc = taskinfo.desc;
                 for i = 1 : length(desc)-1
                      fprintf(myData.fid,[desc{i},',']);
                 end
                 fprintf(myData.fid,[desc{length(desc)}]);
            end            
            fprintf(myData.fid,'\r\n');
            handles.myData.taskinfo = taskinfo;
            guidata(handles.GUI, handles);   
            
%         case 'Save_Results' % Save the results for this task
%             
%             fprintf(taskinfo.fid, [...
%                 taskinfo.task, ',', ...
%                 taskinfo.id, '-1', ',', ...
%                 num2str(taskinfo.order), ',', ...
%                 num2str(taskinfo.slot), ',',...
%                 num2str(taskinfo.xy_marks(1)), ',',...
%                 num2str(taskinfo.xy_marks(2)), ',', ...
%                 num2str(taskinfo.roi_w), ',', ...
%                 num2str(taskinfo.roi_h), ',', ...
%                 num2str(taskinfo.img_w), ',', ...
%                 num2str(taskinfo.img_h), ',', ...
%                 taskinfo.text, ',', ...
%                 num2str(taskinfo.moveflag), ',', ...
%                 num2str(taskinfo.zoomflag), ',', ...
%                 taskinfo.q_op1, ',', ...
%                 taskinfo.q_op2, ',', ...
%                 taskinfo.q_op3, ',', ...
%                 taskinfo.q_op4, ',', ...
%                 num2str(taskinfo.duration), ',', ...
%                 num2str(taskinfo.xy_marks(1)), ',', ...
%                 num2str(taskinfo.xy_marks(2))]);
%             fprintf(taskinfo.fid,'\r\n');
            
    end
    
    % Update handles.myData.taskinfo and pack
    myData.taskinfo = taskinfo;
    handles.myData = myData;
    guidata(hObj, handles);
    
catch ME
    error_show(ME)
end
end