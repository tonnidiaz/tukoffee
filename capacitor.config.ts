import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.tb.tukoffee',
  appName: 'Tukoffee',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  },

  plugins: {
    SplashScreen: {
        launchShowDuration: 200,
        launchAutoHide: false,
        launchFadeOutDuration: 200,
        backgroundColor: "#ffffffff",
        androidSplashResourceName: "splash",
        androidScaleType: "CENTER_CROP",
        splashFullScreen: true,
        splashImmersive: true,

      },
  }
};

export default config;
