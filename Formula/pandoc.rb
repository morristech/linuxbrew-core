require "language/haskell"

class Pandoc < Formula
  include Language::Haskell::Cabal

  desc "Swiss-army knife of markup format conversion"
  homepage "https://pandoc.org/"
  url "https://hackage.haskell.org/package/pandoc-2.7.1/pandoc-2.7.1.tar.gz"
  sha256 "5e2a51f130e0fb39f615f7b9705f8e152156e30de4a71e1c900d1ae2ec8d1eb8"
  head "https://github.com/jgm/pandoc.git"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    rebuild 1
    sha256 "9b72d0209f028c8f14ca8a078f838898b65fc188d9f65d0267e50f864050f663" => :mojave
    sha256 "cd0e7ba4201a3fefa90dae0ec70e66dd427a4d5104de749e56bed0ea28e3af8f" => :high_sierra
    sha256 "81f9bc5ce14964ff46fc2cb6afa624a3105258e4c3cb5eae635525c4b860aac7" => :sierra
    sha256 "8b462bfe3eedc245d77d5ecf2554c3c8ce2b28c800922d6a9ce7b876dab9e56b" => :x86_64_linux
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  unless OS.mac?
    depends_on "unzip" => :build # for cabal install
    depends_on "zlib"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j2" if ENV["CIRCLECI"]

    cabal_sandbox do
      install_cabal_package
    end
    (bash_completion/"pandoc").write `#{bin}/pandoc --bash-completion`
    man1.install "man/pandoc.1"
  end

  test do
    input_markdown = <<~EOS
      # Homebrew

      A package manager for humans. Cats should take a look at Tigerbrew.
    EOS
    expected_html = <<~EOS
      <h1 id="homebrew">Homebrew</h1>
      <p>A package manager for humans. Cats should take a look at Tigerbrew.</p>
    EOS
    assert_equal expected_html, pipe_output("#{bin}/pandoc -f markdown -t html5", input_markdown)
  end
end
