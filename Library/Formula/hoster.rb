class Hoster < Formula
  desc "Project-scoped /etc/hosts management for local, dev, hlg and prod environments"
  homepage "https://github.com/helmedeiros/hoster"
  url "https://github.com/helmedeiros/hoster/releases/download/1.7.2-IURI/hoster-1.7.2-IURI-as.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/helmedeiros/hoster.git", branch: "master"

  depends_on "tree"

  def install
    prefix.install Dir["*"].reject { |f| f["*.py"] }
    system "python3", prefix/"Library/Setup/setup.py", prefix, version
    man.mkpath
  end

  test do
    system bin/"hoster", "--version"
    system bin/"hoster", "init"
    system bin/"hoster", "add", "127.0.0.1", "www.test.com", "--dev"
    system bin/"hoster", "list"
  end
end
