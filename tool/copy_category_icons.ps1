$ErrorActionPreference = 'Stop'
$src = Join-Path $PSScriptRoot '..\..\..\BackEnd\Tabkhtnaa\public\images\categorise'
$dst = Join-Path $PSScriptRoot '..\assets\images\categories'
New-Item -ItemType Directory -Force -Path $dst | Out-Null

$map = [ordered]@{
  'appetizers' = 'Appetizers-01.png'
  'asian_food' = 'Asian food-01.png'
  'aslan_food' = 'Asian food-01.png'
  'bakery' = 'Bakery-01.png'
  'barbeque' = 'Barbeque-01.png'
  'dessert' = 'Dessert-01.png'
  'drinks' = 'Drinks-01.png'
  'fast_food' = 'Fast food-01.png'
  'frozen' = 'Frozen-01.png'
  'healthy_food' = 'Healthy food-01.png'
  'orders' = 'Orders-01.png'
  'oriental_food' = 'Oriental food-01.png'
  'pasta' = 'Pasta-01.png'
  'pickels' = 'Pickels-01.png'
  'salad' = 'Salad-01.png'
  'sandwiches' = 'Sandwiches-01.png'
  'soup' = 'Soup-01.png'
  'spicy' = 'Spicy-01.png'
  'western' = 'Western-01.png'
}

$copied = 0
foreach ($entry in $map.GetEnumerator()) {
  $from = Join-Path $src $entry.Value
  $to = Join-Path $dst ($entry.Key + '.png')
  if (-not (Test-Path $from)) {
    Write-Output "MISSING $from"
    continue
  }
  Copy-Item -LiteralPath $from -Destination $to -Force
  $copied++
  Write-Output "OK $($entry.Key)"
}

$files = Get-ChildItem -LiteralPath $dst -File -Filter '*.png' | Sort-Object Name
Write-Output "COPIED=$copied"
Write-Output "TOTAL=$($files.Count)"
foreach ($f in $files) { Write-Output $f.Name }
