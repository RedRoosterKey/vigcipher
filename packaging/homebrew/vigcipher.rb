class Vigcipher < Formula
  desc "Apply a Vigenère cipher to stdin and write the result to stdout"
  homepage "https://github.com/RedRoosterKey/vigcipher"
  url "https://github.com/RedRoosterKey/vigcipher/archive/refs/tags/v0.0.5.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_THE_TAG_TARBALL"
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
