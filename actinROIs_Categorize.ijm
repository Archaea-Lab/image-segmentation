/////////////////////////////////////////////////////////////////////////////////
//User-defined variables:
// This script assumes Ch1 is GFP & Ch2 is Phase
IMAGEEXT=".nd2"; 		//extension for images
strain = "aBL126";
cond = "midd"; 			//four character tag for condition
actinProcessingName = "_GFPSb25Mh5def2570Th014nm.tif";
/////////////////////////////////////////////////////////////////////////////////
path=getDirectory("Select a folder to analyze ...");
rawdir = path + "\\RawImages";			//specify folder that contains raw images
phasedir=path + "\\PhaseUnedited"; 		//specify folder name for processed phase images
cellmaskdir=path+"\\CellMaskEdited"; 
dilcellmaskdir=path+"\\CellMaskEdited\\Dilated";
GFPdir = path + "\\ActinMaskUnedited"; 		//specify folder name for processed GFP images
actinMaskEditeddir=path+"\\ActinMaskEdited";
actindir = path + "\\ActinMaskEdited";
subsetdir= path +"\\CellMaskEdited\\Subset of Cells with Actin";
actinMeasdir=path+"\\ActinMeasurements";
cellMeasdir= path+"\\CellMeasurements";
cableMeasdir=path+"\\CellMeasurements\\CableMeasurements";
patchMeasdir=path+"\\CellMeasurements\\PatchMeasurements";
cabledir = path + "\\CableMask";
patchdir = path + "\\PatchMask";

File.makeDirectory(subsetdir);
File.makeDirectory(cellMeasdir);
File.makeDirectory(cableMeasdir);
File.makeDirectory(patchMeasdir);
File.makeDirectory(cabledir);
File.makeDirectory(patchdir);
/////////////////////////////////////////////////////////////////////////////////


close("*"); // close all images
roiManager("reset"); // empty the ROI manager
run("Clear Results"); // empty the results table
setOption("BlackBackground", true); // binary images are black in background, objects are white

actinROICategorizer(path);

function actinROICategorizer(path){
	close("*");
	roiManager("reset");
	run("Clear Results");
	setOption("BlackBackground", true);
	
	fl=getFileList(rawdir); // fl is a list (aBL126_erly_00.nd2, aBL126_erly_01.nd2,...)
	fList = newArray(fl.length);
	for(l=0; l<fl.length; l++){
		fList[l] = substring(fl[l], 0, lastIndexOf(fl[l], "."));
	}
	Array.print(fList);
	print("There are these many images to analyze for this condition:");
	print(fList.length);
	m=1;
	for(i=0; i<fl.length; i++){
		// This for loop iterates over each image file, i, in the list fl (filelist)
		if(endsWith(fl[i], IMAGEEXT)==true){
			print("Starting image "+m+", ("+m+"/"+fList.length+")");
			open(rawdir+"\\"+fl[i]);
			roiManager("Open", actindir+"\\"+fList[i]+"_actinROIs.zip");
			selectWindow(fList[i]+".nd2");
			roiManager("Show All");
			roiManager("measure");
			n=RoiManager.size;
			print("Starting image "+m+", ("+m+"/"+fList.length+")");
			print("Total number of actin structures in "+fList[i]+":");
			print(n);
			
			j=0;
			k=0;
			cableIndArr = newArray();
			patchIndArr = newArray();
			for(a=0; a<n; a++){
				roiManager("select", a);
				area = getResult("Area",a);
				AR = getResult("AR",a);
				if(area>0.13){
					if(AR>1.5){
						cableInd = toString(j);
						roiManager("rename", "cable_" + String.pad(cableInd,3));
						cableIndArr = Array.concat(cableIndArr,a);
						j = j+1;
					}else{
						patchInd = toString(k);
						roiManager("rename","patch_" + String.pad(patchInd,3));
						patchIndArr = Array.concat(patchIndArr,a);
						k = k+1;
					}
				}else{
					patchInd = toString(k);
					roiManager("rename","patch_" + String.pad(patchInd,3));
					patchIndArr = Array.concat(patchIndArr,a);
					k = k+1;
				}
				roiManager("deselect");
			}
			print("Number of cables in "+fList[i]+":");
			print(j);
			print("Number of patches in "+fList[i]+":");
			print(k);
			
			roiManager("deselect");
			run("Clear Results");
			roiManager("measure");
			saveAs("Results", actinMeasdir+"\\"+fList[i]+"_all.csv");
			roiManager("deselect");
			run("Clear Results");
			
			print(cableIndArr.length);
			Array.print(cableIndArr);
			roiManager("select", cableIndArr);
			roiManager("save selected", cabledir+"\\"+fList[i]+"_cableROIs.zip");
			roiManager("select", cableIndArr);
			roiManager("measure");
			saveAs("Results", actinMeasdir+"\\"+fList[i]+"_cable.csv");
			run("Clear Results");
			
			print(patchIndArr.length);
			Array.print(patchIndArr);
			roiManager("select", patchIndArr);
			roiManager("save selected", patchdir+"\\"+fList[i]+"_patchROIs.zip");
			roiManager("select", patchIndArr);
			roiManager("measure");
			saveAs("Results", actinMeasdir+"\\"+fList[i]+"_patch.csv");
			run("Clear Results");
			
			totalNROIs = cableIndArr.length+patchIndArr.length;
			print("There are "+n+"actin structures in "+fList[i]+":");
			print(totalNROIs);
			m=m+1;
			close("*"); // close all images
			roiManager("reset"); // empty the ROI manager
			run("Clear Results");
		}
	}
}