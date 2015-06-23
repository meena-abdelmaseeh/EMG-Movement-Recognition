About the code
==============
The source code for the the manuscript titled [AbdelMaseeh, M.; Chen, T.; Stashuk, D., "Extraction and Classification of Multichannel Electromyographic Activation Trajectories for Hand Movement Recognition," Neural Systems and Rehabilitation Engineering, IEEE Transactions on , vol.PP, no.99, pp.1,1 doi: 10.1109/TNSRE.2015.2447217]. 

The paper proposes a system for hand movement recognition using multi-channel electromyographic (EMG) signals obtained from the forearm surface. This system can be potentially used to control prostheses or to provide input to a wide range of human computer interface systems. The developed methods were tested with the publicly available NINAPro database.

Build the code
==============
The code includes DTW.c and FindTrajectories.cpp files that need to be compiled into .mex functions. The steps are:

1- Make sure that the compiler is correctly configured. Compilers are configured through "mex -setup" command. The compilers used for development were "Microsoft Visual C++ 2010" and "Microsoft Visual C++ 2012". For Further details, please visit the following link: http://www.mathworks.com/help/matlab/matlab_external/building-mex-files.html

2- Navigate Matlab to where you downloaded the code. 

3- Execute the following script:	
	CompileCppCode.m

Download the data
=================
The developed methods were tested using the second version of the publicly available databse from the Non-Invasive Adaptive Prosthetics (NINAPro) project. 


1- For complete description of the data and the acquisition protocol, please refer to: 
[M. Atzori, A. Gijsberts, C. Castellini, B. Caputo, A.-G. M. Hager, S. Elsig, G. Giatsidis, F. Bassetto, and H. Muller, “Electromyography data for non-invasive naturally-controlled robotic hand prostheses,” Scientific Data, vol. 1, 2014.] .

2- The data can be downloaded from http://ninapro.hevs.ch .

3- Change the value for DatabaseLocation attribute in Configuration.exp to point to the location of the data.

Run the code
============
1- Change the attributes in the configuration.exp file. Each line in the configuration file has the format: 
AttributeName = AttributeValue; 

2- Run the Main.m script. 

Support
======= 
For any problems or further support, please contact us on m2adly@uwaterloo.ca

Fairness of Usage
=================
Please reference in your paper as:

[AbdelMaseeh, M.; Chen, T.; Stashuk, D., "Extraction and Classification of Multichannel Electromyographic Activation Trajectories for Hand Movement Recognition," Neural Systems and Rehabilitation Engineering, IEEE Transactions on , vol.PP, no.99, pp.1,1 doi: 10.1109/TNSRE.2015.2447217]
