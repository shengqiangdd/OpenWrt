#!/bin/bash

# 修改默认IP
sed -i 's/192.168.6.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 自动登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/v2ray-geodata

# 替换原 svn 命令
function git_sparse_clone() {
  branch="$1" rurl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch $rurl
  repo=$(echo $rurl | awk -F '/' '{print $(NF)}')
  cd $repo && mv -f $@ ../package
  cd .. && rm -rf $repo
}

# 添加额外插件
git clone https://github.com/Zxilly/UA2F.git package/UA2F
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome

# 科学上网插件
git clone --depth=1 -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

# Themes
git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone --depth=1 https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/luci-theme-infinityfreedom
git_sparse_clone main https://github.com/haiibo/packages luci-theme-atmaterial luci-theme-opentomcat luci-theme-netgear

# 更改 Argon 主题背景
#cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# SmartDNS
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# MosDNS
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Alist
#git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# DDNS.to
#git_sparse_clone main https://github.com/linkease/nas-packages-luci luci/luci-app-ddnsto
#git_sparse_clone master https://github.com/linkease/nas-packages network/services/ddnsto

# iStore
#git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
#git_sparse_clone main https://github.com/linkease/istore luci

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/emortal/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/emortal/default-settings/files/99-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by shengqiangdd/g" package/emortal/default-settings/files/99-default-settings

# 修复 hostapd 报错
cp -f $GITHUB_WORKSPACE/scripts/011-fix-mbo-modules-build.patch package/network/services/hostapd/patches/011-fix-mbo-modules-build.patch

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 调整 ZeroTier 到 服务 菜单
# sed -i 's/vpn/services/g; s/VPN/Services/g' feeds/luci/applications/luci-app-zerotier/luasrc/controller/zerotier.lua
# sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/luasrc/view/zerotier/zerotier_status.htm

# 取消对 samba4 的菜单调整
# sed -i '/samba4/s/^/#/' package/lean/default-settings/files/zzz-default-settings

./scripts/feeds update -a
./scripts/feeds install -a
