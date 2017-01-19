# pattern-recognition (CSE426)

Given a training set A of 100 samples/class and three test sets B, C, & D of 100 samples/class (chosen from the list of data sets below), do:

-	Reposition each sample character image by centering it within a 16x16 pixel array (with equal white-space margins top/bottom and left/right; rarely, a character-image may be larger than 16 pixels in width or height---in this case, simply trim off the extra rows or columns roughly equally from left-&-right or top-&-bottom).

-	Extract, from each centered sample, twenty normalized central moment features (as discussed in HW#5, but extended beyond the ten described there).
 
-	Train four classifiers using the data from set A, each using a different classification method given in the list below.

-	Test each of the four classifiers on sets A, B, C, & D;   note the best error rate ‘E’ achieved by any of these four classifiers, averaged over the three test sets B, C, & D.

-	Explore new features which will allow one of the four classifiers to cut E by at least a factor of two (that is, to drop the error in half at least).   You are free to invent any sort of feature that you wish.

-	In addition to trying new features, design and implement a fifth classifier, different from the four above, which will cut E at least in half.   You are free to try any trainable classifier technology in the PR literature (e.g. SVMs, ANNs, CARTs), including any discussed in DHS.  You are free to find and use any pre-existing software for training and testing this fifth classifier.
