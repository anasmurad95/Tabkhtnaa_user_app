# Downloads Figma MCP assets from Phase 0 design context (file vf6Xx7NvM8GBGditNmCUqu)
$base = "https://www.figma.com/api/mcp/asset"
$imgDir = Join-Path $PSScriptRoot "..\assets\images"
$iconDir = Join-Path $PSScriptRoot "..\assets\icons"
New-Item -ItemType Directory -Force -Path $imgDir, $iconDir | Out-Null

$assets = @{
  "splash_bg_food.png" = "$base/164e66cd-6543-4782-add9-cc6d41f4b9de"
  "splash_logo_main.png" = "$base/ac64b925-1d71-45aa-97f5-7e7627c9af45"
  "login_bg_food.png" = "$base/fc1165de-2ddc-44bf-acbe-1e6397edb779"
  "login_header_wave.png" = "$base/54bec44a-5495-4465-82ae-be585dae04b3"
  "login_hero_house.png" = "$base/4a90451e-489b-4ef3-8d94-a130421a1179"
  "profile_header_wave.png" = "$base/cba46765-dee0-4888-be39-dc6294700a13"
  "profile_avatar_sample.png" = "$base/1975fa56-ede1-4134-b78f-4d9f727a6328"
  "splash_bottom_wave.png" = "$base/9aca49a3-a04b-4613-8883-0eec06a51d62"
}

$icons = @{
  "globe_white.png" = "$base/292b8700-b649-424e-9efd-7fa30f3be0a3"
  "chevron_up_orange.png" = "$base/db6caa70-e58e-4962-b99f-bac3afd229f8"
  "chevron_down_white.png" = "$base/89623d1a-548e-4513-abad-1f453bcd5c11"
  "login_back_white.png" = "$base/92f3c0a1-7632-4d44-a44a-19dc78b78e7b"
  "login_user_grey.png" = "$base/a0f1e034-78c2-4aa6-b41a-ab91553a8da7"
  "login_password_grey.png" = "$base/88419f20-48ba-44ea-9768-66e018ab159d"
  "facebook_white.png" = "$base/a00f6bee-8a21-4113-9a0c-4038db8ae04c"
  "google_white.png" = "$base/f0701ac1-4a32-472c-b3c8-a872c8c80a53"
  "profile_back_white.png" = "$base/5e254ce7-5981-41a5-9636-94fead42b367"
  "profile_chevron_orange.png" = "$base/4da9ab07-cab5-495f-a3cc-d3280f961a80"
  "profile_settings_orange.png" = "$base/608084bc-9cce-4822-89e6-d069a8038f99"
  "profile_star_orange.png" = "$base/e8a73769-3935-4b9c-baa7-1ae7444fb28b"
  "profile_orders.png" = "$base/34874e04-80e4-4106-b241-662086c350db"
  "profile_notification.png" = "$base/3ae112ad-9331-4e2e-afba-8ab4743e3feb"
  "profile_logout.png" = "$base/d4f0c464-aee7-4c3f-b156-0a028691d87e"
  "nav_more.png" = "$base/81f4f048-ce89-4d31-a485-58fadf5185bd"
}

function Download-Asset($url, $path) {
  try {
    Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
    Write-Host "OK $path"
  } catch {
    Write-Host "FAIL $path : $_"
  }
}

foreach ($kv in $assets.GetEnumerator()) {
  Download-Asset $kv.Value (Join-Path $imgDir $kv.Key)
}
foreach ($kv in $icons.GetEnumerator()) {
  Download-Asset $kv.Value (Join-Path $iconDir $kv.Key)
}

Write-Host "Done."
