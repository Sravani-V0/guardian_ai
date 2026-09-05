package com.example.guardian_ai

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "guardian_ai/phone"
    private val CALL_PERMISSION_REQUEST = 1001

    private var pendingPhoneNumber: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "makeDirectCall" -> {

                    val phoneNumber =
                        call.argument<String>("phoneNumber")

                    if (phoneNumber.isNullOrBlank()) {
                        result.error(
                            "INVALID_NUMBER",
                            "Emergency phone number is empty.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    if (
                        ContextCompat.checkSelfPermission(
                            this,
                            Manifest.permission.CALL_PHONE
                        ) != PackageManager.PERMISSION_GRANTED
                    ) {
                        pendingPhoneNumber = phoneNumber

                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(Manifest.permission.CALL_PHONE),
                            CALL_PERMISSION_REQUEST
                        )

                        result.success(false)
                    } else {
                        makePhoneCall(phoneNumber)
                        result.success(true)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun makePhoneCall(phoneNumber: String) {

        val intent = Intent(
            Intent.ACTION_CALL,
            Uri.parse("tel:$phoneNumber")
        )

        if (
            ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.CALL_PHONE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        startActivity(intent)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        if (requestCode == CALL_PERMISSION_REQUEST) {

            if (
                grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {
                pendingPhoneNumber?.let {
                    makePhoneCall(it)
                }
            }

            pendingPhoneNumber = null
        }
    }
}