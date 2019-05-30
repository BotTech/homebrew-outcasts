class ImagemagickAT6 < Formula
  desc "Tools and libraries to manipulate images in many formats"
  homepage "https://www.imagemagick.org/"
  # Please always keep the Homebrew mirror as the primary URL as the
  # ImageMagick site removes tarballs regularly which means we get issues
  # unnecessarily and older versions of the formula are broken.
  url "https://dl.bintray.com/homebrew/mirror/imagemagick%406-6.9.10-3.tar.xz"
  mirror "https://www.imagemagick.org/download/ImageMagick-6.9.10-3.tar.xz"
  sha256 "92d15a4b617583998ce10dfa7aa85da2c5c216b4052a2d454aa50d07ee1e585a"
  head "https://github.com/imagemagick/imagemagick6.git"

  bottle do
    sha256 "487b532e7f8d8a9dc34aedd8493690adf7a00351103b64a18ed90ac29d271a9e" => :high_sierra
    sha256 "1b8016f2f6cedbbcc78326b64172c96bc519b00fd8743ba1bdde2e9b92957f32" => :sierra
    sha256 "8475cb7aed67e3974c67f915a18da97908fd4c7b6483c0a5d91bccfaf1962934" => :el_capitan
  end

  keg_only :versioned_formula

  option "with-fftw", "Compile with FFTW support"
  option "with-hdri", "Compile with HDRI support"
  option "with-opencl", "Compile with OpenCL support"
  option "with-openmp", "Compile with OpenMP support"
  option "with-perl", "Compile with PerlMagick"
  option "without-magick-plus-plus", "disable build/install of Magick++"
  option "without-modules", "Disable support for dynamically loadable modules"
  option "without-threads", "Disable threads support"
  option "with-zero-configuration", "Disables depending on XML configuration files"

  deprecated_option "enable-hdri" => "with-hdri"
  deprecated_option "with-gcc" => "with-openmp"
  deprecated_option "with-jp2" => "with-openjpeg"

  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "pkg-config" => :build
  depends_on "libtool"
  depends_on "xz"

  depends_on "jpeg" => :recommended
  depends_on "libpng" => :recommended
  depends_on "libtiff" => :recommended
  depends_on "freetype" => :recommended

  depends_on "fontconfig" => :optional
  depends_on "little-cms" => :optional
  depends_on "little-cms2" => :optional
  depends_on "libwmf" => :optional
  depends_on "librsvg" => :optional
  depends_on "liblqr" => :optional
  depends_on "openexr" => :optional
  depends_on "ghostscript" => :optional
  depends_on "webp" => :optional
  depends_on "openjpeg" => :optional
  depends_on "fftw" => :optional
  depends_on "pango" => :optional
  depends_on "perl" => :optional

  if build.with? "openmp"
    depends_on "gcc"
    fails_with :clang
  end

  skip_clean :la

  patch :DATA

  def install
    args = %W[
      --disable-osx-universal-binary
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-shared
      --enable-static
    ]

    if build.without? "modules"
      args << "--without-modules"
    else
      args << "--with-modules"
    end

    if build.with? "opencl"
      args << "--enable-opencl"
    else
      args << "--disable-opencl"
    end

    if build.with? "openmp"
      args << "--enable-openmp"
    else
      args << "--disable-openmp"
    end

    if build.with? "webp"
      args << "--with-webp=yes"
    else
      args << "--without-webp"
    end

    if build.with? "openjpeg"
      args << "--with-openjp2"
    else
      args << "--without-openjp2"
    end

    args << "--without-gslib" if build.without? "ghostscript"
    args << "--with-perl" << "--with-perl-options='PREFIX=#{prefix}'" if build.with? "perl"
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? "ghostscript"
    args << "--without-magick-plus-plus" if build.without? "magick-plus-plus"
    args << "--enable-hdri=yes" if build.with? "hdri"
    args << "--without-fftw" if build.without? "fftw"
    args << "--without-pango" if build.without? "pango"
    args << "--without-threads" if build.without? "threads"
    args << "--with-rsvg" if build.with? "librsvg"
    args << "--without-x" if build.without? "x11"
    args << "--with-fontconfig=yes" if build.with? "fontconfig"
    args << "--with-freetype=yes" if build.with? "freetype"
    args << "--enable-zero-configuration" if build.with? "zero-configuration"
    args << "--without-wmf" if build.without? "libwmf"

    # versioned stuff in main tree is pointless for us
    system "autoconf"
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"
    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match "PNG", shell_output("#{bin}/identify #{test_fixtures("test.png")}")
    # Check support for recommended features and delegates.
    features = shell_output("#{bin}/convert -version")
    %w[Modules freetype jpeg png tiff].each do |feature|
      assert_match feature, features
    end
  end
end
__END__
diff --git a/configure.ac b/configure.ac
index 9845e9b..0ac4a3f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1281,12 +1281,15 @@ if test "$with_magick_plus_plus" = 'yes'; then
     AC_LANG([C++])
     AC_PROG_CXX
     AX_CXX_BOOL
+    AX_CXX_COMPILE_STDCXX_11()
     AX_CXX_NAMESPACES
     AX_CXX_NAMESPACE_STD
     AC_CXX_HAVE_STD_LIBS
     AC_OPENMP([C++])
     AC_LANG_POP

+    CXXFLAGS="-std=c++11 $CXXFLAGS"
+
     AC_MSG_CHECKING([whether C++ compiler is sufficient for Magick++])
     if \
         test $ax_cv_cxx_bool = 'yes' && \
diff --git a/configure b/configure
index 15724dc..6809fa3 100755
--- a/configure
+++ b/configure
@@ -27544,6 +27544,7 @@ $as_echo "#define HAVE_BOOL /**/" >>confdefs.h
 
 fi
 
+    AX_CXX_COMPILE_STDCXX_11()
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether the compiler implements namespaces" >&5
 $as_echo_n "checking whether the compiler implements namespaces... " >&6; }
 if ${ax_cv_cxx_namespaces+:} false; then :
@@ -27754,6 +27755,8 @@ ac_link='$CC -o conftest$ac_exeext $CFLAGS $CPPFLAGS $LDFLAGS conftest.$ac_ext $
 ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 
+    CXXFLAGS="-std=c++11 $CXXFLAGS"
+
     { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether C++ compiler is sufficient for Magick++" >&5
 $as_echo_n "checking whether C++ compiler is sufficient for Magick++... " >&6; }
     if \
