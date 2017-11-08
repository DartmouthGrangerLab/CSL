# CSL
Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50. \[1\]

## Setup
This code was tested on matlab R2014a, and may require minor tweaking for compatability with other releases.
Depending on your operating system, you may need to compile the mex code in cosegment_BBox/ and LDA/.

## Running the Code
1. Start matlab, and move matlab's working directory to the parent folder of CSLForest_v1
2. Add the entire CSLForest_v1 folder to your matlab path.
3. Execute CSLForest_v1/scripts/demo.m

## Available Datasets
This repository comes ready-to-go with a 4-category subset of the Caltech101 image dataset \[2\]. It has been tested on several datasets:
1. Caltech 101 4-category subset
2. Caltech 101 10-category subset
3. Caltech 256 \[3\] 39-category subset
4. ImageNet \[4\] subset
5. Haxby 2001 \[5\] fMRI dataset
6. Higgs boson dataset

Unsupplied datasets are larger and may be available upon request.

You can use this code on your own datasets. To add a new dataset:
1. Copy your dataset folder into the CSLForest_v1 folder.
2. Create a new configuration file in CSLForest_v1/scripts/DatasetConstants/ .
3. Modify a demo script in CSLForest_v1/scripts/ as appropriate.

\[1\]: https://www.frontiersin.org/articles/10.3389/fncom.2011.00050/full

\[2\]: http://www.vision.caltech.edu/Image_Datasets/Caltech101

\[3\]: http://www.vision.caltech.edu/Image_Datasets/Caltech256

\[4\]: http://www.image-net.org

\[5\]: Haxby, J. V., Gobbini, M. I., Furey, M. L., Ishai, A., Schouten, J. L., & Pietrini, P. (2001). Distributed and overlapping representations of faces and objects in ventral temporal cortex. Science, 293(5539), 2425-2430.
