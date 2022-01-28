#define CHANDLE(name,name2) cmdFuncs[@#name] = [NSValue valueWithPointer:(const void * _Nullable)&handle ## name2 ];
CHANDLE(activeApps,ActiveApps);
CHANDLE(alertInfo,AlertInfo);
CHANDLE(button,Button);
CHANDLE(launchApp,LaunchApp);
//CHANDLE(elByName,ElByName);
//CHANDLE(elByPid,ElByPid);
CHANDLE(elClick,ElClick);
CHANDLE(elForceTouch,ElForceTouch);
CHANDLE(elPos,ElPos);
CHANDLE(elTouchAndHold,ElTouchAndHold);
//CHANDLE(elementAtPoint,ElementAtPoint);
CHANDLE(sysElPos,SysElPos);
CHANDLE(getEl,GetEl);
CHANDLE(getOrientation,GetOrientation);
CHANDLE(setOrientation,SetOrientation);
CHANDLE(homeBtn,HomeBtn);
CHANDLE(iohid,Iohid);
//CHANDLE(isLocked,IsLocked);
//CHANDLE(lock,Lock);
CHANDLE(mouseDown,MouseDown);
CHANDLE(mouseUp,MouseUp);
CHANDLE(nslog,Nslog);
CHANDLE(ping,Ping);
CHANDLE(siri,Siri);
CHANDLE(source,Source);
CHANDLE(sourceJson,Source);
CHANDLE(startBroadcastApp,StartBroadcastApp);
CHANDLE(swipe,Swipe);
CHANDLE(tap,Tap);
CHANDLE(test,Test);
CHANDLE(doubletap,Doubletap);
CHANDLE(tapFirm,TapFirm);
CHANDLE(tapTime,TapTime);
CHANDLE(toLauncher,ToLauncher);
CHANDLE(typeText,TypeText);
CHANDLE(typeKey,TypeKey);
CHANDLE(hasEventRecording,HasEventRecording);
//CHANDLE(unlock,Unlock);
CHANDLE(updateApplication,UpdateApplication);
CHANDLE(wifiIp,WifiIp);
CHANDLE(windowSize,WindowSize);



//LT Changes
CHANDLE(restart,StartLTStream);
CHANDLE(launchsafariurl,OpenSafari);
CHANDLE(cleanbrowser,CleanBrowser);

//LT End
