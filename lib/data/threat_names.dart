const threatDisplayNames = <String, String>{
  'ROOT_DETECTED': 'Rooted device',
  'JAILBREAK_DETECTED': 'Jailbroken iPhone',
  'HOOKING_FRAMEWORK': 'Hooking tool (like Frida)',
  'SCREEN_OVERLAY': 'Screen overlay',
  'APP_TAMPERED': 'App was modified',
  'EMULATOR': 'Running on an emulator',
  'DEBUGGER_ATTACHED': 'Debugger attached',
};

String getThreatDisplayName(String code) =>
    threatDisplayNames[code.trim()] ?? code;
