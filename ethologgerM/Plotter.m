classdef Plotter < handle_light
    %A class for modifying plotting functions
    
    properties
        Property1
    end
    
    methods
        function obj = untitled6(inputArg1,inputArg2)
            %UNTITLED6 Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
    
    methods (Static)
        function initiatePlot()
            clf
            axes('NextPlot','add','FontSize',16,'TickDir','out','FontName','Verdana','Color','k',...
                'XColor','w',...
                'YColor','w',...
                'ZColor','w')
            set(gcf,'color','k')
        end
        
        function notBoxBlack(bkgHandles,bkgStats)
            %adjusts the figure to have black background with mainly white
            %features Hardcastle et al., 2021
            semColor = hex2rgb('#fc9272');
            lineColor = [1 1 1];
            meanColor = hex2rgb('#af8dc3');
            for bIdx = 1:numel(bkgHandles)
                if ~isempty(bkgHandles(bIdx).data)
                    bkgHandles(bIdx).semPtch.FaceColor = 'none';
                    bkgHandles(bIdx).semPtch.EdgeColor = lineColor;
                    bkgHandles(bIdx).semPtch.FaceAlpha = 1;
                    bkgHandles(bIdx).semPtch.EdgeAlpha = 1;
                    bkgHandles(bIdx).semPtch.Visible = 'on';
                    bkgHandles(bIdx).semPtch.LineWidth = 2;
                    
                    bkgHandles(bIdx).data.Marker = '.';
                    bkgHandles(bIdx).data.Color = lineColor;
                    bkgHandles(bIdx).data.MarkerSize = defaultMarkerSize;
                    bkgHandles(bIdx).data.Visible = 'on';
                    
                    bkgHandles(bIdx).mu.Color = lineColor;
                    bkgHandles(bIdx).med.Color = lineColor;
                    bkgHandles(bIdx).med.Visible = 'off';
                    bkgHandles(bIdx).sd.Visible = 'off';
                    bkgHandles(bIdx).sd.Color = semColor;
                    bkgHandles(bIdx).sd.LineWidth = 2;
                    bkgHandles(bIdx).mu.LineWidth = 3;
                    bkgHandles(bIdx).med.LineWidth = 2;
                    bkgHandles(bIdx).med.LineStyle = ':';
                    
                    % set sd to top layer
                    bkgHandles(bIdx).mu.ZData  = abs(bkgHandles(bIdx).mu.ZData);
                    bkgHandles(bIdx).med.ZData  = abs(bkgHandles(bIdx).med.ZData);
                    
                    bkgHandles(bIdx).sd.ZData  = abs(bkgHandles(bIdx).sd.ZData);
                    
                    if applyFisherZ
                        zMean = tanh(mean(atanh(bkgStats(bIdx).vals)));
                        bkgHandles(bIdx).mu.YData = [zMean zMean];
                    end
                end
            end
        end
    end
end

