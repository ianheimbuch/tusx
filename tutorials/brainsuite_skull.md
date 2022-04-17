## How to create a skull mask using **[BrainSuite](http://brainsuite.org/)**
1. Open your structural MRI (T1-weighted)
    * Via **Open a 3D Image File** on the opening menu
    * Or, via _File -> Open Volume_
2. Run the **BrainSuite Anatomical Pipeline** for the first _two_ stages.
    * _Processing -> BrainSuite Anatomical Pipeline_
        * (BrainSuite 19b and earlier: _Cortex -> Cortical Surface Extraction Sequence_)
    * Select and run the first two stages:
        * Skull stripping
        * Skull and scalp
3. From the **Delineation Toolbox** (_View -> Delineation Toolbox Sidebar_):
    * Open the **Label Mask Tool**
    * Click **Update List**
    * Select the **skull** label (should be ID 17)
    * Click **Make Mask**. (Mask will appear as a green outline)
4. Fix the skull mask using the Mask Tool
    * Make sure "**edit mask**" is toggled on.
    * You may want the "**paint on all mouse clicks**" option toggled on, too.
    * Save your mask.
        * Save frequently while working. It will take a while.
    
### Tips:
* Increase view with _View -> Zoom Best Fit_
* Consider using **3D brush** option for initial fixes, since it will color in multiple layers at once.
* BrainSuite was never really designed to handle skull masking well (it's specialty is brain segmentation and diffusion, after all). As such, there is likely a lot you will have to fix using this technique.
    * If you have a preferred skull masking technique, you can always import an externally created mask into BrainSuite (or do the hand segmentation process on another MRI software of your choice, such as [FSLeyes](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSLeyes))