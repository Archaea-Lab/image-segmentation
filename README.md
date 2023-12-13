# image-segmentation

Bisson Lab - Automated batch image processing for cell and actin structure segmentation



SUMMARY: The data analysis pipeline detailed below was used for segmenting cell and GFP-labelled volactin structures (patches and cables) in H. volcanii cells. Cell masks and volactin filaments were generated through automated batch processing using Trackmate, Cellpose2, and custom Fiji macros.
These custom Fiji macros can be found in this repo.


OBJECTIVE: The main challenge was that volactin patches had a large range in intensity - some patches were very dim and hard to segment using standard thresholding. In order to circumvent this and to make sure all patches were segmented, this macro uses a Mexican Hat Filter, which does a decent job at detecting patches - both dim and bright.


INPUT: 
- Cell brightfield/phase images
- GFP image with patches - both dim and bright - and cables

OUTPUT:
- Cell masks - each cell ROI is enumerated and labelled in ImageJ’s ROI Manager (ie. "cell000", "cell 001", ...)
- Actin mask - each cable and patch ROI is labelled and enumerated by cell number (ie. "cell006_patch05", or "cell495_cable02")


---------------------------------------------------------------------------------------------------



1. Cell masks are first generated using the Trackmate GUI in ImageJ to run Cellpose, a trainable, machine-learning–based segmentation algorithm. A custom Cellpose segmentation model that was previously trained by another member of the lab using images of H. volcanii cells of both rod and disk morphotypes - “volcanii_pads&fluidics”. The resultant cell mask can be then manually edited to remove improperly segmented cells. 



2. Cell masks with labels are then generated using the custom macro, “cellROIs_RenameROIs.ijm” which renames cell ROIs as “cell000”, “cell001”,... in the ImageJ ROI Manager.



3. Actin masks are generated through batch processing of images using the custom ImageJ macro “ImageBatchEditing.ijm”. This macro first preprocesses images by subtracting background and using a Mexican Hat filter, which is particularly useful for detecting particles that can have both low and high signal intensities. Actin ROIs are then detected using ImageJ’s built-in particle detector (“Analyze Particles…”) and filtered using a high-pass size filter. The macro then refers back the previously generated cell ROI list to remove actin ROIs that are localized to cells that will not be used for analysis, ie. cells that were not detected/removed when generating the final cell mask. 



4. Further, actin ROIs are categorized into separate cable and patch masks using the custom ImageJ macro, “actinROIs_Categorize.ijm”. Actin ROIs with an area greater than 0.13 um^2 and aspect ratio greater than 1.5 are categorized as cables. All other actin particles are categorized as patches. Using the labelled cell masks, each cable ROI is matched to its respective cell using the labelled cell masks and renamed in the ImageJ ROI Manager as “cell006_cable02”, as an example. This is repeated for the patch ROIs.
