$urls = @(
  'https://github.com/login',
  'https://aitoearn.ai',
  'https://aitoearn.cn',
  'https://www.douyin.com',
  'https://www.xiaohongshu.com',
  'https://www.kuaishou.com',
  'https://www.bilibili.com',
  'https://www.tiktok.com',
  'https://www.youtube.com',
  'https://www.facebook.com',
  'https://www.instagram.com',
  'https://www.threads.net',
  'https://x.com',
  'https://www.pinterest.com',
  'https://www.linkedin.com'
)

foreach ($url in $urls) {
  Start-Process $url
  Start-Sleep -Milliseconds 250
}

Write-Host 'Opened pre-login tabs for GitHub, AiToEarn, and supported social platforms.'
