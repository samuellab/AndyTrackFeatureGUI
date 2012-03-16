Track Feature GUI Framework
===========================

by Andrew Leifer
leifer@fas.harvard.edu


This is a small modular MATLAB script that generates a user interface for display images and soliciting user input about features. Its not really designed to be stand alone.

The main function is BrightObjectTracker.m It takes two function handles, one to a function that loads in new images, and another function that identifies feature candidates.

The framework will display the features and allow the user to select amongst the top 5 candidates or manually enter their own.

This is released under a GNU GPL license.


