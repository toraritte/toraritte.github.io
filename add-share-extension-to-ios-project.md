Add Share Extension to an iOS project (Living Document)
=====================================

Adding a share extension to a project a second time around and would hate to do the research again the next time.

Resources used
--------------
+ Apple's [App Extension Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/)

Step 1: Add Share Extension target in Xcode
-------------------------------------------
**File > New > Target**, then choose "**Share Extension**".  
<sup>Wrote <a href="https://animationreview.files.wordpress.com/2012/11/mouse-cleaning-c2a9-mgm.jpg" >"Stare Extension"</a> first. 
  
Step 2: Edit `Info.plist`
-------------------------

[Declaring Supported Data Types for a Share or Action Extension](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html#//apple_ref/doc/uid/TP40014214-CH21-SW8) section is helpful but the predicate thing did not work for me.

### Example: Restrict Share Extension to audio files only

---
<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="https://licensebuttons.net/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
</p>
