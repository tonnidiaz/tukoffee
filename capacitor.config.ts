import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.tb.tukoffee',
  appName: 'Tukoffee',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  }
};

export default config;
