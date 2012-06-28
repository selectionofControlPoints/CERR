function planC = mha2cerr(infoS,data3M)
%"mha2cerr"
%   Create an scan based mha header and 3D volume. 
%
%   APA
%
%   Usage: planC = mha2cerr(infoS,data3M)
%
% Copyright 2010, Joseph O. Deasy, on behalf of the CERR development team.
% 
% This file is part of The Computational Environment for Radiotherapy Research (CERR).
% 
% CERR development has been led by:  Aditya Apte, Divya Khullar, James Alaly, and Joseph O. Deasy.
% 
% CERR has been financially supported by the US National Institutes of Health under multiple grants.
% 
% CERR is distributed under the terms of the Lesser GNU Public License. 
% 
%     This version of CERR is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
% CERR is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with CERR.  If not, see <http://www.gnu.org/licenses/>.

% Initialize planC

CTOffset = 1000;

planC = initializeCERR;

indexS = planC{end};

xValsV = infoS.Offset(1)/10  : infoS.PixelDimensions(2)/10 : infoS.Offset(1)/10 + infoS.PixelDimensions(2)*(infoS.Dimensions(2)-1)/10;
yValsV = -infoS.Offset(2)/10  :-infoS.PixelDimensions(2)/10 : -infoS.Offset(2)/10 - infoS.PixelDimensions(1)*(infoS.Dimensions(1)-1)/10;

zValsV = -infoS.Offset(3)/10: -infoS.PixelDimensions(3)/10 : -infoS.Offset(3)/10 - infoS.PixelDimensions(3)*(infoS.Dimensions(3)-1)/10;
zValsV = fliplr(zValsV);

ind = length(planC{indexS.scan}) + 1; 

%Create array of all zeros, size of y,x,z vals.
planC{indexS.scan}(ind).scanArray = uint16(flipdim(permute(data3M,[2,1,3]),3) + CTOffset);
planC{indexS.scan}(ind).scanType = 'CT';
planC{indexS.scan}(ind).scanUID = createUID('scan'); 
%planC{indexS.scan}(ind).uniformScanInfo = [];
%planC{indexS.scan}(ind).scanArrayInferior = [];
%planC{indexS.scan}(ind).scanArraySuperior = [];
%planC{indexS.scan}(ind).thumbnails = [];

scanInfo = initializeScanInfo;

scanInfo(1).grid2Units = infoS.PixelDimensions(2)/10;
scanInfo(1).grid1Units = infoS.PixelDimensions(1)/10; %negative for y.
scanInfo(1).sizeOfDimension1 = infoS.Dimensions(2);
scanInfo(1).sizeOfDimension2 = infoS.Dimensions(1);
scanInfo(1).xOffset = infoS.Offset(2)/10;
scanInfo(1).yOffset = infoS.Offset(1)/10;

scanInfo(1).CTOffset = CTOffset;

%Calculate proper scan offset values based on x,y,z vals.
scanInfo(1).xOffset = xValsV(1) + (scanInfo(1).sizeOfDimension2-1)*scanInfo(1).grid2Units/2;
scanInfo(1).yOffset = yValsV(end) + (scanInfo(1).sizeOfDimension1-1)*scanInfo(1).grid1Units/2;
scanInfo(1).zValue = 0;

sliceThickness = infoS.PixelDimensions(3)/10;

%Populate scanInfo(1) array.
for i=1:length(zValsV)
    scanInfo(1).sliceThickness = sliceThickness;
    scanInfo(1).zValue = zValsV(i);
    planC{indexS.scan}(ind).scanInfo(i) = scanInfo(1);
end

% Populate CERR Options
planC{indexS.CERROptions} = CERROptions;

planC = setUniformizedData(planC);

pause(0.05)

save_planC(planC);


