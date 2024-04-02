# AlexMaxDemo_iOS

# Version description

| Version     | TopOn SDK Version              |   Applovin version     |
| ------------ | --------------------------- | --------------- |
| 1.0.4       |  >= 6.2.98            |   >= 12.3.1  |
| 1.0.3       |  >= 6.2.87  <6.2.98          | 12.1.0  |
| 1.0.2 | >= 6.2.10  <6.2.87      |  -  |

Other:

1. Added support for MAX's native self-rendered ad integration. Currently compatible with Applovin, Admob, and Pangle. Please refer to the [MaxAdapter support versions](https://dash.applovin.com/documentation/mediation/ios/ad-formats/native-manual) for more information.

2. [TopOn Native Self-rendered Ad Integration Documentation](https://help.toponad.com/docs/Selfrendering-ads)



# integration

## 1. Access TopOn SDK

Please refer to  to access[TopOn SDK Integration Documentation](https://help.toponad.com/docs/LqneJG) TopOn SDK, it is recommended to access **TopOn v6.1.65 and above**[TopOn SDK Integration Documentation Expired](https://docs.toponad.com/#/en-us/ios/GetStarted/TopOn_Get_Started)

## 2 Introducing Max SDK&Alex Adapter

### iOS

#### 1. Import Max SDK

```
pod 'AppLovinSDK'
```



#### 2. Import Alex Adapter

1.To add the source code from the "Max" folder or the "MaxSDKAdapter.framework" to your project

<img width="987" alt="截屏2023-02-08 13 52 41" src="https://user-images.githubusercontent.com/124124788/217446269-c866b212-242a-425a-814a-f7aa14571be8.png">

![Max_lib](https://github.com/Alex-only/AlexMaxDemo_iOS/assets/124124788/53747ba4-bd5b-41ef-8154-d355dc2213ad)





###  Unity平台

We just need to import the MaxSDKAdapter.framework into the path，`Assets/AnyThinkAds/Plugins/iOS`，

![Unity_Max_Podfile_1](https://github.com/Alex-only/AlexMaxDemo_iOS/assets/124124788/266b34ab-6f1c-4878-bdb1-bf8a41c44ee3)

To add the MaxSDKAdapter.framework to your Xcode project using a Podfile,  pod install

```
pod 'AnyThinkiOS', '6.2.34'
pod 'AppLovinSDK'
```

###  Flutter平台

To import the MaxSDKAdapter.framework into the specified path `plugins/anythink_sdk/ios/ThirdPartySDK` and then install the dependencies using `pod install`

![flutter_max](Assets/flutter_max.png)



### 3. The Key used in the Adapter

```
"sdk_key": SDK Key of advertising platform
"unit_id": Advertising slot ID of the advertising platform
"unit_type": Ad slot type, 0: Banner, 1: MREC
```

The JSON configuration example when adding an ad source in the background is as follows: (xxx needs to be replaced with the actual SDK key and ad slot ID of Max, and "unit_type" does not need to be configured for non-banner ad slots)

```json
{
    "sdk_key":"xxx",
    "unit_id":"xxx",
    "unit_type":"0"
}
```



## 三. Max integrates with other advertising platforms

<font color='red'>If you do not need to access other advertising platforms through Max, you can skip this part.</font>

### 1.Determine advertising platform

1. To determine the compatible AdMob version for your TopOn version (v6.2.75), you can refer to the [TopOn documentation](https://docs.toponad.com/#/zh-cn/android/download/package) . It will provide you with the information about the AdMob version compatible with your TopOn version. For example, if the documentation states that TopOn v6.2.75 is compatible with AdMob v10.8.0, then you should use AdMob v10.8.0 for integration.
2. After determining the compatible AdMob version (v10.11.0.0) from the previous step, you can visit the [Max Mediation documentation](https://dash.applovin.com/documentation/mediation/android/mediation-adapters#adapter-network-information) to find the corresponding adapter version. In this case, since you are using Max SDK version 11.11.3 and AdMob version 10.11.0.0, you would look for the Max adapter version that matches AdMob version 10.11.0.0.

![max_admob](Assets/max_admob.png)

**Notice:**

(1) If you cannot find the Adapter corresponding to Admob v10.8.0, you can find the corresponding Adapter version by checking the Changelog of the Adapter.

![max_admob_tip_01](Assets/max_chang_log.png)

(2) Make sure that both TopOn and Max are compatible with Admob SDK



### 2. Introduce advertising platform Adapter

```
pod 'AppLovinMediationGoogleAdapter','10.11.0.0'
```



### 3. Additional configuration of the advertising platform

Enter the [Preparing Mediated Networks](https://dash.applovin.com/documentation/mediation/ios/mediation-adapters) page, then check Admob and perform additional configuration according to the generated configuration instructions.

**Note**: The corresponding application ID of the `GADApplicationIdentifier` configured in Info.plist must be consistent with the application ID in the Admob advertising source configured in the TopOn background.

![max_admob_tip_01](Assets/max_admob_tip_01.png)

![max_admob_tip_01](Assets/max_admob_tip_02.png)

![max_admob_tip_01](Assets/max_admob_tip_03.png)



### 4. Verify integration

4.1 Call the following code to open Max’s Mediation Debugger tool

**Note：**

- Among them, sdkKey is the SDK Key of Max background.
- After testing, you need to delete this code

```objective-c
 [[ALSdk sharedWithKey:@"sdkKey"] showMediationDebugger];
```



4.2  Enter the[Mediation-Debugger](https://dash.applovin.com/documentation/mediation/ios/testing-networks/mediation-debugger) page and follow the steps below to verify whether the advertising platform integration is normal.

![max_admob_tip_01](Assets/max_debugger.png)





## 4. TopOn Background configuration

1. You need to add a Custom Network.

![1](https://user-images.githubusercontent.com/124124788/222124007-1a773ce8-aa7a-4a36-842b-9a67577327bb.png)


2. Choose "Custom Network". Fill in Network Name/Account Name and Adapter's class names according to the contents above.
   *Network Name needs to contain Max to distinguish the Network. Example: Max_XXXXX,

The files used in the SDK for this article are named:

RewardedVideo：AlexMaxRewardedVideoAdapter<br/>
Interstitial：AlexMaxInterstitialAdapter<br/>
Banner：AlexMaxBannerAdapter<br/>
Native：AlexMaxNativeAdapter<br/>
Splash：AlexMaxSplashAdapter<br/>

If the developer has modified the file name in the source code behind, please use the modified name to fill in the background.

![2](https://user-images.githubusercontent.com/124124788/222124025-dd7700ad-3190-4c30-a63f-2c82e13005bb.png)


3. Mark the Network Firm ID

![3](https://user-images.githubusercontent.com/124124788/222124037-0f4ab1fd-9295-411e-b08b-21d2ac2667b3.png)

4. You can add the Ad Sources after adding the Network.

5. You can edit the placement setting to fill the report api key.





## 五. Max setting

### Step1.Create Max account

Log in to the [MAX](https://dash.applovin.com/o/mediation) official website to apply for an account



### Step2.Create MAX app and ad unit

Create app and ad unit in MAX-->Manage-->Ad Units

![max_admob](Assets/max_1.png)



### Step3.Complete Network information configuration in MAX

![max_admob](Assets/max_2.png)



### Step4. MAX Advertisement Description

The corresponding relationship between MAX’s Unit and TopOn’s placement type is as follows:

| MAX-Unit     | TopOn-广告类型 |
| ------------ | -------------- |
| Banner       | Banner         |
| Interstitial | Interstitial   |
| Rewarded     | Rewarded Video |
| App Open     | Splash         |
| Native       | Native         |



### Step5.  Configure MAX unit

#### 5.1  Configure the unit of MAX

5.1.1 Obtain the Ad Unit ID of MAX through the following path: MAX-->Manage-->Ad Units

![max_admob](Assets/max_3.png)

5.1.2. Configure MAX parameters in the TopOn

1. Add an ad source, log in to the TopOn → Mediation → Add ad source



## Step 6. Test Max ads

<font color='red'>Please make sure you have followed the instructions above to create applications and advertising placement in the Max backend and configure them under the advertising placement in the TopOn backend.</font>

1. Open the log of TopOn SDK

```objective-c
  [ATAPI setLogEnabled:YES];//The SDK log function is recommended to be turned on during the integration testing phase and must be turned off before going online.
```

### 2. Open Max's test mode

Enter the [MAX - Test Mode](https://dash.applovin.com/o/mediation/test_modes) page, click the `Add Test Device` button, and fill in the GAID obtained above in the input box of IDFA (iOS) or GAID (Android), then select the advertising platform that needs to be tested, and click `Save` to save it.

![max_admob](Assets/max_test_mode.png)

> For more information, please refer to  [MAX Test Mode](https://dash.applovin.com/documentation/mediation/android/testing-networks/test-mode)



### 3.  Load & display ads

After adding the test device to the Max backend, please wait for 5 to 10 minutes. After the configuration takes effect, call the relevant methods of the TopOn SDK to load and display the TopOn placement to verify whether the integration of the Max advertising is normal.
