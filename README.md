Setup
=====

0) Get an API key from http://getpocket.com/api/
1) Add the contents of the SDK folder to your app
2) In your app delegate's application:didFinishLaunchingWithOptions: method, add this line: `[[PocketAPI sharedAPI] setAPIKey:@"Put Your API Key Here"];`
3) Replace the `"Put Your API Key Here"` bit with the API key you got in step 0.
4) Add the Security.framework to your project.
5) To log in, call `-[PocketAPI loginWithUsername: password: delegate:]`. The Pocket SDK automatically saves and loads the user's credentials securely in the keychain.
6) To save URLs, call `-[PocketAPI saveURL: delegate]` or `-[PocketAPI saveURL: withTitle: delegate:]`.
7) Read PocketAPI.h to see the PocketAPIDelegate protocol that your app implements. Use this to show app-appropriate UI for the progress of item saving.