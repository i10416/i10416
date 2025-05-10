# Notes on Android conventions

Android follows "convention over configuration(CoC)".
It simplifies programs and reduces the lines of code, but at the same time,
it sometimes makes it difficult for newcomers without Android knowledge to
understand what is going on when they edit something in their codebase.

I write this notes to dump my search result and the context for future references.

## minSdkVersion 26 & asset naming convention

Android 26 or later supports Adaptive Icon feature.
According to several tutorials, the icon configuration is put under `mipmap-anydpi-v26`.

Android build and runtime utilize directory name containing version and screen resolution to support OS version x device matrix.

For example, `mipmap-hdpi-v26` takes higher precedence over `mipmap-hdpi` on devices with API level >= 26.

It came to my mind that if my application supports only minSdkVersion 26 or later, I could simply put the asset under `mipmap-anydpi`(without `-v26`).

Unfortunately, I still need to put the asset under `mipmap-anydpi-v26` even though it builds without issues.
### Reference

> Event though it builds without issues, there seems to be a difference. I just did the same—upgrade the minSdkVersion to 26, then rename the folders to drop -v26. Afterwards, the app icon looked different on the same Android 12 device I had used before to test the old behaviour.
> https://stackoverflow.com/questions/66005140/minsdkversion-26-or-later-and-just-with-mipmap-anydpi-containing-ic-launcher-ico


>  Since I changed to only support v28 and beyond I renamed mipmap-anydpi-v26 to mipmap-anydpi — but that messed up the adaptive icons.
> https://stackoverflow.com/questions/45080712/whats-mipmap-anydpi-v26-in-res-directory-in-android-studio-3-0#comment120894612_51171266

## Why we use ic_launcher.xml referencing the icon assets instead of directly put icon assets there?
It is possible to put launcher icon in a location other than mipmap resource, but
launcher icon is semantically similar to mipmap in that its size differs according to device screen size.

If Launcher icon(ic_launcher.xml) is put in mipmap resource,
it needs to reference the non-mipmap icon assets because mipmap resource directory
cannot contain `vectorDrawable`.

### Reference
https://qiita.com/ryo_mm2d/items/2b20b72d3a7c56a68269#mipmap%E3%81%A8drawable