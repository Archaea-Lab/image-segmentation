// This script assumes Ch1 is GFP & Ch2 is DIC

path=getDirectory("Select a folder to analyze ..."); //this has to be the "home directory"
rawdir = path + "\\RawImages";
unlabelledcelldir=path+"\\CellMaskEdited\\Unlabelled";
cellmaskdir = path + "\\CellMaskEdited";

Proj(path);

function Proj(path){
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
	for(i=0; i<fList.length; i++){
		if(endsWith(fl[i], IMAGEEXT)==true){
			imagebaseName = fList[i];
			rawimage = imagebaseName+".nd2";
			unlabelledcellrois = imagebaseName+"_cellROIs.zip";
			cellrois = imagebaseName+"_cellROIs.zip";
			
			open(rawdir+"\\"+rawimage);
			roiManager("Open", unlabelledcelldir+"\\"+unlabelledcellrois);
			selectWindow(rawimage);
			roiManager("Show All");
			n = RoiManager.size;
			print("Starting image "+m+", ("+m+"/"+fList.length+")");
			print("Total number of cells in "+fList[i]+":");
			print(n);
			for(j=0; j<n; j++){
				roiManager("select", j);
				roiManager("rename", "cell" + String.pad(j,3));
				roiManager("deselect");
			}
	
			roiManager("save", cellmaskdir+"\\"+cellrois);
			roiManager("reset");
			close("*");
			m=m+1;
		}
	}
}
