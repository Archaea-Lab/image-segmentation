/////////////////////////////////////////////////////////////////////////////////
//User-defined variables:
// This script assumes Ch1 is GFP & Ch2 is Phase
IMAGEEXT=".nd2"; 				//extension for images
strain = "aBL126";
cond = "midd"; 					//four character tag for condition
sbRadius = "25";
hatRadius = "4";
minThreshValue = "1285";
sizeThreshValue = "017"; 		//"017" = 0.017
/////////////////////////////////////////////////////////////////////////////////
path=getDirectory("Select a folder to analyze ...");
actinProcessingName = "_Sb"+sbRadius+"Mh"+hatRadius+"def"+minThreshValue+"Th"+sizeThreshValue"nm";
rawdir =path+"\\RawImages";			//specify folder that contains raw images
phasedir=path+"\\CellUnedited"; 		//specify folder name for processed phase images
GFPdir= path +"\\ActinMaskUnedited"; 		//specify folder name for processed GFP images
actinMaskEditeddir=path+"\\ActinMaskEdited";
cellmaskdir =path+"\\CellMaskEdited";
unlabelledcelldir=path+"\\CellMaskEdited\\Unlabelled";
dilcellmaskdir=path+"\\CellMaskEdited\\Dilated";

File.makeDirectory(phasedir);
File.makeDirectory(cellmaskdir);
File.makeDirectory(GFPdir);
File.makeDirectory(actinMaskEditeddir);
File.makeDirectory(unlabelledcelldir);
File.makeDirectory(dilcellmaskdir);

rawImageEditor(path);

// This function needs labelled, edited cell ROIs in CellMaskEdited folder
// Once cellROIs are hand-edited, you can run the next function.
actinROIcleaner(path);

function rawImageEditor(path){
	close("*"); // close all images
	roiManager("reset"); // empty the ROI manager
	run("Clear Results"); // empty the results table
	setOption("BlackBackground", true); // binary images are black in background, objects are white
	
	fl=getFileList(rawdir); // fl is a list (aBL126_erly_00.nd2, aBL126_erly_01.nd2,...)
	fList = newArray(fl.length);
	for(l=0; l<fl.length; l++){
		fList[l] = substring(fl[l], 0, lastIndexOf(fl[l], "."));
	}
	Array.print(fList);
	print("There are these many images to analyze for this condition:");
	print(fList.length);
	
	for(i=0; i<fl.length; i++){
		// This for loop iterates over each image file, i, in the list fl (filelist)
		if(endsWith(fl[i], IMAGEEXT)==true){
			open(rawdir+"\\"+fl[i]);
			run("Split Channels");
			
			// Now let's process the GFP channel. 
			selectWindow("C1-"+stripX(fl[i])+IMAGEEXT);
			run("Subtract Background...", "rolling="+sbRadius+" sliding disable");
			run("Mexican Hat Filter", "radius="+hatRadius);
			saveAs("tiff", GFPdir+"\\"+fList[i]+"_"+"Sb"+sbRadius+"Mh"+hatRadius+".tif");
			
			setThreshold(parseInt(minThreshValue), 65535,"black & white");
			run("Convert to Mask");
			saveAs("tiff", GFPdir+"\\"+fList[i]+"_"+"Sb"+sbRadius+"Mh"+hatRadius+"def"+minThreshValue+"Th"+".tif");
			selectWindow(fList[i]+"_"+"Sb"+sbRadius+"Mh"+hatRadius+"def"+minThreshValue+"Th"+".tif");
			run("Analyze Particles...", "size=0."+sizeThreshValue+"-Infinity exclude include add");
			roiManager("Save", GFPdir+"\\"+fList[i]+actinProcessingName+".zip");
			roiManager("deselect");
			roiManager("combine");
			selectWindow(fList[i]+"_"+"Sb"+sbRadius+"Mh"+hatRadius+"def"+minThreshValue+"Th"+".tif");
			run("Clear Outside");
			roiManager("deselect");
			roiManager("Show None");
			saveAs("tiff", GFPdir+"\\"+fList[i]+actinProcessingName+".tif");
			roiManager("reset");
			
			// Now let's process the Phase channel.
			selectWindow("C2-"+fl[i]);
			saveAs("tiff", phasedir+"\\"+fList[i]+"_Phase"+".tif");
			
			roiManager("reset");
			run("Clear Results");
			close("*");
		}
	}
}

function actinROIcleaner(path){
	close("*"); // close all images
	roiManager("reset"); // empty the ROI manager
	run("Clear Results"); // empty the results table
	setOption("BlackBackground", true); // binary images are black in background, objects are white
	
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
			open(cellmaskdir+"\\"+fList[i]+"_cellROIs.zip");
			open(GFPdir+"\\"+fList[i]+actinProcessingName+".tif");
			selectWindow(fList[i]+actinProcessingName+".tif");
			roiManager("Show All");
			n = RoiManager.size;
			print("Starting image "+m+", ("+m+"/"+fList.length+")");
			print("Total number of cells in "+fList[i]+":");
			print(n);
			allInd = Array.getSequence(n);
			for (j = 0; j < n; j++) {
				roiManager("select", j);
			    run("Enlarge...", "enlarge=5 pixel");
			    roiManager("update")//Replaces the selected ROI on the list with the current selection.
			    roiManager("deselect");
			}
			selectWindow(fList[i]+actinProcessingName+".tif");
			roiManager("Show All");
			roiManager("deselect");
			roiManager("save", dilcellmaskdir+"\\"+fList[i]+"_dilatedcellROIs.zip")
			roiManager("select", allInd);
			roiManager("Combine");
			run("Clear Outside");
			roiManager("reset");
			selectWindow(fList[i]+actinProcessingName+".tif");
			roiManager("Show None");
			saveAs("tiff", actinMaskEditeddir+"\\"+fList[i]+"_dilatedcellMask_actinMask.tif");
			
			run("Analyze Particles...", "size=0.000-Infinity exclude include add");
			roiManager("Save", actinMaskEditeddir+"\\"+fList[i]+"_dilatedcellMask_actinROIs.zip");
			
			roiManager("reset");
			run("Clear Results");
			close("*");
			m=m+1;
		}
	}
}


function stripX(string){
	
	// This is because Macro language doesn't have a general use name without extension
	// returns "aBL126_erly_00.nd2" as "aBL126_erly_00"
	return substring(string, 0, lastIndexOf(string, "."));
}
