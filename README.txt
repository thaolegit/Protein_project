
CONTENTS OF THIS FILE
---------------------

 * Introduction
 * About the source code folder
 * Navigating in the folder
 * Launching the app
 * Using the app
 * Limitations and Errors


INTRODUCTION
------------

PROJECT NAME: PROTEINAR

ProteinAR is an iOS app, developed in Swift using Xcode.
ProteinAR integrates the ARKit framework from Apple, allows users to display protein structures in AR and interact with these structures. Users can also create new proteins by combining the polypeptide chains. The data source for protein is RCSB PDB.


ABOUT THE SOURCE CODE FOLDER
------------

The source code folders consists of 6 folders:
1. Buttons: button images for the UI
2. Combinations.scnassets: models that are combinations of polypeptide chains
3. models.scnassets:polypeptide chains models
4. Protein.v3.1: source code folder
5. Protein.v3.1Tests: XCTest folder
6. Sample.scnassets: downloaded and converted pdb files from RCSB
And one main code file: Protein.v3.1.xcodeproj


NAVIGATING IN THE FOLDER
----------------
1. Open the main code file Protein.v3.1.xcodeproj on Xcode. 
***WARNING: The file can be opened on any version of Xcode, but might have some incompatibilities with version of Xcode that are older than 11. Runs best on Xcode version 12.

2. Storyboard can be found at Main.storyboard.

3. Four main screens of the app are coded in four swift files:
  - FirstViewController: landing screen
  - IntroViewController: Introduction about the app with Slide.xib for page controls
  - EduViewController: Education screen where users can download and display protein models from RCSB PDB once the app is completed. At the moment, it can only download models to Document Directory and displayed some pre-downloaded files from Sample.scnassets.
  - GameViewController: Mini-game screen where users can create new protein from polypeptide chains. Models will be displayed from Combinations.scnassets directory.

4. CoreData
The app uses Core Data to store protein's information (in String type). The table can be found at Database.xcdatamodeld.

5. Test 
The app can only be tested after the app had been launched.

LAUNCHING THE APP
-------------

1. To fully enable all functions of ProteinAR, it needs to be tested on an iOS device. 
As ProteinAR uses ARKit, not all iOS devices satisfy the conditions. Only the following devices are qualified:
	 iPhone SE, iPhone 6s and later
	 iPad 2017 and later
	 all iPad Pro models
***WARNING: as the testing device was iPhone, using this app on iPad could generate some UI troubles.

2. Internet connection must be available.

**Note: To enable AR functions, ProteinAR needs to get access to the camera.
Therefore, the built-in simulators of Xcode would not be able to display AR function.
However, it can generate the file download function.



USING THE APP
-----------------
After the app is launched, the first screen will display 3 options: Introduction, Education, Mini-game.

1. By pressing Introduction, users will be guided through the main functions of the apps.
2. By pressing on Education, users will be able to download and display the protein structures, as well as interact with them. If the protein model does  not exist, a 3D text will be generated notifying the users.
On this screen, there are 4 Utility buttons helping users to navigate in the app, explain how things work, record the AR screen, take photos of the AR screen and exit. Videos and photos can be saved in the photo library of the phone.
3. By pressing on Mini-game, users will be able to play a game of combining polypeptide chains into new proteins. If the combination is not valid, a 3D text will be generated to notify users. The utility buttons are the same as the ones on Education screen. 


LIMITATIONS 
---------------

As mentioned in the thesis, the app's goal was to download and display the protein structure at the same time. However, this needs a conversion function from PDB file to Collada file, which the project was not able to create. Therefore, the protein models can be downloaded and saved into Document Directory but are not being displayed at real time. A conversion function must be made for this. 

The source code folder should be named ProteinAR instead of Protein.v3.1. However, due to the unforgiving name-changing of Swift, it stayed as Protein.v3.1.



