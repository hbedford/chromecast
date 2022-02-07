package com.puzzl.chromecast

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

public class ChromecastPlugin: FlutterPlugin, ActivityAware {
  private lateinit var chromeCastFactory: ChromeCastFactory

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    chromeCastFactory = ChromeCastFactory(flutterPluginBinding.binaryMessenger)
    flutterPluginBinding
      .platformViewRegistry
      .registerViewFactory(
        "ChromeCastButton",
        chromeCastFactory
      )
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    chromeCastFactory.activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onDetachedFromActivity() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }
}