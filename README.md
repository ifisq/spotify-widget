# spotify-widget
This is an application/iOS 14 widget I wrote to display your Now Playing Spotify song!

## NOTICE

Spotify widget has been released in my app [TuneTrack](https://apps.apple.com/app/id1525634753). This repository's code no longer works and as a result has been archived. If you'd like to use the widget, please download the app from the App Store.

### Preface
This widget isn't meant for general usage. It serves more as a proof of concept, and a demonstration of what you can do with WidgetKit! If you'd like to take a look at the widget's code, click [here](sqwidget/sqwidget.swift). There's still a few issues with WidgetKit (because it's only 2 days old at the time of release!), and that leads to the widget crashing from time to time. If you have suggestions or want updates on the widget, check out my [Twitter](https://twitter.com/ifisq)!

### Installation

1. Download the GitHub source files.
2. Open the .xcodeproj file
3. Switch the bundle identifiers & Team to yourself for the CustomWidgets and sqwidgetExtension targets.
4. Change the App Group in CustomWidgets and sqwidgetExtension to your own thing. (e.g. group.dev.aryanjnambiar.CustomWidgets.app). These HAVE to be the same for it to work.
5. In ViewController.swift, change the defaults on line 37 and line 121 to point to your App Group. Do the same in line 84 on sqwidget.swift
6. Try building/installing it! 

Note: I haven't had a chance to test this process out on another device, so if I'm missing any steps, please let me know!

### Usage

1. Open the CustomWidgets application
2. Click login with Spotify
3. Give the application permission to access your Spotify data
4. Success! Try adding a widget to the homescreen.

### Known Bugs
```WARNING! Sole personality requested when nil; THIS MAY BE A SPURIOUS LAUNCH OF THE PLUGIN due to a message to an XPC endpoint other than the main service endpoint; personalities```

To the best of my knowledge, this is an issue with WidgetKit. Just keep trying to build/run the app or extension until it works properly on your phone (it'll work eventually!).
Update: This issue was fixed with a new release of an iOS 14.0 Developer Beta.

### Video Demo
[Twitter link](https://twitter.com/i/status/1275955672564355072)

### Images
<img src="https://i.imgur.com/Ptkd1Ud.jpg" width="500">
<img src="https://i.imgur.com/1reLmnu.jpg" width="500">
<img src="https://i.imgur.com/yn7A7ku.jpg" width="500">
