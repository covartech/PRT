Title: Image segmentation - classify pixels from one of 7 classes
Origin: cultivated

Usage: development

Order:  uninformative

Attributes:
  1 pixel-class	        u CEMENT BRICKFACE GRASS FOLIAGE SKY PATH WINDOW # Pixel classes
  2 region-centroid-col u  (0,255)	# centre pixel column of the region.
  3 region-centroid-row u  (0,255)	# centre pixel row of the region.
  4 short-line-density-5 u  [0,1],	# Low contrast line count
  5 short-line-density-2 u  [0,1],	# High contrast line count
  6 vedge-mean		 u  [0,Inf]     # Mean horizontal contrast
  7 vedge-sd		 u  [0,Inf]     # Standard deviation of horizontal contrast
  8 hedge-mean		 u  [0,Inf]     # Mean vertical contrast
  9 hedge-sd		 u  [0,Inf]     # Standard deviation of vertical contrast
 10 intensity-mean	 u  [0,Inf]     # Average intensity  (R+G+B)/3
 11 rawred-mean		 u  [0,Inf]     # Average red over areas
 12 rawblue-mean	 u  [0,Inf]     # Average blue over areas
 13 rawgreen-mean	 u  [0,Inf]     # Average green over areas
 14 exred-mean		 u  [-Inf,Inf]     # Excess red (2R - (G + B))
 15 exblue-mean		 u  [-Inf,Inf]     # Excess blue (2B - (G + R))
 16 exgreen-mean	 u  [-Inf,Inf]     # Excess green (2G - (T + B))
 17 value-mean		 u  [-Inf,Inf]     # 3-d non linear transformation of RGB
 18 saturation-mean	 u  [-Inf,Inf]     # same as for value-mean
 19 hue-mean		 u  [-Inf,Inf]     # same as for value-mean
