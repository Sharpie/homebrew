require 'brewkit'

class Scummvm <Formula
  @url='http://downloads.sourceforge.net/project/scummvm/scummvm/1.0.0rc1/scummvm-1.0.0rc1.tar.bz2'
  @homepage='http://www.scummvm.org/'
  @md5='f3fabedc7ff2424d6a4bc678229b22ce'

  def caveats
    <<-EOS
ScummVM provide their own Mac build and as such that is the one they
officially support on this platform. Ours is more optimised, but you may
prefer to use theirs. If so type `brew home scummvm' to visit their site.
    EOS
  end

  depends_on 'sdl'
  depends_on 'flac' => :recommended
  depends_on 'libvorbis' => :recommended
  depends_on 'libogg' => :recommended

  def install
    system "./configure --prefix='#{prefix}' --disable-debug"
    system "make install"
    share=prefix+'share'
    (share+'scummvm'+'scummmodern.zip').unlink
    (share+'pixmaps').rmtree
  end
end
