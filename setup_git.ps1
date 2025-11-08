# Git 初始化脚本
# 用于设置 Git 用户信息（如果需要）

Write-Host "检查 Git 配置..." -ForegroundColor Cyan

# 检查是否已设置用户名
$userName = git config --global user.name
if (-not $userName) {
    Write-Host "未检测到 Git 用户名，请输入您的姓名:" -ForegroundColor Yellow
    $inputName = Read-Host
    if ($inputName) {
        git config --global user.name $inputName
        Write-Host "已设置 Git 用户名为: $inputName" -ForegroundColor Green
    }
}

# 检查是否已设置邮箱
$userEmail = git config --global user.email
if (-not $userEmail) {
    Write-Host "未检测到 Git 邮箱，请输入您的邮箱:" -ForegroundColor Yellow
    $inputEmail = Read-Host
    if ($inputEmail) {
        git config --global user.email $inputEmail
        Write-Host "已设置 Git 邮箱为: $inputEmail" -ForegroundColor Green
    }
}

# 显示当前配置
Write-Host "`n当前 Git 配置:" -ForegroundColor Cyan
Write-Host "  用户名: $(git config --global user.name)" -ForegroundColor White
Write-Host "  邮箱: $(git config --global user.email)" -ForegroundColor White

Write-Host "`nGit configuration completed!" -ForegroundColor Green

