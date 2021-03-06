package com.eazita.smsgateway.ui;

import android.content.SharedPreferences;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.Context;
import android.content.SharedPreferences.OnSharedPreferenceChangeListener;
import android.os.Bundle;
import android.preference.*;
import android.provider.Settings;
import android.provider.Settings.SettingNotFoundException;
import android.text.method.PasswordTransformationMethod;
import android.view.Menu;

import com.eazita.smsgateway.App;

import com.eazita.smsgateway.R;

public class Prefs extends PreferenceActivity implements OnSharedPreferenceChangeListener {

    private App app;
    
    private BroadcastReceiver installReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {  
            PreferenceScreen screen = getPreferenceScreen();
            updatePrefSummary(screen.findPreference("send_limit"));
        }
    };        
    
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.prefs);
        
        app = (App) getApplication();
        
        PreferenceScreen screen = this.getPreferenceScreen();
        int numPrefs = screen.getPreferenceCount();
        
        for(int i=0; i < numPrefs;i++)
        {
            updatePrefSummary(screen.getPreference(i));
        }
        
        IntentFilter installReceiverFilter = new IntentFilter();        
        installReceiverFilter.addAction(App.EXPANSION_PACKS_CHANGED_INTENT);        
        registerReceiver(installReceiver, installReceiverFilter);                
    }    
    
    @Override
    public void onDestroy()
    {        
        unregisterReceiver(installReceiver);        
        super.onDestroy();
    }    
    
    @Override 
    protected void onResume(){
        super.onResume();
        // Set up a listener whenever a key changes             
        getPreferenceScreen().getSharedPreferences().registerOnSharedPreferenceChangeListener(this);
    }

    @Override 
    protected void onPause() { 
        super.onPause();
        // Unregister the listener whenever a key changes             
        getPreferenceScreen().getSharedPreferences().unregisterOnSharedPreferenceChangeListener(this);     
    } 

    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) { 
        
        if (key.equals("outgoing_interval"))
        {            
            app.setOutgoingMessageAlarm();
        }
        else if (key.startsWith("amqp_"))
        {
            if (app.isAmqpEnabled())
            {
                app.getAmqpConsumer().startAsync();
            }
            else
            {
                app.getAmqpConsumer().stopAsync();
            }                
        }
        else if (key.equals("wifi_sleep_policy"))
        {
            int value;
            String valueStr = sharedPreferences.getString("wifi_sleep_policy", "screen");
            if ("screen".equals(valueStr))
            {
                value = Settings.System.WIFI_SLEEP_POLICY_DEFAULT;
            }
            else if ("plugged".equals(valueStr))
            {
                value = Settings.System.WIFI_SLEEP_POLICY_NEVER_WHILE_PLUGGED;
            }
            else 
            {
                value = Settings.System.WIFI_SLEEP_POLICY_NEVER;
            }
            
            Settings.System.putInt(getContentResolver(), 
                Settings.System.WIFI_SLEEP_POLICY, value);
        }
        else if (key.equals("sim_select_policy"))
        {
            String gsim=app.getSIM();
            String simname;
            if(gsim.equals("2")){
                simname=App.getSIMInfo(this).get(0).getDisplay_name()+", "+App.getSIMInfo(this).get(1).getDisplay_name();
            }else {
                simname=App.getSIMInfo(this).get(Integer.parseInt(gsim)).getDisplay_name();
            }
            app.log("SIM changed to: " + simname);
        }
        else if (key.equals("secret_pin"))
        {
            String serverUrl = app.getServerUrl();
            
            app.log("Secret Pin changed to: " + app.getDisplayString(app.getSecretPin()));
        }
        else if (key.equals("call_notifications"))
        {
            app.log("Call notifications changed to: " + (app.callNotificationsEnabled() ? "ON": "OFF"));
        }
        else if (key.equals("phone_number"))
        {
            app.log("Phone number changed to: " + app.getDisplayString(app.getPhoneNumber()));
        }
        else if (key.equals("test_mode"))
        {
            app.log("Test mode changed to: " + (app.isTestMode() ? "ON": "OFF"));
        }
        else if (key.equals("enabled"))
        {
            app.log(app.isEnabled() ? getText(R.string.started) : getText(R.string.stopped));
            app.enabledChanged();
        }
        
        sendBroadcast(new Intent(App.SETTINGS_CHANGED_INTENT));
        updatePrefSummary(findPreference(key));
    }    

    private void updatePrefSummary(Preference p)
    {
        if (p == null)
        {
            return;
        }
        
        String key = p.getKey();
        
        if ("wifi_sleep_policy".equals(key))
        {       
            int sleepPolicy;
            
            try
            {
                sleepPolicy = Settings.System.getInt(this.getContentResolver(), 
                    Settings.System.WIFI_SLEEP_POLICY);                
            }
            catch (SettingNotFoundException ex)
            {
                sleepPolicy = Settings.System.WIFI_SLEEP_POLICY_DEFAULT;
            }               
            
            switch (sleepPolicy)
            {
                case Settings.System.WIFI_SLEEP_POLICY_DEFAULT:
                    p.setSummary("Wi-Fi will disconnect when the phone sleeps");
                    break;
                case Settings.System.WIFI_SLEEP_POLICY_NEVER_WHILE_PLUGGED:
                    p.setSummary("Wi-Fi will disconnect when the phone sleeps unless it is plugged in");
                    break;
                case Settings.System.WIFI_SLEEP_POLICY_NEVER:
                    p.setSummary("Wi-Fi will stay connected when the phone sleeps");
                    break;
            }
        }
        else if ("sim_select_policy".equals(key))
        {
            p.setSummary("SET SIM policy");

        }
        else if ("send_limit".equals(key))
        {
            int limit = app.getOutgoingMessageLimit();
            String limitStr = "Send up to " + limit + " SMS per hour.";
            
            if (limit < 300)
            {
                limitStr += "\nClick to increase limit...";
            }
            
            p.setSummary(limitStr);
        }        
        else if ("help".equals(key))
        {
            p.setSummary(app.getPackageInfo().versionName);
        }
        else if (p instanceof PreferenceCategory)
        {
            PreferenceCategory category = (PreferenceCategory)p;
            int numPreferences = category.getPreferenceCount();
            for (int i = 0; i < numPreferences; i++)
            {
                updatePrefSummary(category.getPreference(i));
            }                    
        }
        else if (p instanceof ListPreference) {
            p.setSummary(((ListPreference)p).getEntry()); 
        }
        else if (p instanceof EditTextPreference) {
            
            EditTextPreference textPref = (EditTextPreference)p;
            String text = textPref.getText();
            if (text == null || text.equals(""))
            {            
                p.setSummary("(not set)"); 
            }            
            else if (textPref.getEditText().getTransformationMethod() instanceof PasswordTransformationMethod)
            {
                p.setSummary("********");
            }
            else
            {
                p.setSummary(text);
            }
        }
    }    

    // any other time the Menu key is pressed
    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        this.finish();
        return (true);
    }
}
