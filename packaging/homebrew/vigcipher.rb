class Vigcipher < Formula
  desc "Apply a Vigenère cipher to stdin and write the result to stdout"
  homepage "https://github.com/RedRoosterKey/vigcipher"
  url "https://github.com/RedRoosterKey/vigcipher/archive/refs/tags/v0.0.5.tar.gz"
  sha256 "e2b436420f72b06fa55b7d3a239ca17b252717e49f0c52f9cd6df00867d387e1"
  license "GPL-3.0-or-later"
  head "https://github.com/RedRoosterKey/vigcipher.git", branch: "master"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_match(/^\d+\.\d+\.\d+$/, shell_output("#{bin}/vigcipher --version"))
    assert_equal "mygpqw fg sois",
                 pipe_output("#{bin}/vigcipher -e -p -q LC -k lemon", "attack at dawn")
  end
end
