package com.tealium;

import android.util.Log;

import com.tealium.library.BuildConfig;
import com.tealium.library.ConsentManager;
import com.tealium.library.Tealium;
import com.tealium.lifecycle.LifeCycle;
import com.tealium.internal.tagbridge.RemoteCommand;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * TealiumPlugin
 */
public class TealiumPlugin implements MethodCallHandler {
    private String mTealiumInstanceName;
    private static PluginRegistry.Registrar mRegistrar;
    private static MethodChannel mChannel;
    private static Map<String, RemoteCommand> mRemoteCommandsMap = new HashMap<>();

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        mChannel = new MethodChannel(registrar.messenger(), "tealium");
        mChannel.setMethodCallHandler(new TealiumPlugin());
        mRegistrar = registrar;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "initialize":
                initialize(call, result);
                break;
            case "initializeWithConsentManager":
                initializeWithConsentManager(call, result);
                break;
            case "initializeCustom":
                initializeCustom(call, result);
                break;
            case "trackEvent":
                trackEvent(call, result);
                break;
            case "trackEventForInstance":
                trackEventForInstance((String) call.argument("instance"), call, result);
                break;
            case "trackView":
                trackView(call, result);
                break;
            case "trackViewForInstance":
                trackViewForInstance((String) call.argument("instance"), call, result);
                break;
            case "setVolatileData":
                setVolatileData(call, result);
                break;
            case "setVolatileDataForInstance":
                setVolatileDataForInstance((String) call.argument("instance"), call, result);
                break;
            case "setPersistentData":
                setPersistentData(call, result);
                break;
            case "setPersistentDataForInstance":
                setPersistentDataForInstance((String) call.argument("instance"), call, result);
                break;
            case "removeVolatileData":
                removeVolatileData(call, result);
                break;
            case "removeVolatileDataForInstance":
                removeVolatileDataForInstance((String) call.argument("instance"), call, result);
                break;
            case "removePersistentData":
                removePersistentData(call, result);
                break;
            case "removePersistentDataForInstance":
                removePersistentDataForInstance((String) call.argument("instance"), call, result);
                break;
            case "getVolatileData":
                getVolatileData(call, result);
                break;
            case "getVolatileDataForInstance":
                getVolatileDataForInstance((String) call.argument("instance"), call, result);
                break;
            case "getPersistentData":
                getPersistentData(call, result);
                break;
            case "getPersistentDataForInstance":
                getPersistentDataForInstance((String) call.argument("instance"), call, result);
                break;
            case "getVisitorId":
                getVisitorId(result);
                break;
            case "getVisitorIdForInstance":
                getVisitorIdForInstance((String) call.argument("instance"), result);
                break;
            case "getUserConsentStatus":
                getUserConsentStatus(result);
                break;
            case "getUserConsentStatusForInstance":
                getUserConsentStatusForInstance((String) call.argument("instance"), result);
                break;
            case "setUserConsentStatus":
                setUserConsentStatus(call, result);
                break;
            case "setUserConsentStatusForInstance":
                setUserConsentStatusForInstance((String) call.argument("instance"), call, result);
                break;
            case "getUserConsentCategories":
                getUserConsentCategories(result);
                break;
            case "getUserConsentCategoriesForInstance":
                getUserConsentCategoriesForInstance((String) call.argument("instance"), result);
                break;
            case "setUserConsentCategories":
                setUserConsentCategories(call, result);
                break;
            case "setUserConsentCategoriesForInstance":
                setUserConsentCategoriesForInstance((String) call.argument("instance"), call, result);
                break;
            case "resetUserConsentPreferences":
                resetUserConsentPreferences();
                break;
            case "resetUserConsentPreferencesForInstance":
                resetUserConsentPreferencesForInstance((String) call.argument("instance"));
                break;
            case "setConsentLoggingEnabled":
                setConsentLoggingEnabled(call, result);
                break;
            case "setConsentLoggingEnableForInstance":
                setConsentLoggingEnabledForInstance((String) call.argument("instance"), call, result);
                break;
            case "isConsentLoggingEnabled":
                isConsentLoggingEnabled(result);
                break;
            case "isConsentLoggingEnabledForInstance":
                isConsentLoggingEnabledForInstance((String) call.argument("instance"), result);
                break;
            case "addRemoteCommandForInstance":
                addRemoteCommandForInstance((String) call.argument("instance"), call);
                break; 
            case "addRemoteCommand":
                addRemoteCommand(call);
                break;
            case "removeRemoteCommandForInstance":
                removeRemoteCommandForInstance((String) call.argument("instance"), call);
                break; 
            case "removeRemoteCommand":
                removeRemoteCommand(call);
                break;                        
            default:
                result.notImplemented();
                break;


        }
    }

    private void initialize(MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String account = (String) arguments.get("account");
        final String profile = (String) arguments.get("profile");
        final String environment = (String) arguments.get("environment");
        final String datasourceId = (String) arguments.get("androidDatasource");
        final String instance = (String) arguments.get("instance");
        final boolean isLifecycleEnabled = (boolean) arguments.get("isLifecycleEnabled");

        if (account == null || profile == null || environment == null) {
            throw new IllegalArgumentException("Account, profile, and environment parameters must be provided and non-null");
        }

        final Tealium.Config config = Tealium.Config.create(mRegistrar.activity().getApplication(), account, profile, environment);
        if (datasourceId != null) {
            config.setDatasourceId(datasourceId);
        }

        mTealiumInstanceName = instance;

        if (isLifecycleEnabled) {
            LifeCycle.setupInstance(mTealiumInstanceName, config, true);
        }

        Tealium.createInstance(instance, config);
        result.success(null);
    }

    private void initializeWithConsentManager(MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String account = (String) arguments.get("account");
        final String profile = (String) arguments.get("profile");
        final String environment = (String) arguments.get("environment");
        final String datasourceId = (String) arguments.get("androidDatasource");
        final String instance = (String) arguments.get("instance");
        final boolean isLifecycleEnabled = (boolean) arguments.get("isLifecycleEnabled");

        if (account == null || profile == null || environment == null) {
            throw new IllegalArgumentException("Account, profile, and environment parameters must be provided and non-null");
        }

        final Tealium.Config config = Tealium.Config.create(mRegistrar.activity().getApplication(), account, profile, environment);
        if (datasourceId != null) {
            config.setDatasourceId(datasourceId);
        }

        config.enableConsentManager(instance);
        mTealiumInstanceName = instance;

        if (isLifecycleEnabled) {
            LifeCycle.setupInstance(mTealiumInstanceName, config, true);
        }

        Tealium.createInstance(instance, config);
        result.success(null);
    }

    private void initializeCustom(MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String account = (String) arguments.get("account");
        final String profile = (String) arguments.get("profile");
        final String environment = (String) arguments.get("environment");
        final String datasourceId = (String) arguments.get("androidDatasource");
        final String instance = (String) arguments.get("instance");
        final boolean isLifecycleEnabled = (boolean) arguments.get("isLifecycleEnabled");
        final String overridePublishSettingsUrl = (String) arguments.get("overridePublishSettingsUrl");
        final String overrideTagManagementUrl = (String) arguments.get("overrideTagManagementUrl");
        final boolean enableConsentManager = (boolean) arguments.get("enableConsentManager");


        if (account == null || profile == null || environment == null) {
            throw new IllegalArgumentException("Account, profile, and environment parameters must be provided and non-null");
        }

        final Tealium.Config config = Tealium.Config.create(mRegistrar.activity().getApplication(), account, profile, environment);
        if (datasourceId != null) {
            config.setDatasourceId(datasourceId);
        }

        if (overridePublishSettingsUrl != null) {
            config.setOverridePublishSettingsUrl(overridePublishSettingsUrl);
        }

        if (overrideTagManagementUrl != null) {
            config.setOverrideTagManagementUrl(overrideTagManagementUrl);
        }

        if (enableConsentManager) {
            config.enableConsentManager(instance);
        }

        mTealiumInstanceName = instance;
        if (isLifecycleEnabled) {
            LifeCycle.setupInstance(mTealiumInstanceName, config, true);
        }

        Tealium.createInstance(instance, config);
        result.success(null);
    }

    private void trackEvent(MethodCall call, Result result) {
        trackEventForInstance(mTealiumInstanceName, call, result);
    }

    private void trackEventForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String eventName = (String) arguments.get("eventName");
        final HashMap data = (HashMap) arguments.get("data");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "TrackEvent attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (data != null) {
            instance.trackEvent(eventName, data);
        } else {
            instance.trackEvent(eventName, null);
        }

        result.success(null);
    }

    private void trackView(MethodCall call, Result result) {
        trackViewForInstance(mTealiumInstanceName, call, result);
    }

    private void trackViewForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String viewName = (String) arguments.get("viewName");
        final HashMap data = (HashMap) arguments.get("data");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "TrackView attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (data != null) {
            instance.trackView(viewName, data);
        } else {
            instance.trackView(viewName, null);
        }

        result.success(null);
    }

    private void setVolatileData(MethodCall call, Result result) {
        setVolatileDataForInstance(mTealiumInstanceName, call, result);
    }

    private void setVolatileDataForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final HashMap data = (HashMap) arguments.get("data");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "SetVolatileData attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (data != null) {
            //iterate through data
            Iterator it = data.entrySet().iterator();

            while (it.hasNext()) {
                Map.Entry pair = (Map.Entry) it.next();

                if (pair.getValue() instanceof String || pair.getValue() instanceof ArrayList || pair.getValue() instanceof HashMap) {
                    instance.getDataSources().getVolatileDataSources().put((String) pair.getKey(), pair.getValue());
                }
            }
        }
        result.success(null);
    }

    private void setPersistentData(MethodCall call, Result result) {
        setPersistentDataForInstance(mTealiumInstanceName, call, result);
    }

    private void setPersistentDataForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final HashMap<String, Object> data = (HashMap) arguments.get("data");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(com.tealium.library.BuildConfig.TAG, "SetPersistentData attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        Iterator it = data.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();

            if (pair.getValue() instanceof String) {
                instance.getDataSources().getPersistentDataSources().edit().putString((String) pair.getKey(), (String) pair.getValue()).apply();
            } else if (pair.getValue() instanceof ArrayList) {
                instance.getDataSources().getPersistentDataSources().edit().putStringSet((String) pair.getKey(), arrayToStringSet((ArrayList) pair.getValue())).apply();
            } else {
                throw new IllegalArgumentException("Could not set volatile data for key: " + pair.getKey());
            }
            it.remove(); // avoids a ConcurrentModificationException
        }
    }

    private void removeVolatileData(MethodCall call, Result result) {
        removeVolatileDataForInstance(mTealiumInstanceName, call, result);
    }

    private void removeVolatileDataForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final List<String> keys = (List) arguments.get("keys");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "RemoveVolatileData attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (keys != null) {
            for (String key : keys) {
                instance.getDataSources().getVolatileDataSources().remove(key);
            }
        }
        result.success(null);
    }

    private void removePersistentData(MethodCall call, Result result) {
        removePersistentDataForInstance(mTealiumInstanceName, call, result);

    }

    private void removePersistentDataForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final List<String> keys = (List) arguments.get("keys");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "RemovePersistentData attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (keys != null) {
            for (String key : keys) {
                instance.getDataSources().getPersistentDataSources().edit().remove(key).apply();
            }
        }
        result.success(null);
    }

    private void getVolatileData(MethodCall call, Result result) {
        getVolatileDataForInstance(mTealiumInstanceName, call, result);
    }

    private void getVolatileDataForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String key = (String) arguments.get("key");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "GetVolatileData attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        result.success(instance.getDataSources().getVolatileDataSources().get(key));
    }

    private void getPersistentData(MethodCall call, Result result) {
        getPersistentDataForInstance(mTealiumInstanceName, call, result);
    }

    private void getPersistentDataForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String key = (String) arguments.get("key");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "GetPersistentData attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        Map<String, ?> allPersistentData = instance.getDataSources().getPersistentDataSources().getAll();
        Object data = allPersistentData.get(key);

        if (data instanceof HashSet) {
            data = setToArrayList((HashSet) allPersistentData.get(key));
        }

        result.success(data);
    }

    private void getVisitorId(Result result) {
        getVisitorIdForInstance(mTealiumInstanceName, result);

    }

    private void getVisitorIdForInstance(String instanceName, Result result) {
        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "GetVisitorId attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        result.success(instance.getDataSources().getVisitorId());
    }

    private void getUserConsentStatus(Result result) {
        getUserConsentStatusForInstance(mTealiumInstanceName, result);
    }

    private void getUserConsentStatusForInstance(String instanceName, Result result) {
        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "GetUserConsentStatus attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            result.success(instance.getConsentManager().getUserConsentStatus());
        }
    }

    private void setUserConsentStatus(MethodCall call, Result result) {
        setUserConsentStatusForInstance(mTealiumInstanceName, call, result);
    }

    private void setUserConsentStatusForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final int consentCode = (int) arguments.get("userConsentStatus");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "SetUserConsentStatus attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            instance.getConsentManager().setUserConsentStatus(mapConsentStatus(consentCode));
        }
        result.success(null);
    }

    private void getUserConsentCategories(Result result) {
        getUserConsentCategoriesForInstance(mTealiumInstanceName, result);
    }

    private void getUserConsentCategoriesForInstance(String instanceName, Result result) {
        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "GetUserConsentCategories attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            result.success(Arrays.asList(instance.getConsentManager().getUserConsentCategories()));
        }
    }

    private void setUserConsentCategories(MethodCall call, Result result) {
        setUserConsentCategoriesForInstance(mTealiumInstanceName, call, result);
    }

    private void setUserConsentCategoriesForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        List<String> categories = (ArrayList<String>) arguments.get("categories");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "SetUserConsentCategories attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            //todo set consent categories here
            String[] userConsentCategories = new String[categories.size()];

            for (int i = 0; i < categories.size(); i++) {
                userConsentCategories[i] = categories.get(i);
            }

            instance.getConsentManager().setUserConsentCategories(userConsentCategories);
        }
    }

    private void resetUserConsentPreferences() {
        resetUserConsentPreferencesForInstance(mTealiumInstanceName);
    }

    private void resetUserConsentPreferencesForInstance(String instanceName) {
        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(com.tealium.library.BuildConfig.TAG, "ResetUserConsentPreferences attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            instance.getConsentManager().resetUserConsentPreferences();
        }
    }

    private void setConsentLoggingEnabled(MethodCall call, Result result) {
        setConsentLoggingEnabledForInstance(mTealiumInstanceName, call, result);
    }

    private void setConsentLoggingEnabledForInstance(String instanceName, MethodCall call, Result result) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final boolean isLogging = (boolean) arguments.get("isConsentLoggingEnabled");

        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "SetConsentLoggingEnabled attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            instance.getConsentManager().setConsentLoggingEnabled(isLogging);
        }
    }

    private void isConsentLoggingEnabled(Result result) {
        isConsentLoggingEnabledForInstance(mTealiumInstanceName, result);
    }

    private void isConsentLoggingEnabledForInstance(String instanceName, Result result) {
        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {
            Log.e(BuildConfig.TAG, "IsConsentLoggingEnabled attempted, but Tealium not enabled for instance name: " + instanceName);
        }

        if (instance.getConsentManager() != null) {
            result.success(instance.getConsentManager().isConsentLogging());
        }
    }

    private void addRemoteCommandForInstance(String instance, MethodCall call) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String commandID = (String) arguments.get("commandID");
        final String description = (String) arguments.get("description");
        final Tealium tealium = Tealium.getInstance(instance);
        if (tealium == null) {
            Log.e(BuildConfig.TAG, "addRemoteCommandForInstance attempted, but Tealium not enabled for instance name: " + instance);
            return;
        }
        final RemoteCommand remoteCommand = new RemoteCommand(commandID, description) {
            @Override
            protected void onInvoke(Response response) throws Exception {
                Map<String, Object> args = toMap(response.getRequestPayload());
                mChannel.invokeMethod("callListener", args);
                Log.i(BuildConfig.TAG, "addRemoteCommandForInstance attempted response: " + response);
            }
        };
        tealium.addRemoteCommand(remoteCommand);
        mRemoteCommandsMap.put(commandID, remoteCommand);
    }    

    private void addRemoteCommand(MethodCall call) {
        addRemoteCommandForInstance(mTealiumInstanceName, call);
    }

    private void removeRemoteCommandForInstance(String instance, MethodCall call) {
        Map<String, Object> arguments = (Map<String, Object>) call.arguments;
        final String commandID = (String) arguments.get("commandID");
        final Tealium tealium = Tealium.getInstance(instance);
        if (tealium == null) {
            Log.e(BuildConfig.TAG, "removeRemoteCommandForInstance attempted, but Tealium not enabled for instance name: " + instance);
            return;
        }
        if (mRemoteCommandsMap.get(commandID) != null) {
            tealium.removeRemoteCommand(mRemoteCommandsMap.get(commandID));
            Log.i(BuildConfig.TAG, "Remote command with id `" + commandID + "` has been removed from `" + instance + "`");
        } else {
            Log.d(BuildConfig.TAG, "Remote command with id `" + commandID + "` does not exist");
        }
    } 

    private void removeRemoteCommand(MethodCall call) {
        removeRemoteCommandForInstance(mTealiumInstanceName, call);
    }

    //========================== Helper Functions =============================

    public static Map<String, Object> toMap(JSONObject jsonobj)  throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();
        Iterator<String> keys = jsonobj.keys();
        while(keys.hasNext()) {
            String key = keys.next();
            Object value = jsonobj.get(key);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            map.put(key, value);
        }   return map;
    }

    public static List<Object> toList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();
        for(int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            }
            else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            list.add(value);
        }   return list;
     }

    private String mapConsentStatus(int userConsentStatus) {
        switch (userConsentStatus) {
            case 0:
                return ConsentManager.ConsentStatus.UNKNOWN;
            case 1:
                return ConsentManager.ConsentStatus.CONSENTED;
            case 2:
                return ConsentManager.ConsentStatus.NOT_CONSENTED;
            default:
                return ConsentManager.ConsentStatus.UNKNOWN;
        }
    }

    private Set<String> arrayToStringSet(ArrayList array) {
        Set<String> strSet = new HashSet<>(array);
        return strSet;
    }

    private List setToArrayList(Set strSet) {
        List<String> list = new ArrayList<>(strSet);
        return list;
    }
}
