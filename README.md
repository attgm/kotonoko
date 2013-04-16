#コトノコ
コトノコ（言の庫）は、Mac OS Xで動作する EPWING ビューワです.  
KOTONOKO is EPWING viewer for Mac OS X.

#Buliding
コトノコのmakeには, libebが必要です. 入手できない場合は, Ubuntuなどからソースパッケージを取得すると良いと思われます. [http://packages.ubuntu.com/](http://http://packages.ubuntu.com/)

ます, libebの構築を行う必要があります.
libebは eblib/ 以下に展開し, patchがある場合はpatchをあててください.

	cd eblib/eb-4.4.3
	patch -p1 < ../eb-4.4.3-kotonoko-patch
	
eblib/eb/build-post.hを作成する必要があります. 面倒ならば全部makeしてしまってもかまいません.

	./configure
	cd eb
	make build-post.h
	
ここまでで, ebooks.xcodeprojを開けば問題ないはずです. もし, パスの違いなどでファイルへの参照が切れている場合は, 適宜修正してください.



