$urls = @(
  'https://console.cloud.google.com/apis/credentials',
  'https://developers.tiktok.com',
  'https://developer.x.com/en/portal',
  'https://developers.facebook.com',
  'https://www.linkedin.com/developers',
  'https://developers.pinterest.com',
  'https://open.douyin.com',
  'https://open.kuaishou.com',
  'https://openhome.bilibili.com',
  'https://mp.weixin.qq.com'
)

foreach ($url in $urls) {
  Start-Process $url
  Start-Sleep -Milliseconds 250
}

Write-Host 'Opened developer credential portals. Relay is still recommended if you do not want to apply for every platform credential.'
