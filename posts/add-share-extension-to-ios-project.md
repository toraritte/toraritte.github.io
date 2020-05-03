Add Share Extension with a custom view to an iOS project (Living Document)
==========================================================================

Simply adding a share extension via Step 1 below makes a `SLComposeServiceViewController` subclass by default, with a text view and a configuration item below it. The only way to get rid of the text view is to make a custom view controller, therefore the same look will be recreated here without the text view.

Also see ["Share Extension - Remove Textfield"](https://stackoverflow.com/questions/46606221/share-extension-remove-textfield) Stackoverflow question.

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

Step 3: Custom view controller
------------------------------

Adding a custom view controller with a blurred background, just as it is with `SLComposeServiceViewController`.

```swift
/*
class ShareViewController: SLComposeServiceViewController { */
class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        /* This could've been done from the Object Library but for some reason
           the blurred view kept being deallocated. Doing it programmatically
           resulted in the same behaviour, but after a couple retries it seems
           that it is ok. Weird.
        */
        // https://stackoverflow.com/questions/17041669/creating-a-blurring-overlay-view/25706250
        // only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            view.insertSubview(blurEffectView, at: 0)
        } else {
            view.backgroundColor = .black
        }
        // Do any additional setup after loading the view.
    }
    // (...)
}
```

Step 4: Embed a navigation controller
-------------------------------------

Drag a Navigation Controller to the storyboard from the object library, CTRL drag the Share View Controller to the Navigation Controller and select "Embed". 

---
<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="https://licensebuttons.net/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
</p>
