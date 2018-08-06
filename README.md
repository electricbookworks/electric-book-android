# Electric Book Android app

When an Electric Book project has so many images that its app size is over 100MB, Google Play requires that they are stored in a separate expansion file. To manage that expansion file, you need to maintain the Google Play version of the app in this repo, separately from the main project repo.

## Usage

First, make sure you have Android Studio and Java SDK 8 (at the moment, SDK 9 does not work). [Guidance here](https://cordova.apache.org/docs/en/latest/guide/platforms/android/).

Install Cordova 6.5 globally, or if you're on Windows and use the script mentioned below, the script uses that version locally from `node_modules`.

> Note: In this guidance, we'll use `com.example.myapp` to refer to your app ID. You'll use your own, as stored in your main content project's `_data/meta.yml` files as its `app-id`.

If you are building a translation, search this repo for all instances of `com.example.myapp.expansion` or `com.example.myapp.fr.expansion` (where `com.example.myapp` is your project's app ID, and `.fr` is the language tag of the app you're working on) and make sure that the language tag (`fr` in this example) matches the language you're working on.

1. To update the content, build app-ready HTML over in your main content project, then copy the contents of `_site/app/www` there to this project's `www` directory. When building the HTML there:
   1. if you're outputting a translation, when asked by the output script for extra config files, use `_configs/_config.app.fr.yml` (e.g. `fr` for French)
   1. remember to activate the expansion file behaviour there in `_data/settings.yml` by setting `google-play-expansion-file-enabled: true`.
2. In `config.xml`, we recommend updating the version number in the `widget` element to match the version of the main content repo as specified in its `_data/meta.yml`. This keeps the content version aligned with the app version. The app version *must* increment with each release added to Google Play.
2. Run the `run-windows.bat` batch file. This will move the images to `expansion-main`and zip them up with no compression. (This script isn't available for Mac or Linux yet.)
   
   If xAPKReader plugin has been successfully added, the script will try to build a local testing version of the app.

   Alternatively (or if you're on Mac or Linux), run:

   ```
   npm install
   ```

   then

   ```
   cordova platform remove android
   ```

   ```
   cordova platform add android@6.3.0
   ```

   ```
   cordova prepare android
   ```

   ```
   cordova build android
   ```

   If your emulator is set up, you can run:

   ```
   cordova emulate android
   ```

3. To create a signed release:
   1.  Copy `build-example.json` to `build.json` and fill in the path to your keystore and its passwords and key alias. *Do not commit `build.json` or the keystore to version control*.
   2.  In the project root run `cordova build android --release`.

If you need to generate a keystore, the easiest way to do this is with Android Studio. Open the project (the repo) in Android Studio, then go to 'Build > Generate signed APK...'. Fill in the prompts, and your `.jks` keystore will appear where you've defined there that it should.

If you're working on an existing app, it's likely that a keystore already exists for this project, and you should use that one. Its password and the password for the key it contains should be stored somewhere safely for you to find.

> Note: The first time you set up a new app, you'll go to 'App signing' on Google Play for your certificate. Google Play will say that you will get a certificate once you've uploaded an APK. You worry, because you wonder whether Google will accept an unsigned APK. So you upload an insigned APK and Google Play says that it can't use that because it's unsigned. You are rightly confused by this. Then go back to 'App signing' and, voila, magically there is now a certificate ready for you to use to sign your APK.

## On app prep and signing

> For each application, the Google Play service automatically generates a 2048-bit RSA public/private key pair that is used for licensing and in-app billing. The key pair is uniquely associated with the application. Although associated with the application, the key pair is not the same as the key that you use to sign your applications (or derived from it). ... To add licensing to an application, you must obtain your application's public key for licensing and copy it into your application. – [Google Developer guidelines](https://developer.android.com/google/play/licensing/adding-licensing)

Some useful resources:

- [Preparing the app](https://developer.android.com/studio/publish/preparing)
- [Signing the app](https://developer.android.com/studio/publish/app-signing)
- [Launch checklist](https://developer.android.com/distribute/best-practices/launch/launch-checklist)
- [App signing with Google Play Signing](https://medium.com/mindorks/securing-and-optimizing-your-app-with-google-play-app-signing-24a3658fd319)

## Testing

### Testing locally

1. Install the `android-debug.apk`\* as an app normally. (I.e. download it to your phone over a network or email, and open the APK file on the device to install it.) Don't open the app yet.

   \* Note that signed apps (`android-release.apk`) can't be tested locally, presumably because once signed the app is only allowed to use expansion files downloaded securely from Google Play.

2. Rename `expansion-main.zip` to `main.1.com.example.myapp.obb`.
3. Copy `main.1.com.example.myapp.obb` to your device, into this folder: `Android/obb/com.example.myapp`. You may need to create the folder in `Android/obb`. Do *not* save it to the SD card, which has a similar path.

   So the expansion is now on your device (not the SD card) at `Android/OBB/com.example.myapp/main.1.com.example.myapp.obb`.

   If you are creating a translation-specific app, you need to add the language tag to the folder name and expansion file name, as with `.fr` in this example:

   `Android/obb/com.example.myapp.fr`

   `main.1.com.example.myapp.fr.obb`

   This is because for translation apps (i.e. where built with a `site-language` set in the config) we set a different APK ID: the parent ID, but with the language tag appended like this.

4. Your app Should Just Work.

### Testing on Google Play

Testers should be members of a Google Group. Once added the the group, get the testing URL for them to visit to opt in from Google Play. It should look like `https://play.google.com/apps/testing/com.example.myapp`.

## Uploading to Google Play

The first time you add an APK to Google Play that needs an expansion file, the upload dialog gives you no way to add the expansion file. This is probably because Google Play treats expansion files firstly as a way to update existing apps. 

To upload the expansion file, go to 'Artifact library' and click the plus sign to the right of the APK. Choose 'Add update'. That will ask if you want to add an expansion file. Select that and choose the expansion file to upload.

(This odd behaviour may have been fixed by now.)

## Installing xAPKReader

The xAPKReader plugin has already been added here. In the event it needs to be done again, follow the [guidelines here](https://github.com/agamemnus/cordova-plugin-xapkreader/tree/cordova-6.5.0). When adding, use the full add command including the public API key and expansio authority like this:

```
cordova plugin add https://github.com/agamemnus/cordova-plugin-xapkreader.git#cordova-6.5.0 --variable XAPK_PUBLIC_KEY="MIIBIjANBgkqh[...]AQAB" --variable XAPK_EXPANSION_AUTHORITY="com.example.myapp.expansion"
```
