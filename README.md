Welcome!
========

Thanks for checking out the Pocket SDK. With a few lines of code, your app can quickly add support for saving URLs to users' Pocket lists.

Setup
=====

0. Get an API key from http://getpocket.com/api/
1. Add the contents of the SDK folder to your app. If you already include SFHFKeychainUtils, you should not include the copy bundled with the SDK.
2. In your app delegate's application:didFinishLaunchingWithOptions: method, add this line: `[[PocketAPI sharedAPI] setAPIKey:@"Put Your API Key Here"];`
3. Replace the `"Put Your API Key Here"` bit with the API key you got in step 0.
4. Add the Security.framework to your project.
5. To log in, call `-[PocketAPI loginWithUsername: password: delegate:]`. The Pocket SDK automatically saves and loads the user's credentials securely in the keychain.
6. To save URLs, call `-[PocketAPI saveURL: delegate]` or `-[PocketAPI saveURL: withTitle: delegate:]`.
7. Read PocketAPI.h to see the PocketAPIDelegate protocol that your app implements. Use this to show app-appropriate UI for the progress of item saving.

Acknowledgements
================

The Pocket SDK uses the following open source software:

- [SFHFKeychainUtils](https://github.com/ldandersen/scifihifi-iphone/tree/master/security) for saving user credentials securely to the keychain.

License
=======

Copyright (c) 2012 Read It Later, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.