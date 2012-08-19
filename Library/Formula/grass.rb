require 'formula'

def postgres?
    ARGV.include? "--with-postgres"
end

def mysql?
    ARGV.include? "--with-mysql"
end

class Grass < Formula
  homepage 'http://grass.osgeo.org/'
  url 'http://grass.osgeo.org/grass64/source/grass-6.4.2.tar.gz'
  sha1 '74481611573677d90ae0cd446c04a3895e232004'

  head 'https://svn.osgeo.org/grass/grass/trunk'

  option 'with-postgres', 'Specify PostgreSQL as a dependency'
  option 'with-mysql', 'Specify MySQL as a dependency'
  option 'without-gui', 'Build without WxPython interface. Command line tools still available.'

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "readline"
  depends_on "gdal"
  depends_on "libtiff"
  depends_on "unixodbc"
  depends_on "fftw"
  depends_on "cairo" if MacOS.version == :leopard
  depends_on :x11

  unless build.include? 'without-gui'
    depends_on 'wxmac' if MacOS.prefer_64_bit?
  end

  # Patch out a portion of the Makefile that tries to install stuff to
  # /Library/Documentation. Reported upstream:
  #   http://trac.osgeo.org/grass/ticket/1644
  def patches; DATA; end

  fails_with :clang do
    build 421

    cause <<-EOS.undent
      Multiple build failures while compiling GRASS tools.
      EOS
  end

  def install
    readline = Formula.factory('readline')
    gettext = Formula.factory('gettext')

    args = [
      "--disable-debug", "--disable-dependency-tracking",
      "--with-libs=#{MacOS::X11.lib} #{HOMEBREW_PREFIX}/lib",
      "--with-includes=#{HOMEBREW_PREFIX}/include",
      "--enable-largefile",
      "--enable-shared",
      "--with-cxx",
      "--with-opengl=aqua",
      "--with-x",
      "--without-motif",
      "--with-python=/usr/bin/python-config",
      "--with-blas",
      "--with-lapack",
      "--with-sqlite",
      "--with-odbc",
      "--with-geos=#{HOMEBREW_PREFIX}/bin/geos-config",
      "--with-png-includes=#{MacOS::X11.include}",
      "--with-png",
      "--with-readline-includes=#{readline.include}",
      "--with-readline-libs=#{readline.lib}",
      "--with-readline",
      "--with-nls-includes=#{gettext.include}",
      "--with-nls-libs=#{gettext.lib}",
      "--with-nls",
      "--with-freetype-includes=#{MacOS::X11.include} #{MacOS::X11.include}/freetype2",
      "--with-freetype",
      "--without-tcltk" # Disabled due to compatibility issues with OS X Tcl/Tk
    ]

    args << "--without-wxwidgets" if build.include? 'without-gui'

    if MacOS.prefer_64_bit?
      args << "--enable-64bit"
      args << "--with-macosx-archs=x86_64"
      # 64-bit installations have to use our wxmac config.
      args << "--with-wxwidgets=#{HOMEBREW_PREFIX}/bin/wx-config" unless build.include? 'without-gui'
    else
      args << "--with-macosx-archs=i386"
      # 32-bit installations can use whatever they want.
      args << "--with-wxwidgets=#{which 'wx-config'}" unless build.include? 'without-gui'
    end

    # Deal with Cairo support
    if MacOS.version == :leopard
      cairo = Formula.factory('cairo')
      args << "--with-cairo-includes=#{cairo.include}/cairo"
      args << "--with-cairo-libs=#{cairo.lib}"
    else
      args << "--with-cairo-includes=#{MacOS::X11.include} #{MacOS::X11.include}/cairo"
    end

    args << "--with-cairo"

    # Database support
    args << "--with-postgres" if postgres?
    if mysql?
      mysql = Formula.factory('mysql')
      args << "--with-mysql-includes=#{mysql.include + 'mysql'}"
      args << "--with-mysql-libs=#{mysql.lib + 'mysql'}"
      args << "--with-mysql"
    end

    system "./configure", "--prefix=#{prefix}", *args
    system "make" # make and make install must be separate steps.
    system "make install"
  end
end

__END__
Remove two lines of the Makefile that try to install stuff to
/Library/Documentation---which is outside of the prefix and usually fails due
to permissions issues.

diff --git a/Makefile b/Makefile
index f1edea6..be404b0 100644
--- a/Makefile
+++ b/Makefile
@@ -304,8 +304,6 @@ ifeq ($(strip $(MINGW)),)
 	-tar cBf - gem/skeleton | (cd ${INST_DIR}/etc ; tar xBf - ) 2>/dev/null
 	-${INSTALL} gem/gem$(GRASS_VERSION_MAJOR)$(GRASS_VERSION_MINOR) ${BINDIR} 2>/dev/null
 endif
-	@# enable OSX Help Viewer
-	@if [ "`cat include/Make/Platform.make | grep -i '^ARCH.*darwin'`" ] ; then /bin/ln -sfh "${INST_DIR}/docs/html" /Library/Documentation/Help/GRASS-${GRASS_VERSION_MAJOR}.${GRASS_VERSION_MINOR} ; fi
 
 
 install-strip: FORCE
