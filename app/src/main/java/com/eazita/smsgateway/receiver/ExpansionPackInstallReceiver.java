package com.eazita.smsgateway.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.eazita.smsgateway.App;

public class ExpansionPackInstallReceiver extends BroadcastReceiver
{
    @Override
    public void onReceive(Context context, Intent intent) 
    {        
        App app = (App) context.getApplicationContext();
        
        String action = intent.getAction();
        
        boolean isInstalled = !"android.intent.action.PACKAGE_REMOVED".equals(action);
        
        String packageName = intent.getData().getSchemeSpecificPart();
        
        if (packageName != null)
        {
            if (packageName.startsWith(context.getPackageName() + ".pack"))
            {            
                app.updateExpansionPacks(); 
            }
        }
    }        
}    