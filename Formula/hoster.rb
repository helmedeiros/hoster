require "formula"

# Documentation: https://github.com/Homebrew/homebrew/wiki/Formula-Cookbook
#                /usr/local/Library/Contributions/example-formula.rb
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Hoster < Formula
  homepage "https://github.com/helmedeiros/hoster"
  head "https://github.com/iuriandreazza/hoster.git" 
  url "https://github.com/iuriandreazza/hoster/releases/download/0.1/hoster-0.1-as.tar.gz"
  sha1 "89d0acc94d4d7572b9d08bbcda14d2f1c2454e78"

  # depends_on "cmake" => :build
  depends_on :python # if your formula requires any X11/XQuartz components

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    prefix.install Dir['./*.sh','./builtin/*']
    man.mkpath
    system "python","setup.py"
    
    #install Dir['builtin/*']

    # Remove unrecognized options if warned by configure
    #system "./configure", "--disable-debug",
    #                      "--disable-dependency-tracking",
    #                      "--disable-silent-rules",
    #                      "--prefix=#{prefix}"
    # system "cmake", ".", *std_cmake_args
    #system "make", "install" # if this fails, try separate make/make install steps
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test hoster`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end