package com.toyoichy.kaliminipc

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val KaliBlue = Color(0xFF367BF5)
private val Night = Color(0xFF10141D)
private val Panel = Color(0xFF1B2330)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = darkColorScheme(primary = KaliBlue, background = Night, surface = Panel)) {
                KaliMiniPcApp()
            }
        }
    }
}

private enum class UiMode { MOBILE, DESKTOP }

@Composable
private fun KaliMiniPcApp() {
    var mode by rememberSaveable { mutableStateOf(UiMode.MOBILE) }
    Surface(modifier = Modifier.fillMaxSize(), color = Night) {
        Column(
            modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("KALI MINI PC", color = Color.White, fontSize = 23.sp, fontWeight = FontWeight.Bold)
                    Text("Linux in your pocket", color = Color.LightGray, fontSize = 13.sp)
                }
                Text("ARM64", color = KaliBlue, fontWeight = FontWeight.Bold)
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                ModeButton("Mobile", mode == UiMode.MOBILE, Modifier.weight(1f)) { mode = UiMode.MOBILE }
                ModeButton("Desktop", mode == UiMode.DESKTOP, Modifier.weight(1f)) { mode = UiMode.DESKTOP }
            }
            Card(colors = CardDefaults.cardColors(containerColor = Panel), shape = RoundedCornerShape(22.dp)) {
                Column(Modifier.padding(18.dp)) {
                    Text(if (mode == UiMode.MOBILE) "Mobile workspace" else "Desktop workspace",
                        color = Color.White, fontSize = 19.sp, fontWeight = FontWeight.SemiBold)
                    Spacer(Modifier.height(8.dp))
                    Text(
                        if (mode == UiMode.MOBILE) "Touch-first controls for your Kali environment."
                        else "The XFCE desktop session will appear here when the Linux runtime is ready.",
                        color = Color.LightGray
                    )
                    Spacer(Modifier.height(18.dp))
                    Box(
                        modifier = Modifier.fillMaxWidth()
                            .height(if (mode == UiMode.MOBILE) 170.dp else 220.dp)
                            .background(Color(0xFF0B1C37), RoundedCornerShape(16.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("KALI", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Black)
                            Text(if (mode == UiMode.MOBILE) "Mobile interface preview" else "XFCE desktop preview",
                                color = Color(0xFF9FC2FF), fontSize = 12.sp)
                        }
                    }
                }
            }
            Card(colors = CardDefaults.cardColors(containerColor = Panel)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Linux runtime", color = Color.White, fontWeight = FontWeight.Bold)
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(Modifier.size(9.dp).background(Color(0xFFFFB74D), RoundedCornerShape(50)))
                        Text("  Not installed", color = Color(0xFFFFD18A), fontSize = 13.sp)
                    }
                    Text("Kali Linux ARM64 root filesystem is not installed yet.",
                        color = Color.LightGray, fontSize = 13.sp)
                    Button(onClick = {}, enabled = false, modifier = Modifier.fillMaxWidth()) {
                        Text("Install Kali Linux — coming soon")
                    }
                }
            }
            Text("QUICK ACCESS", color = Color(0xFF9FC2FF), fontSize = 12.sp, fontWeight = FontWeight.Bold)
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                QuickCard("Terminal", "Shell", Modifier.weight(1f))
                QuickCard("Files", "Rootfs", Modifier.weight(1f))
                QuickCard("Packages", "APT", Modifier.weight(1f))
            }
            Text("Early development build · Rootless · No UBL required", color = Color.Gray, fontSize = 11.sp)
        }
    }
}

@Composable
private fun ModeButton(label: String, selected: Boolean, modifier: Modifier = Modifier, onClick: () -> Unit) {
    if (selected) Button(onClick = onClick, modifier = modifier) { Text(label) }
    else OutlinedButton(onClick = onClick, modifier = modifier) { Text(label) }
}

@Composable
private fun QuickCard(title: String, subtitle: String, modifier: Modifier = Modifier) {
    Card(modifier = modifier, colors = CardDefaults.cardColors(containerColor = Panel)) {
        Column(Modifier.padding(12.dp)) {
            Text(title, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 13.sp)
            Text(subtitle, color = Color.LightGray, fontSize = 11.sp)
        }
    }
}
