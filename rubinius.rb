require 'formula'

class Rubinius < Formula
  url 'http://asset.rubini.us/rubinius-1.0.0-20100514.tar.gz'
  version '1.0.0'
  homepage 'http://rubini.us/'
  md5 'b05f4e791d3712c5a50b3d210dac6eb0'
  head 'git://github.com/evanphx/rubinius.git'

  aka "rbx"

  # Do not strip binaries, or else it fails to run.
  def skip_clean?(path); true end

  def install
    # Let Rubinius define its own flags; messing with these causes build breaks.
    %w{CC CXX LD CFLAGS CXXFLAGS CPPFLAGS LDFLAGS}.each { |e| ENV.delete(e) }

    ENV['RELEASE'] = "#{version}" # to fix issues with "path already exists"

    # "--skip-system" means to use the included LLVM
    system "./configure", "--skip-system",
                          "--prefix", "#{prefix}",
                          "--includedir", "#{include}/rubinius",
                          "--libdir", lib,
                          "--mandir", man, # For completeness; no manpages exist yet.
                          "--gemsdir", "#{lib}/rubinius/gems"

    ohai "config.rb", File.open('config.rb').to_a if ARGV.debug? or ARGV.verbose?

    system "/usr/bin/ruby", "-S", "rake", "install"
  end
end
