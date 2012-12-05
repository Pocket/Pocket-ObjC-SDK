Welcome!
========

Thanks for checking out the Pocket SDK. With a few lines of code, your app can quickly add support for saving URLs to users' Pocket lists.

##Installing the Pocket SDK##

The Pocket SDK is the fastest way to add Pocket integration to any iOS or Mac application. Adding the Pocket SDK to your app is incredibly easy. Follow the steps below and you can be saving urls to Pocket from your app within 15 minutes.

###Step 1: Download the Pocket SDK###

You can download the SDK at: [http://getpocket.com/api/v3/pocket-objc-sdk.zip](http://getpocket.com/api/v3/pocket-objc-sdk.zip)

You can also watch/checkout the SDK from GitHub at: [http://github.com/pocketco/Pocket-ObjC-SDK](http://github.com/pocketco/Pocket-ObjC-SDK). If you use recommend adding the Pocket SDK as a git submodule of your project by running `git submodule add git://github.com/Pocket/Pocket-ObjC-SDK.git <path>` from the root directory of your repository, replacing the `<path>` with the path you'd like it installed to.

If you use [CocoaPods](http://cocoapods.org/), you can add the `PocketAPI` pod to your Podfile. Then run `pod install`, and the Pocket SDK will be available in your project. See the documentation on the CocoaPods website if you want to set up a new or existing project.

The project download includes the SDK and an example project.

###Step 2: Add the Pocket SDK to your project###

- Open your existing project. 
- Drag the SDK folder from the example project into your Xcode project.
- Make sure the “Copy items into destination group’s folder (if needed)” checkbox is checked.
- Select your Xcode project in the Project Navigator, select your application target, select “Build Phases”, and add Security.framework to your “Link Binary With Libraries” phase.

The SDK includes all necessary source files and does not have any other dependencies.


![](https://s3.amazonaws.com/pocket-assets/adding-sdk.png "Dragging the SDK to your XCode project")


![](https://s3.amazonaws.com/pocket-assets/adding-security-framework.png "Security.framework is in the Link Binary With Libraries Build Phase")

###Step 3: Obtain a platform consumer key###


When you register your app with Pocket, it will provide you with a platform consumer key. This key identifies your app to Pocket’s API.

If you have not obtained a consumer key yet, you can register one at [http://getpocket.com/api/signup](http://getpocket.com/api/signup)


###Step 4: Add the Pocket URL scheme###


Once you have the consumer key for the platform you are supporting, the application must register a URL scheme to receive login callbacks. By default, this is "pocketapp" plus your application's ID (which you can find at the beginning of the consumer key before the hyphen). So if your consumer key is 42-abcdef, your app ID is 42, and your URL scheme will be "pocketapp42". 

If there are already URL schemes in your app’s Info.plist, you can either add the new URL scheme, or use an existing scheme by calling `[[PocketAPI sharedAPI] setURLScheme:@"YOUR-URL-SCHEME-HERE"]`. To add a URL Scheme, create a block like the one below in your Info.plist, updating it with the app’s scheme:

	▾ URL Types (Array)
		▾ Item 0 (Dictionary)
			  URL Identifier (String) com.getpocket.sdk
			▾ URL Schemes (Array) (1 item)
				Item 0	(String) [YOUR URL SCHEME, like "pocketapp42"]

Or you can copy and paste the following into the XML Source for the Info.plist:

	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLName</key>
			<string>com.readitlater</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>pocketapp9553</string>
			</array>
		</dict>
	</array>

###Step 5: Configure your App Delegate###


The final steps to set up the Pocket SDK requires adding a few lines of code to your main app delegate. This is the class where you include iOS required methods like applicationDidFinishLaunching.

####Import the PocketAPI Header####

At the top of your app delegate source file (and anywhere you call the PocketAPI object),  you'll need to include the PocketAPI header. At the top of your class you'll probably see other imports already. Simply add this line:

	#import “PocketAPI.h”

####Set Your Platform Consumer Key####

The Pocket SDK requires your consumer key in order to make any requests to the API. Call this method with your registered consumer key when launching your app:

	[[PocketAPI sharedAPI] setConsumerKey:@"Your Consumer Key Here"];

####Add a method for the Pocket url-scheme####

The final step is to give the SDK an opportunity to handle incoming URLs.  If you do not already implement this method on your app delegate, simply add the following method:

	-(BOOL)application:(UIApplication *)application 
	           openURL:(NSURL *)url
	 sourceApplication:(NSString *)sourceApplication
	        annotation:(id)annotation{
	
	    if([[PocketAPI sharedAPI] handleOpenURL:url]){
	        return YES;
	    }else{
	        // if you handle your own custom url-schemes, do it here
	        return NO;
	    }
	
	}


###Step 6: Start Saving to Pocket!###

At this point you’ve properly installed the SDK and can now start making requests and saving urls to Pocket. Here is a two line example:

	NSURL *url = [NSURL URLWithString:@”http://google.com”];
	[[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error){
	    if(error){
	        // there was an issue connecting to Pocket
	        // present some UI to notify if necessary

	    }else{
	        // the URL was saved successfully
	    }
	}];

The example above uses blocks which requires iOS 4.0 or greater. If you have a need to support iOS 3.0, you can use the [linkto:delegate or operation based methods].



##Managing Accounts / Handling User Logins##

Following Pocket’s API best practices, you’ll want to provide a way for the user to manage what account they are logged into. This is most commonly handled by adding a setting in your app’s option screen that lets the user configure their Pocket account. When the user taps this, you can simply call one line of code which will handle the entire authorization process:

	[[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
	if (error != nil)
	{
		// There was an error when authorizing the user. The most common error is that the user denied access to your application.
		// The error object will contain a human readable error message that you should display to the user
		// Ex: Show an UIAlertView with the message from error.localizedDescription
	}
	else
	{
		// The user logged in successfully, your app can now make requests.
		// [API username] will return the logged-in user’s username and API.loggedIn will == YES
	}
	}];

It is also recommended to observe changes to the PocketAPI's username and loggedIn properties to determine when the logged-in user changes. If iOS terminates your application while it is in the background (e.g. due to memory constraints), any pending login attempts are automatically saved and restored at launch if needed. Therefore, your delegate/block responses may not get called. If you need to update UI when the logged in user changes, register for observers on PocketAPI at application launch.

###Calling Other Pocket APIs###

To call other arbitrary APIs, pass the API's method name, the HTTP method name, and an NSDictionary of arguments. An NSDictionary with the response from the API will be passed to the handler.

	NSString *apiMethod = ...;
	 PocketAPIHTTPmethod httpMethod = ...; // usually PocketAPIHTTPMethodPOST
	 NSDictionary *arguments = ...;

	 [[PocketAPI sharedAPI] callAPIMethod:apiMethod 
	                       withHTTPMethod:httpMethod 
	                            arguments:arguments
	                              handler: ^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error){
	    // handle the response here
	 }];

Acknowledgements
================

The Pocket SDK uses the following open source software:

- [SFHFKeychainUtils](https://github.com/ldandersen/scifihifi-iphone/tree/master/security) for saving user credentials securely to the keychain.
- [UIDevice-Hardware](https://github.com/erica/uidevice-extension) for creating a user agent

License
=======

Copyright (c) 2012 Read It Later, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
