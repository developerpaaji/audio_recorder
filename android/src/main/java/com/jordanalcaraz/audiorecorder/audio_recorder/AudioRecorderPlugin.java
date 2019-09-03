package com.jordanalcaraz.audiorecorder.audiorecorder;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.MediaRecorder;
import android.os.Environment;
import android.util.Log;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AudioRecorderPlugin
 */
public class AudioRecorderPlugin implements MethodCallHandler {
  private final Registrar registrar;
  private boolean isRecording = false;
  private static final String LOG_TAG = "AudioRecorder";
  private static MediaRecorder mRecorder = null;
  private static String mFilePath = null;
  private Date startTime = null;
  private String mExtension = "";
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "audio_recorder");
    channel.setMethodCallHandler(new AudioRecorderPlugin(registrar));

  }

  private AudioRecorderPlugin(Registrar registrar){
    this.registrar = registrar;
  }

  int count=0;

  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "start":
        Log.d(LOG_TAG, "Start");
        String path = call.argument("path");
        mExtension = ".amr";
        startTime = Calendar.getInstance().getTime();
        if (path != null) {
          mFilePath = path;
        } else {
          String fileName = String.valueOf(startTime.getTime());
          mFilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + fileName + mExtension;
        }
        Log.d(LOG_TAG, mFilePath);
        startRecording();
        isRecording = true;
        result.success(null);
        break;
      case "pause":
        Log.d(LOG_TAG, "Pause");
        if(mRecorder!=null){
          mRecorder.pause();
          result.success(true);
        }
        else{
          result.success(false);
        }
        break;
      case "resume":
        Log.d(LOG_TAG, "Resume");
        if(mRecorder!=null){
          mRecorder.resume();
          result.success(true);
        }
        else{
          result.success(false);
        }
        break;
      case "stop":
        Log.d(LOG_TAG, "Stop");
        stopRecording();
        long duration = Calendar.getInstance().getTime().getTime() - startTime.getTime();
        Log.d(LOG_TAG, "Duration : " + String.valueOf(duration));
        isRecording = false;
        HashMap<String, Object> recordingResult = new HashMap<>();
        recordingResult.put("duration", duration);
        recordingResult.put("path", mFilePath);
        recordingResult.put("audioOutputFormat", mExtension);
        result.success(recordingResult);
        break;
      case "isRecording":
        Log.d(LOG_TAG, "Get isRecording");
        result.success(isRecording);
        break;
      case "hasPermissions":
        Log.d(LOG_TAG, "Get hasPermissions");
        Context context = registrar.context();
        PackageManager pm = context.getPackageManager();
        int hasStoragePerm = pm.checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE, context.getPackageName());
        int hasRecordPerm = pm.checkPermission(Manifest.permission.RECORD_AUDIO, context.getPackageName());
        int hasReadContact = pm.checkPermission(Manifest.permission.READ_CONTACTS, context.getPackageName());
        int hasReadPhonePerm=pm.checkPermission(Manifest.permission.READ_PHONE_STATE, context.getPackageName());
        int hasCoarsePerm=pm.checkPermission(Manifest.permission.ACCESS_COARSE_LOCATION,context.getPackageName());
        boolean hasPermissions =
                hasStoragePerm == PackageManager.PERMISSION_GRANTED &&
                        hasRecordPerm == PackageManager.PERMISSION_GRANTED&&
                        hasReadContact==PackageManager.PERMISSION_GRANTED&&
                        hasReadPhonePerm== PackageManager.PERMISSION_GRANTED&&
                        hasCoarsePerm==PackageManager.PERMISSION_GRANTED;
        result.success(hasPermissions);
        break;
      default:
        result.notImplemented();
        break;
    }
  }


  private void startRecording() {

    mRecorder = new MediaRecorder();
    Log.d(LOG_TAG, "Media Recorder "+(mRecorder!=null)+" "+(++count));
    mRecorder.setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION);
    mRecorder.setOutputFormat(MediaRecorder.OutputFormat.AMR_WB);
    mRecorder.setOutputFile(mFilePath);
    mRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_WB);
    mRecorder.setAudioChannels(1);
    mRecorder.setAudioSamplingRate(16000);
    try {
      mRecorder.prepare();
    } catch (IOException e) {
      Log.e(LOG_TAG, "prepare() failed");
    }

    mRecorder.start();
  }



  private void stopRecording() {
    if (mRecorder != null){
      mRecorder.stop();
      mRecorder.reset();
      mRecorder.release();
      mRecorder = null;
    }
  }
  private TelephonyManager mTelephonyManager;
  private void callPhoneManager(){
    Context context = registrar.context();
    mTelephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
    mTelephonyManager.listen(new PhoneCallback(), PhoneStateListener.LISTEN_CALL_STATE
            | PhoneStateListener.LISTEN_CELL_INFO // Requires API 17
            | PhoneStateListener.LISTEN_CELL_LOCATION
            | PhoneStateListener.LISTEN_DATA_ACTIVITY
            | PhoneStateListener.LISTEN_DATA_CONNECTION_STATE
            | PhoneStateListener.LISTEN_SERVICE_STATE
            | PhoneStateListener.LISTEN_SIGNAL_STRENGTHS
            | PhoneStateListener.LISTEN_CALL_FORWARDING_INDICATOR
            | PhoneStateListener.LISTEN_MESSAGE_WAITING_INDICATOR);
  }
}